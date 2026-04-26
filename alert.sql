-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : alert.sql                                                                             --
-- Description   : Query to view alert Errors and ORAs                                                   --
-- Comments      : Need to logon as sysdba                                                               --
-- Requirements  : Access to the x$dbgalertext.                                                          --
-- Usage:         SQL> @alert                                                                            --
--                                                                                                       --
-- Last Modified : 09/12/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

--alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
--set lines 9999 pages 9999
--col originating_timestamp format a35
--col message_text format a100
--select distinct
--   to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY HH24:MI') as DATA_ALERTA,
--   message_text
--from x$dbgalertext
--where originating_timestamp > (sysdate-12/24)
--and message_text like '%ORA-%'
--order by DATA_ALERTA asc;


alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
set lines 9999 pages 9999
col originating_timestamp format a35
col message_text format a200
select distinct
   to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY HH24:MI') as DATA_ALERTA,
   message_text
from x$dbgalertext
where originating_timestamp > (sysdate - 4)
--and message_text like '%ORA-%'
and regexp_like(message_text, '(ORA-|error)')
order by DATA_ALERTA asc;