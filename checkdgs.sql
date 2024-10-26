-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : checkdgs.sql                                                                          --
-- Description   : Displays info of DG config e status - Run on Staddby side.                            --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ views.                                                              --
-- Call Syntax   : @checkdgs                                                                             --
-- Last Modified : 07/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


set echo off;
set heading off;
set feedback off;
SET WRAP ON;
SET TIMING OFF;
set wrap on;
set colsep " | "
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
set lines 999;
set pages 999;
col host for a40
col schema for a25
col data for a18
col status for a10
set serveroutput on

set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   STATUS ATUAL DO BANCO DE DADOS  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;

prompt
SELECT i.HOST_NAME host,
i.INSTANCE_NAME instance,
SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') schema,logins, to_char(sysdate,'DD/MM/YYYY hh24:mi:ss') DATA_VALIDACAO,i.STATUS,i.startup_time
FROM GV$INSTANCE i;
prompt

set heading OFF;
prompt
select 'OBS: O campo DATAGUARD_BROKER = ENABLE indica que e usado o broker como orquestrador da replicacao. ' from dual;
set heading ON;
prompt
col guard_status for a15;
col DATAGUARD_BROKER for a25;
SELECT NAME,DB_UNIQUE_NAME, OPEN_MODE, LOG_MODE,DATABASE_ROLE,GUARD_STATUS, DATAGUARD_BROKER,SWITCHOVER_STATUS FROM V$DATABASE;
prompt


set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '   CONFIGURACAO DATA GUARD   ' from dual;
select '-----------------------------------------' from dual;
prompt
prompt
set heading ON;

Select
    Tb.Database_Role as "Database_Role",
    Tb.Open_Mode as "Open_Mode",
    Tb.Protection_Mode as "Protection_Mode",
    Tb.Inst_Name as "INSTANCE_NAME",
    Tb.Name as "Metric",
    Tb.Seconds as "SECONDS",
    Tb.Computedsecondsago as "COMPUTE_SECONDS_AGO",
    Case
        When (Tb.Database_Role = 'PHYSICAL STANDBY' Or Tb.Database_Role ='LOGICAL STANDBY') And Tb.Name ='apply lag' Then  Tb.Averageapplyrate
        Else 0 End as "Average_Apply_Rate"
From
(Select
(Select Database_Role From V$database) As Database_Role,
(Select Open_Mode From V$database) As Open_Mode,
(Select Protection_Mode From V$database) As Protection_Mode,
(select i.instance_name from gv$instance i where s.Inst_Id=i.Inst_Id) as Inst_Name,
s.Name,
((Extract(Second From To_Dsinterval(Value)) + Extract(Minute From To_Dsinterval(Value)) * 60
+ Extract(Hour From To_Dsinterval(Value)) *60*60 + Extract(Day From To_Dsinterval(Value)) *60*60*24)) As Seconds,
Round(Sysdate - To_Date(Datum_Time,'MM/DD/YYYY HH24:MI:SS'),2) As Computedsecondsago,
(Select max(Round(Sofar/1024,2)) "Mb/sec" From Gv$recovery_Progress Where Item='Average Apply Rate') Averageapplyrate
From Gv$dataguard_Stats s Where Name In ('apply lag') And Datum_Time Is Not Null)Tb;
prompt

prompt
set lines 1000
select to_char(start_time, 'dd-mon-rr hh24:mi:ss') start_time,
       item, round(sofar/1024,2) "MB/Sec"
       from v$recovery_progress
       where (item='Active Apply Rate' or item='Average Apply Rate');
prompt


set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '   STATUS PROCESSO DE REPLICACAO   ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;


prompt
select * from v$dataguard_stats;
prompt


prompt
SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY;
prompt

set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   STATUS DOS DESTs E FRA  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;

prompt
set lines 9999 pages 9999
col dest_name for a20;
col SYNCHRONIZED for a15;
col error for a30;
col DESTINATION for a12;
set lines 160;
set pages 300;
select dest_id, dest_name, DESTINATION, status, database_mode, error, SYNCHRONIZED, GAP_STATUS from v$archive_dest_status where database_mode <> 'UNKNOWN';
prompt

prompt
column destination format a35 wrap
column process format a7
column ID format 99
column mid format 99
SELECT thread#, dest_id, destination, gvad.status, target, schedule, process, mountid mid FROM gv$archive_dest gvad, gv$instance gvi WHERE gvad.inst_id = gvi.inst_id AND destination is NOT NULL ORDER BY thread#, dest_id;
prompt

prompt
select dest_name, target, status, schedule, valid_now, db_unique_name, log_sequence from v$archive_dest where target = 'STANDBY';
prompt

prompt
SELECT * FROM SYS.V_$FLASH_RECOVERY_AREA_USAGE;
prompt

