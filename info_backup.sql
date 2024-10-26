-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : info_backup.sql                                                                       --
-- Description   : Historical information about backup types.                                            --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ views and grant alter session.                                      --
-- Call Syntax   : @info_backup                                                                          --
-- Last Modified : 20/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SET WRAP ON;
SET LINE 500 PAGES 5000;
SET COLSEP ' | '
COL INPUT FORMAT A10
COL OUTPUT FORMAT A10
COL INPUT_SEC FORMAT A10
COL OUTPUT_SEC FORMAT A10
COL DB_NAME FORMAT A15
COL STATUS FORMAT A30
--COL HRS FORMAT 999.99
set echo off;
set heading off;
set feedback off;
prompt
prompt
select '-----------------------------------' from dual;
select '  INFO BACKUP FULL - LAST 10 DAYS  ' from dual;
select '-----------------------------------' from dual;
prompt
prompt
set heading on;
set feedback on;
SET WRAP ON;
SELECT  sys_context('USERENV', 'DB_NAME') DB_NAME,
START_TIME as "START_DATE",
END_TIME,
TRIM('.' FROM TRIM(BOTH '0' FROM TRIM('+' FROM TO_CHAR(NUMTODSINTERVAL(elapsed_seconds, 'SECOND'), 'HH24:MI:SS')))) EXEC_TIME,
INPUT_TYPE,
--INPUT_BYTES_DISPLAY INPUT,
OUTPUT_BYTES_DISPLAY OUTPUT,
INPUT_BYTES_PER_SEC_DISPLAY INPUT_SEC,
OUTPUT_BYTES_PER_SEC_DISPLAY OUTPUT_SEC,
STATUS
FROM V$RMAN_BACKUP_JOB_DETAILS
WHERE INPUT_TYPE='DB FULL'
AND START_TIME > SYSDATE-10
--GROUP BY INPUT_TYPE, STATUS, START_TIME,OUTPUT_DEVICE_TYPE, END_TIME,ELAPSED_SECONDS,OUTPUT_BYTES_DISPLAY
ORDER BY START_TIME DESC;
set heading off;
set feedback off;
prompt
prompt
select '-----------------------------------------------' from dual;
select '  INFO BACKUP INCREMENTAL - L0 / L1 - LAST 10 DAYS ' from dual;
select '-----------------------------------------------' from dual;
prompt
prompt
set heading on;
set feedback on;
SELECT  sys_context('USERENV', 'DB_NAME') DB_NAME,
START_TIME as "START_DATE",
END_TIME,
TRIM('.' FROM TRIM(BOTH '0' FROM TRIM('+' FROM TO_CHAR(NUMTODSINTERVAL(elapsed_seconds, 'SECOND'), 'HH24:MI:SS')))) EXEC_TIME,
INPUT_TYPE,
--INPUT_BYTES_DISPLAY INPUT,
OUTPUT_BYTES_DISPLAY OUTPUT,
INPUT_BYTES_PER_SEC_DISPLAY INPUT_SEC,
OUTPUT_BYTES_PER_SEC_DISPLAY OUTPUT_SEC,
STATUS
FROM V$RMAN_BACKUP_JOB_DETAILS
WHERE INPUT_TYPE like 'DB INCR%'
AND START_TIME > SYSDATE-10
--GROUP BY INPUT_TYPE, STATUS, START_TIME,OUTPUT_DEVICE_TYPE, END_TIME,ELAPSED_SECONDS,OUTPUT_BYTES_DISPLAY
ORDER BY START_TIME DESC;
set heading off;
set feedback off;
prompt
prompt
select '----------------------------------------' from dual;
select '  INFO BACKUP ARCHIVELOG - LAST 1 DAY   ' from dual;
select '----------------------------------------' from dual;
prompt
prompt
set heading on;
set feedback on;
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
set lines 9999
set pages 9999
col START_DATE for a10
col EXEC_TIME for a10
col STATUS for a23
COL INPUT FORMAT A10
COL OUTPUT FORMAT A10
COL INPUT_SEC FORMAT A10
COL OUTPUT_SEC FORMAT A10
COL DB_NAME FORMAT A10
SELECT  sys_context('USERENV', 'DB_NAME') DB_NAME,
START_TIME as "START_DATE",
END_TIME,
TRIM('.' FROM TRIM(BOTH '0' FROM TRIM('+' FROM TO_CHAR(NUMTODSINTERVAL(elapsed_seconds, 'SECOND'), 'HH24:MI:SS')))) EXEC_TIME,
INPUT_TYPE,
OUTPUT_DEVICE_TYPE,
--INPUT_BYTES_DISPLAY INPUT,
OUTPUT_BYTES_DISPLAY OUTPUT,
INPUT_BYTES_PER_SEC_DISPLAY INPUT_SEC,
OUTPUT_BYTES_PER_SEC_DISPLAY OUTPUT_SEC,
STATUS
FROM V$RMAN_BACKUP_JOB_DETAILS
WHERE INPUT_TYPE='ARCHIVELOG'
AND START_TIME > SYSDATE-3
--GROUP BY INPUT_TYPE, STATUS, START_TIME, OUTPUT_DEVICE_TYPE, END_TIME,ELAPSED_SECONDS,OUTPUT_BYTES_DISPLAY
ORDER BY START_TIME DESC;
set heading off;
set feedback off;
prompt
prompt
select '-----------------------------------' from dual;
select ' TYPES OF BACKUP MADE ON DATABASE  ' from dual;
select '-----------------------------------' from dual;
prompt
prompt
set heading on;
set feedback on;
SELECT COUNT(*), INPUT_TYPE  as "BACKUP TYPE"
FROM V$RMAN_BACKUP_JOB_DETAILS
GROUP BY INPUT_TYPE
ORDER BY 1 DESC;
set heading off;
set feedback off;
prompt
prompt
select '-------------------------------------------------------' from dual;
select ' BACKUP OPERATIONS TOTAL WORK/SOFAR - EXECUTING NOW  ' from dual;
select '-------------------------------------------------------' from dual;
prompt
prompt
set heading on;
set feedback on;
column i_lops_sid       heading SID                      for a5
column s.username       heading USERNAME                 for a30
column i_lops_nmae      heading 'OPERATION'              for a33
column i_lops_targ      heading 'TARGET'                 for a40
column i_lops_sof       heading 'BLK|READS'              for 999999999999999
column i_lops_work      heading 'BLK|TOTAL'              for 999999999999999
column i_lops_pct       heading 'PCT(%)'                 for 990.90
column i_lops_star      heading 'DT_START'               for a11
column i_lops_elap      heading 'ELAPSED|DD:HH:MI:SS'    for a11
column i_lops_rem       heading 'REMAINING|DD:HH:MI:SS'  for a11
column i_lops_blk       heading 'BLK'                    for a3
column COMPLETE         heading '% COMPLETE'             for a10
set lines 9999;
set pages 9999;
column message forma a100;
select  
        s.inst_id,
        to_char(l.sid) i_lops_sid,
		s.username,
        s.sql_id,
        l.opname i_lops_nmae,
        l.target i_lops_targ,
        l.sofar  i_lops_sof,
        l.totalwork i_lops_work,
    --    MESSAGE,
        trunc((l.sofar/l.totalwork)*100,2) i_lops_pct,
        to_char(l.start_time, 'DD/MM HH24:MI') i_lops_star,
        trunc(l.elapsed_seconds/86400) || ':' || to_char(to_date(mod(l.elapsed_seconds,86400), 'SSSSS'), 'HH24:MI:SS') i_lops_elap,
        trunc(l.time_remaining/86400)|| ':' || to_char(to_date(mod(l.time_remaining,86400), 'SSSSS'), 'HH24:MI:SS') i_lops_rem
		--ROUND (l.SOFAR/l.TOTALWORK*100, 2) COMPLETE
from gv$session_longops l, gv$session s
where   time_remaining > 0
and      l.sid = s.sid (+)
and l.inst_id = s.inst_id
and l.OPNAME LIKE 'RMAN%' AND l.OPNAME NOT LIKE '%aggregate%'
AND l.TOTALWORK != 0 AND l.SOFAR != TOTALWORK
order by 9 desc;
SET COLSEP ' ';
prompt
prompt
set heading off;
set feedback off;
prompt
prompt
--select '-------------------------------------------------------' from dual;
--select '                       ASM SPACE                        ' from dual;
--select '-------------------------------------------------------' from dual;
--prompt
--prompt
--set heading on;
--set feedback on;
--@asm_spacex