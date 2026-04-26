-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : gap.sql                                                                               --
-- Description   : Ver gap no standby e calcular pct de aplicacao.                                       --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @gap - on standby side.                                                               --
-- Created       : 20/07/2023                                                                            --
-- Last Modified : 17/12/2025 - Add case for 0 on BLOCK# and BLOCK Columns.                              --
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
select '   SEQUENCE SENDO APLICADA AGORA  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt

SELECT NAME, VALUE FROM V$DATAGUARD_STATS;
prompt
prompt

set lines 1000
col PCT heading "Pct %" FORMAT 999,999,990
col status for a20;
select process, thread#, sequence#, status, BLOCK#, BLOCKS, 
case 
when BLOCK# > 0 and BLOCKS > 0 then round(BLOCK#/BLOCKS*100,3) 
END as PCT
from v$managed_standby where process='MRP0';

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