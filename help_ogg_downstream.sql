
-- ########################################################################################################
--                                                                                                       --
-- File Name     : ogg_downstream_scripts.sql                                                            --
-- Description   : Displays info about ogg replication and gap                                           --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @ogg_downstream_scripts                                                               --
-- Last Modified : 22/02/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

-- Parametros obsoletos

TRANLOGOPTIONS INCLUDEREGIONID


-- Mostra informacoes sobre XStream outbound servers
select SERVER_NAME,STATUS,USER_COMMENT,START_SCN from DBA_XSTREAM_OUTBOUND;
 
 
 -- Mostra os servers de caputura disponiveis
col SERVER_NAME for a20;
col CREATE_DATE for a30;
col USER_COMMENT for a40;
select SERVER_NAME,CREATE_DATE,USER_COMMENT from SYS.XSTREAM$_SERVER;
 

 -- Mostra os processos de caputura e seus status, se estao ou nao atachados a um server process
col CAPTURE_NAME for a20;
col CAPTURE_USER for a10;
col ERROR_MESSAGE for a40;
col status for a10;
col CLIENT_STATUS for a15;
col PURPOSE for a20;
select CAPTURE_NAME,CAPTURE_USER,FIRST_SCN,ERROR_MESSAGE,CLIENT_STATUS,PURPOSE,OLDEST_SCN, status from dba_capture;



-- Executar com SYS - Mostra os erros do alert referente a falta de archives para o processo de captua

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
set lines 9999 pages 9999
col originating_timestamp format a35
col message_text format a100
select distinct
   to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY HH24:MI') as DATA_ALERTA,
   message_text
from x$dbgalertext
where originating_timestamp > (sysdate-1)
and message_text like '%Missing log for capture%'
order by DATA_ALERTA asc;

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
set lines 9999 pages 9999
col originating_timestamp format a35
col message_text format a100
select distinct
   to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY HH24:MI') as DATA_ALERTA,
   message_text
from x$dbgalertext
where originating_timestamp > (sysdate-2)
and message_text like '%LOGMINER%'
order by DATA_ALERTA asc;

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
set lines 9999 pages 9999
col originating_timestamp format a35
col message_text format a100
select distinct
   to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY HH24:MI') as DATA_ALERTA,
   message_text
from x$dbgalertext
where originating_timestamp > (sysdate-1)
and message_text like '%ORA%'
order by DATA_ALERTA asc;



set lines 9999 pages 9999
col originating_timestamp format a35
col message_text format a100
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
select * from (
select distinct
   to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY HH24:MI') as DATA_ALERTA,
   message_text
from x$dbgalertext
where originating_timestamp > (sysdate-1)
order by DATA_ALERTA asc)
where rownum <=100;



-- Mostra sessoes ativas e inativas do user OGGFORBD - Banco que o extract conecta

COLUMN username FORMAT A20
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
COLUMN event FORMAT A10 WORD_WRAP TRUNC
COLUMN sql_id FORMAT a15
COLUM client_info FORMAT a25
SELECT  distinct s.inst_id,
       s.sid||','||s.serial#||',@'||s.inst_id as "SID/SERIAL",
       NVL(s.username, '(oracle)') AS username,
	   s.osuser,
	   s.client_info,
	   s.module,
	   s.sql_id,
       s.status,
       s.machine,
	   s.logon_time,
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
                                          TRUNC(last_call_et / (60 * 60 * 24))) * 24)) * 60))) * 60) || 'S ' AS LAST_CALL_ET, s.blocking_session
FROM   gv$session s,
       gv$process p
WHERE  s.paddr  = p.addr
AND    s.inst_id = p.inst_id
AND    s.username ='OGGFORBD' or s.username ='OGGADMDS'
AND    S.inst_id = '1'
---AND   s. sid= 909
AND s.sid != (SELECT sid FROM v$mystat WHERE ROWNUM=1)
order by 1,7,8 desc;


-- validate session 

col username for a20
col program for a30 word_wrap trunc
COL EVENT FOR A50 word_wrap trunc
COL MODULE FOR A20 
SELECT SID, SERIAL#, USERNAME, SQL_ID, PROGRAM, MODULE, STATUS, EVENT, BLOCKING_SESSION
FROM V$SESSION
WHERE EVENT LIKE '%logminer%' OR MODULE LIKE '%GoldenGate%';



--To display this information about each registered archive redo log file in a database, run the following query:

COLUMN CONSUMER_NAME HEADING 'Capture|Process|Name' FORMAT A15
COLUMN SOURCE_DATABASE HEADING 'Source|Database' FORMAT A10
COLUMN SEQUENCE# HEADING 'Sequence|Number' FORMAT 99999
COLUMN NAME HEADING 'Archived Redo Log|File Name' FORMAT A20
COLUMN DICTIONARY_BEGIN HEADING 'Dictionary|Build|Begin' FORMAT A10
COLUMN DICTIONARY_END HEADING 'Dictionary|Build|End' FORMAT A10

SELECT r.CONSUMER_NAME,
       r.SOURCE_DATABASE,
       r.SEQUENCE#, 
       r.NAME, 
       r.DICTIONARY_BEGIN, 
       r.DICTIONARY_END 
  FROM DBA_REGISTERED_ARCHIVED_LOG r, DBA_CAPTURE c
  WHERE r.CONSUMER_NAME = c.CAPTURE_NAME;  


-- To display this information about each required archive redo log file in a database, run the following query:

  COLUMN CONSUMER_NAME HEADING 'Capture|Process|Name' FORMAT A15
COLUMN SOURCE_DATABASE HEADING 'Source|Database' FORMAT A10
COLUMN SEQUENCE# HEADING 'Sequence|Number' FORMAT 99999
COLUMN NAME HEADING 'Required|Archived Redo Log|File Name' FORMAT A40

SELECT r.CONSUMER_NAME,
       r.SOURCE_DATABASE,
       r.SEQUENCE#, 
       r.NAME 
  FROM DBA_REGISTERED_ARCHIVED_LOG r, DBA_CAPTURE c
  WHERE r.CONSUMER_NAME =  c.CAPTURE_NAME AND
        r.NEXT_SCN      >= c.REQUIRED_CHECKPOINT_SCN;  

      