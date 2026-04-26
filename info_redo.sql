-- ########################################################################################################
--                                                                                                       --
-- File Name     : info_redo.sql                                                                         --
-- Description   : Displays info about redo generation - matriz                                          --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @info_redo                                                                            --
-- Last Modified : 05/07/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

set heading off;
set feedback off;
prompt
prompt
select '-----------------------------' from dual;
select '   REDO - MAPA DE GERACAO  ' from dual;
select '-----------------------------' from dual;
prompt
prompt    
set heading on;
set feedback on;                          
set lines 9999
column  dt format a8 heading 'DATE'
column  t1 format a4 heading 00h
column  t2 format a4 heading 01h
column  t3 format a4 heading 02h
column  t4 format a4 heading 03h
column  t5 format a4 heading 04h
column  t6 format a4 heading 05h
column  t7 format a4 heading 06h
column  t8 format a4 heading 07h
column  t9 format a4 heading 08h
column t10 format a4 heading 09h
column t11 format a4 heading 10h
column t12 format a4 heading 11h
column t13 format a4 heading 12h
column t14 format a4 heading 13h
column t15 format a4 heading 14h
column t16 format a4 heading 15h
column t17 format a4 heading 16h
column t18 format a4 heading 17h
column t19 format a4 heading 18h
column t20 format a4 heading 19h
column t21 format a4 heading 20h
column t22 format a4 heading 21h
column t23 format a4 heading 22h
column t24 format a4 heading 23h
column  tt format a5 heading TOTAL
select to_char(first_time,'yyyymmdd') dt,
decode(sum(decode(to_char(first_time,'hh24'),'00',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'00',1,0))) t1,
decode(sum(decode(to_char(first_time,'hh24'),'01',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'01',1,0))) t2,
decode(sum(decode(to_char(first_time,'hh24'),'02',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'02',1,0))) t3,
decode(sum(decode(to_char(first_time,'hh24'),'03',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'03',1,0))) t4,
decode(sum(decode(to_char(first_time,'hh24'),'04',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'04',1,0))) t5,
decode(sum(decode(to_char(first_time,'hh24'),'05',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'05',1,0))) t6,
decode(sum(decode(to_char(first_time,'hh24'),'06',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'06',1,0))) t7,
decode(sum(decode(to_char(first_time,'hh24'),'07',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'07',1,0))) t8,
decode(sum(decode(to_char(first_time,'hh24'),'08',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'08',1,0))) t9,
decode(sum(decode(to_char(first_time,'hh24'),'09',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'09',1,0))) t10,
decode(sum(decode(to_char(first_time,'hh24'),'10',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'10',1,0))) t11,
decode(sum(decode(to_char(first_time,'hh24'),'11',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'11',1,0))) t12,
decode(sum(decode(to_char(first_time,'hh24'),'12',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'12',1,0))) t13,
decode(sum(decode(to_char(first_time,'hh24'),'13',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'13',1,0))) t14,
decode(sum(decode(to_char(first_time,'hh24'),'14',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'14',1,0))) t15,
decode(sum(decode(to_char(first_time,'hh24'),'15',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'15',1,0))) t16,
decode(sum(decode(to_char(first_time,'hh24'),'16',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'16',1,0))) t17,
decode(sum(decode(to_char(first_time,'hh24'),'17',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'17',1,0))) t18,
decode(sum(decode(to_char(first_time,'hh24'),'18',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'18',1,0))) t19,
decode(sum(decode(to_char(first_time,'hh24'),'19',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'19',1,0))) t20,
decode(sum(decode(to_char(first_time,'hh24'),'20',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'20',1,0))) t21,
decode(sum(decode(to_char(first_time,'hh24'),'21',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'21',1,0))) t22,
decode(sum(decode(to_char(first_time,'hh24'),'22',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'22',1,0))) t23,
decode(sum(decode(to_char(first_time,'hh24'),'23',1,0)),0,'-',sum(decode(to_char(first_time,'hh24'),'23',1,0))) t24,
decode(count(*),0,'-',count(*)) tt
from sys.gv_$log_history
where first_time > SYSDATE - 31
group by to_char(first_time,'yyyymmdd')
order by 1 desc;

SET LINES 9999
SET PAGES 100
COL DATA    FORMAT A25
COL GB_SIZE FORMAT 999,999,999,999
COL QTDE    FORMAT 999,999,999,999
COL DUMMY   FORMAT a10 HEADING ""
COMPUTE AVG OF GB_SIZE ON DUMMY
BREAK ON dummy


SELECT '' as dummy,
       TRUNC(COMPLETION_TIME,'DD') DATA, 
       sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024 GB_SIZE,
       COUNT(*) QTDE,
	   MIN(SEQUENCE#) MIN_SEQ#
  FROM V$ARCHIVED_LOG L
WHERE STANDBY_DEST = 'NO'
   AND COMPLETION_TIME >= trunc(sysdate) - 50
GROUP BY TRUNC(COMPLETION_TIME,'DD')
ORDER BY DATA;


set heading off;
set feedback off;
prompt
prompt
select '-----------------------------' from dual;
select '   REDO - INFORMACOES  ' from dual;
select '-----------------------------' from dual;
prompt
prompt    
set heading on;
set feedback on; 
set lines 9999 pages 9999;
col member for a60;
select a.THREAD#, 
       a.GROUP#, 
       a.STATUS, 
       b.MEMBER, 
       (a.BYTES/1024/1024) as TAM_MB, 
       nvl( b.STATUS, 'EM USO' ) LOG_FILE_STATUS,
       a.ARCHIVED, 
       a.SEQUENCE#
from V$LOG a, V$LOGFILE b
where b.GROUP# = a.GROUP#
order by 1, 2
/
prompt
set heading off;
set feedback off;
select 'Tamanho do REDO atual : '|| sum(bytes/1024/1024/1024) || ' GB' from gv$log;
SELECT 'ARCHIVE_LAG_TARGET in Min: '|| VALUE/60 FROM GV$PARAMETER WHERE NAME = 'archive_lag_target';
prompt
prompt
set heading on;
set feedback on;
