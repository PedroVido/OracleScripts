-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : automate_capacity_asm.sql                                                             --
-- Description   : Displays infos for agent IA - Solicitacao ASM.                                        --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ and DBA views.                                                      --
-- Call Syntax   : @automate_capacity_asm                                                                --
-- Last Modified : 17/03/2026                                                                            --
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

-- Novas Variaveis
v_os_size number := 0;
v_total_size number := 0;
v_free_size number := 0;
v_dg_name varchar(10);
v_nome_banco varchar(20);


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
BEGIN

SELECT NAME into v_nome_banco
from v$database;
--DG_NAME
SELECT NAME into v_dg_name
	FROM V$ASM_DISKGROUP
    WHERE NAME = 'DG_DATA' or NAME = 'DATAC1' or NAME = 'DATA';
-- TOTAL_MB
SELECT round( TOTAL_MB / DECODE(TYPE,'HIGH',3,'NORMAL',2,1)/1024,2)  into v_total_size
	FROM V$ASM_DISKGROUP
    WHERE NAME = 'DG_DATA' or NAME = 'DATAC1' or NAME = 'DATA';

-- FREE_MB
SELECT round(USABLE_FILE_MB/1024,2) into v_free_size
	FROM V$ASM_DISKGROUP
    WHERE NAME = 'DG_DATA' or NAME = 'DATAC1' or NAME = 'DATA';

-- OS DISK SIZE 
SELECT round(B.OS_MB/1024,2) INTO v_os_size
    FROM V$ASM_DISK B, V$ASM_DISKGROUP A
    WHERE A.GROUP_NUMBER (+) =B.GROUP_NUMBER
	AND a.name like '%DATA%'
	and rownum = 1;
END;
DBMS_OUTPUT.PUT_LINE(CHR(10));
--DBMS_OUTPUT.PUT_LINE('Summary');
--DBMS_OUTPUT.PUT_LINE('========');
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('0) NOME_BANCO        : '||v_nome_banco);
DBMS_OUTPUT.PUT_LINE('1) NOME_DISCO        : '||v_dg_name);
DBMS_OUTPUT.PUT_LINE('2) DB_CRESCIMENTO    : '||round(((v_db_growth/v_numdays)*30)/1024,2) ||' GB');
DBMS_OUTPUT.PUT_LINE('3) ESPACO_TOTAL      : '||v_total_size ||' GB');
DBMS_OUTPUT.PUT_LINE('4) ESPACO_FREE       : '||v_free_size ||' GB');
DBMS_OUTPUT.PUT_LINE('5) TAMANHO_DISCO     : '||v_os_size ||' GB');
DBMS_OUTPUT.PUT_LINE(CHR(10));
--DBMS_OUTPUT.PUT_LINE('/\/\/\/\/\/\/\/\/\/\/ END \/\/\/\/\/\/\/\/\/\/\');
EXCEPTION
WHEN NOT_IN_AWR THEN
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('====================================================================================================================');
DBMS_OUTPUT.PUT_LINE('!!! ONE OR MORE TABLESPACES USAGE INFORMATION NOT FOUND IN AWR !!!');
DBMS_OUTPUT.PUT_LINE('Execute DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT, or wait for next AWR snapshot capture before executing this script');
DBMS_OUTPUT.PUT_LINE('====================================================================================================================');
END;
/