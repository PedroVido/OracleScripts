-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : checkdgp.sql                                                                          --
-- Description   : Displays info of DG config e status - Run on Primary side.                            --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ views.                                                              --
-- Call Syntax   : @checkdgp                                                                             --
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
prompt
select '-----------------------------------------' from dual;
select '   CONFIGURACAO DATA GUARD   ' from dual;
select '-----------------------------------------' from dual;
prompt


prompt
select 'OBS: O campo DATAGUARD_BROKER = ENABLE indica que esta sendo usado o broker como orquestrador da replicacao. ' from dual;
set heading ON;


prompt
select recovery_mode from v$archive_dest_status where dest_id = 2;
prompt

prompt
col guard_status for a15;
col DATAGUARD_BROKER for a25;
SELECT NAME,DB_UNIQUE_NAME, OPEN_MODE, LOG_MODE,DATABASE_ROLE,GUARD_STATUS, DATAGUARD_BROKER,SWITCHOVER_STATUS FROM V$DATABASE;
prompt



set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '   STATUS PROCESSO DE REPLICACAO   ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;


SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY;


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
select dest_name, target, status, schedule, valid_now, db_unique_name, log_sequence from v$archive_dest where target = 'STANDBY';
prompt

prompt
SELECT * FROM SYS.V_$FLASH_RECOVERY_AREA_USAGE;
prompt


set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   STATUS ARCHIVES  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;

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
--where rownum <= 10
prompt


set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   APLICACAO DOS ARCHIVES NO STANDBY  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;

COL archived_seq#   FOR a10 HEADING 'Ultima Seq| Recebida' JUSTIFY RIGHT
COL applied_seq#   FOR a10 HEADING 'Ultima Seq| Aplicada' JUSTIFY RIGHT
col dest_id for 99
col dest_name for a20
col db_unique_name for a12
  select dest_id
,        dest_name
,        gap_status
,        archived_thread#
,        archived_seq#
,        applied_thread#
,        applied_seq#
,        type
,        database_mode
,        recovery_mode
,        status
--,        error
    from v$archive_dest_status ads
   where status              != 'INACTIVE'
     and recovery_mode       in ('MANAGED', 'MANAGED REAL TIME APPLY')
order by dest_id
,        archived_thread#;


prompt
set lines 1000
select a.Ultimo_recebido_no_DR, Aplicando_no_DR, (a.Ultimo_recebido_no_DR - b.aplicando_no_DR) as Falta_aplicar
from 
(select max(r.sequence#) Ultimo_recebido_no_DR from v$archived_log r, v$log l where r.dest_id = 2 and l.archived='YES')a, 
(select APPLIED_SEQ# Aplicando_no_DR from v$archive_dest_status where status = 'VALID' and TYPE = 'PHYSICAL')b ;
prompt





--set heading OFF;
--prompt
--select '-----------------------------------------' from dual;
--select '   APLICACAO DOS ARCHIVES NO STANDBY  ' from dual;
--select '-----------------------------------------' from dual;
--prompt
--set heading ON;
--prompt
--
--col DESTINATION for a50;
--select
--    'Thread=>'||a.thread# ||' Service Destination=> '||(select  distinct DESTINATION from V$ARCHIVE_DEST_STATUS where DEST_ID =a.DEST_ID AND TYPE<>'DOWNSTREAM') DESTINATION,
--    DEST_ID,
--    (select max (sequence#) from v$archived_log where archived='YES' and thread#=a.thread#) archived,
--    max (a.sequence#) applied,
--    (select max (sequence#) from v$archived_log where archived='YES' and thread#=a.thread#)-max (a.sequence#) gap,
--    (select DECODE(database_role, 'SNAPSHOT STANDBY', 1, 'LOGICAL STANDBY', 2, 'PHYSICAL STANDBY', 3, 'PRIMARY', 4, 'FAR SYNC', 5, 0) AS ROLE FROM v$database) AS GAP_DATABASE_ROLE,
--	max (next_time) last_app_timestamp
--from v$archived_log a
--where a.applied='YES'
--and (select  distinct DESTINATION from V$ARCHIVE_DEST_STATUS where DEST_ID =a.DEST_ID and SRL='YES' AND TYPE<>'DOWNSTREAM') is not null
--and DEST_ID <> 1
--group by a.thread#, DEST_ID
--order by DEST_ID,a.thread#;