-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : mem.sql                                                                               --
-- Description   : Displays info abaout memeory used by sessions.                                        --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @mem                                                                                  --
-- Last Modified : 30/08/2024                                                                            --
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
select '   CONSUMO DE MEMORIA POR SESSAO  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;


SET LINESIZE 9999
SET PAGESIZE 9999
COLUMN spid HEADING 'OSpid' FORMAT a8
COLUMN pid HEADING 'Orapid' FORMAT 999999
COLUMN sid HEADING 'Sess id' FORMAT 99999
COLUMN serial# HEADING 'Serial#' FORMAT 999999
COLUMN status HEADING 'Status' FORMAT a8
COLUMN pga_alloc_mem HEADING 'PGA alloc' FORMAT 99,999,999,999
COLUMN pga_used_mem HEADING 'PGA used' FORMAT 99,999,999,999
COLUMN username HEADING 'Oracle user' FORMAT a20
COLUMN osuser HEADING 'OS user' FORMAT a20
COLUMN program HEADING 'Program' FORMAT a20 word_wrap trunc
SELECT p.spid,
       p.pid,
       s.sid,
       s.serial#,
       s.status,
       p.pga_alloc_mem,
       p.pga_used_mem,
       s.username,
       s.osuser,
       s.program,
	   s.sql_id
FROM v$process p, v$session s
WHERE s.paddr( + ) = p.addr
and s.username is not null
ORDER BY p.pga_alloc_mem DESC;
PROMPT
PROMPT

set heading OFF;
prompt
select '-----------------------------------------' from dual;
select '   CONSUMO DE MEMORIA TOTAL  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;

SELECT SUM(pga_alloc_mem)/1024/1024 AS "Mbytes allocated", SUM(pga_used_mem)/1024/1024 AS "Mbytes used" FROM v$process;
