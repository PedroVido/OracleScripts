-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : db_crescimento.sql                                                                    --
-- Description   : Displays estimates info about DB growth : 30, 60, 90 and 360 days.                    --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ and DBA views.                                                      --
-- Call Syntax   : @db_crescimento                                                                       --
-- Last Modified : 07/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

set serverout on
set verify off
set lines 200
set pages 2000
DECLARE
v_ts_id number;
not_in_awr EXCEPTION;
v_ts_block_size number;
v_begin_snap_id number;
v_end_snap_id number;
v_begin_snap_date date;
v_end_snap_date date;
v_numdays number;
v_count number;
v_ts_begin_size number;
v_ts_end_size number;
v_ts_growth number;
v_ts_begin_allocated_space number;
v_ts_end_allocated_space number;
v_db_begin_size number := 0;
v_db_end_size number := 0;
v_db_begin_allocated_space number := 0;
v_db_end_allocated_space number := 0;
v_db_growth number := 0;
cursor v_cur is select tablespace_name from dba_tablespaces where contents='PERMANENT';
BEGIN
FOR v_rec in v_cur
LOOP
BEGIN
v_ts_begin_allocated_space := 0;
v_ts_end_allocated_space := 0;
v_ts_begin_size := 0;
v_ts_end_size := 0;
SELECT ts# into v_ts_id FROM v$tablespace where name = v_rec.tablespace_name;
SELECT block_size into v_ts_block_size FROM dba_tablespaces where tablespace_name = v_rec.tablespace_name;
select count(*) into v_count from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id;
IF v_count=0 THEN
RAISE not_in_awr;
END IF;
SELECT min(snap_id), max(snap_id), min(trunc(to_date(rtime,'MM/DD/YYYY HH24:MI:SS'))), max(trunc(to_date(rtime,'MM/DD/YYYY HH24:MI:SS')))
into v_begin_snap_id,v_end_snap_id, v_begin_snap_date, v_end_snap_date from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id;
IF UPPER(v_rec.tablespace_name)='SYSTEM' THEN
v_numdays := v_end_snap_date - v_begin_snap_date;
END IF;
SELECT round(max(tablespace_size)*v_ts_block_size/1024/1024,2) into v_ts_begin_allocated_space from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id and snap_id = v_begin_snap_id;
SELECT round(max(tablespace_size)*v_ts_block_size/1024/1024,2) into v_ts_end_allocated_space from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id and snap_id = v_end_snap_id;
SELECT round(max(tablespace_usedsize)*v_ts_block_size/1024/1024,2) into v_ts_begin_size from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id and snap_id = v_begin_snap_id;
SELECT round(max(tablespace_usedsize)*v_ts_block_size/1024/1024,2) into v_ts_end_size from dba_hist_tbspc_space_usage where tablespace_id=v_ts_id and snap_id = v_end_snap_id;
v_db_begin_allocated_space := v_db_begin_allocated_space + v_ts_begin_allocated_space;
v_db_end_allocated_space := v_db_end_allocated_space + v_ts_end_allocated_space;
v_db_begin_size := v_db_begin_size + v_ts_begin_size;
v_db_end_size := v_db_end_size + v_ts_end_size;
v_db_growth := v_db_end_size - v_db_begin_size;
END;
END LOOP;
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('Summary');
DBMS_OUTPUT.PUT_LINE('========');
DBMS_OUTPUT.PUT_LINE('1) Allocated Space: '||v_db_end_allocated_space||' MB'||' ('||round(v_db_end_allocated_space/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE('2) Used Space: '||v_db_end_size||' MB'||' ('||round(v_db_end_size/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE('3) Used Space Percentage: '||round(v_db_end_size/v_db_end_allocated_space*100,2)||' %');
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('History');
DBMS_OUTPUT.PUT_LINE('========');
DBMS_OUTPUT.PUT_LINE('1) Allocated Space on '||v_begin_snap_date||': '||v_db_begin_allocated_space||' MB'||' ('||round(v_db_begin_allocated_space/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE('2) Current Allocated Space on '||v_end_snap_date||': '||v_db_end_allocated_space||' MB'||' ('||round(v_db_end_allocated_space/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE('3) Used Space on '||v_begin_snap_date||': '||v_db_begin_size||' MB'||' ('||round(v_db_begin_size/1024,2)||' GB)' );
DBMS_OUTPUT.PUT_LINE('4) Current Used Space on '||v_end_snap_date||': '||v_db_end_size||' MB'||' ('||round(v_db_end_size/1024,2)||' GB)' );
DBMS_OUTPUT.PUT_LINE('5) Total growth during last '||v_numdays||' days between '||v_begin_snap_date||' and '||v_end_snap_date||': '||v_db_growth||' MB'||' ('||round(v_db_growth/1024,2)||' GB)');
IF (v_db_growth <= 0 OR v_numdays <= 0) THEN
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('No data growth was found for the Database');
ELSE
DBMS_OUTPUT.PUT_LINE('6) Per day growth during last '||v_numdays||' days: '||round(v_db_growth/v_numdays,2)||' MB'||' ('||round((v_db_growth/v_numdays)/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('Expected Growth');
DBMS_OUTPUT.PUT_LINE('===============');
DBMS_OUTPUT.PUT_LINE('1) Expected growth for next 30 days: '|| round((v_db_growth/v_numdays)*30,2)||' MB'||' ('||round(((v_db_growth/v_numdays)*30)/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE('2) Expected growth for next 60 days: '|| round((v_db_growth/v_numdays)*60,2)||' MB'||' ('||round(((v_db_growth/v_numdays)*60)/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE('3) Expected growth for next 90 days: '|| round((v_db_growth/v_numdays)*90,2)||' MB'||' ('||round(((v_db_growth/v_numdays)*90)/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE('3) Expected growth for next 360 days: '|| round((v_db_growth/v_numdays)*360,2)||' MB'||' ('||round(((v_db_growth/v_numdays)*360)/1024,2)||' GB)');
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('/\/\/\/\/\/\/\/\/\/\/ END \/\/\/\/\/\/\/\/\/\/\');
END IF;
EXCEPTION
WHEN NOT_IN_AWR THEN
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('====================================================================================================================');
DBMS_OUTPUT.PUT_LINE('!!! ONE OR MORE TABLESPACES USAGE INFORMATION NOT FOUND IN AWR !!!');
DBMS_OUTPUT.PUT_LINE('Execute DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT, or wait for next AWR snapshot capture before executing this script');
DBMS_OUTPUT.PUT_LINE('====================================================================================================================');
END;
/