prompt
col IS_RECOVERY_DEST_FILE for a23;
col STANDBY_DEST for a10;
COL DELETED for a7;
select * from (
select sequence#, 
       first_time, 
       next_time, 
       dest_id, 
       STANDBY_DEST, 
       APPLIED, 
       DELETED, 
       CASE
          WHEN STATUS = 'A'
           THEN 'Disponivel'
          WHEN STATUS = 'D'
           THEN 'Deletado'
          WHEN STATUS = 'U'
           THEN 'Indisponivel'
          WHEN STATUS = 'X'
           THEN 'Expirado'
         ELSE 'NULL' END STATE 
from v$archived_log 
where first_time > trunc(sysdate)-1 and dest_id = 2 
order by sequence# desc);
prompt


set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   DEST ERRORs   ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt

prompt
SELECT thread#, dest_id, gvad.status, error FROM gv$archive_dest gvad, gv$instance gvi WHERE gvad.inst_id = gvi.inst_id AND destination is NOT NULL ORDER BY thread#, dest_id;
prompt


set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   SESSOES EM PARALLEL - REDO APPLY  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt

select count(*), username, status, state, event from gv$session where event like '%parallel recovery%' or event like '%checkpoint%' group by username, status, state, event;
prompt

set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   APLICACAO DOS ARCHIVES NO STANDBY  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';
set lines 255;
set pages 255;
break on report on thread skip 1
compute sum label "gap total: " of gap on report
select a.thread# as thread,
b.last_seq,
a.applied_seq,
a.last_app_timestamp,
b.last_seq - a.applied_seq gap
from ( select thread#,
max (sequence#) applied_seq,
max (next_time) last_app_timestamp
from gv$archived_log
where applied = 'YES'
group by thread#) a,
( select thread#, max (sequence#) last_seq
from gv$archived_log
group by thread#) b
where a.thread# = b.thread#;

set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   SEQUENCE SENDO APLICADA AGORA  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt

set lines 1000
col PCT heading "Pct %" FORMAT 999,999,990
select process, thread#, sequence#, status, BLOCK#, BLOCKS, round((BLOCK#/BLOCKS)*100,3) as "PCT" from v$managed_standby where process='MRP0';



set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   LOG APLICACAO  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt


set lines 1000
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'; 
col message format a120
select timestamp, message from v$dataguard_status;


set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   BACKUPS EXECUTANDO NO MOMENTO  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt

COLUMN username FORMAT A10
COLUMN osuser FORMAT A12 WORD_WRAP TRUNC
COLUMN spid FORMAT A9
COLUMN service_name FORMAT A15
COLUMN machine FORMAT A15 WORD_WRAP TRUNC
COLUMN program FORMAT A10 WORD_WRAP TRUNC
COLUMN SID/SERIAL FORMAT A14
COLUMN LAST_CALL_ET FORMAT A16
COLUMN action FORMAT A24 WORD_WRAP TRUNC
COLUMN module FORMAT A20 WORD_WRAP TRUNC
COLUMN state FORMAT A17 WORD_WRAP TRUNC
COLUMN status FORMAT A12 WORD_WRAP TRUNC
COLUMN resource_consumer_group FORMAT A18 WORD_WRAP TRUNC
COLUMN event FORMAT A40 WORD_WRAP TRUNC
SELECT NVL(s.username, '(oracle)') AS username,
       s.inst_id,
       s.osuser,
       s.sid || ',' || s.serial#||',@'||s.inst_id as "SID/SERIAL",
       s.status,
       s.event,
       s.machine,
       s.program,
       s.action,
       s.module,
       TRUNC(last_call_et / (60 * 60 * 24)) || 'D ' ||
           TRUNC(MOD(last_call_et / (60 * 60 * 24),
                     TRUNC(last_call_et / (60 * 60 * 24))) * 24) || 'H ' ||
           TRUNC(MOD((MOD(last_call_et / (60 * 60 * 24),
                          TRUNC(last_call_et / (60 * 60 * 24))) * 24),
                     TRUNC(MOD(last_call_et / (60 * 60 * 24),
                               TRUNC(last_call_et / (60 * 60 * 24))) * 24)) * 60) || 'M ' ||
           TRUNC(MOD((MOD((MOD(last_call_et / (60 * 60 * 24),
                               TRUNC(last_call_et / (60 * 60 * 24))) * 24),
                          TRUNC(MOD(last_call_et / (60 * 60 * 24),
                                    TRUNC(last_call_et / (60 * 60 * 24))) * 24)) * 60),
                     (TRUNC(MOD((MOD(last_call_et / (60 * 60 * 24),
                                     TRUNC(last_call_et / (60 * 60 * 24))) * 24),
                                TRUNC(MOD(last_call_et / (60 * 60 * 24),
                                          TRUNC(last_call_et / (60 * 60 * 24))) * 24)) * 60))) * 60) || 'S ' AS LAST_CALL_ET
FROM   gv$session s
WHERE program LIKE '%rman%' or program like '%backup%'
AND s.status ='ACTIVE';
prompt

set echo on;
set feedback on;
