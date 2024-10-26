set lines 9999
set pages 9999
col CLIENT_IDENTIFIER for a40
col TRACEFILE for a80
select s.sid,s.serial#,s.username,s.osuser, s.client_identifier, s.sql_trace,s.action, p.TRACEFILE
from v$session s,v$process p
where s.paddr=p.addr
and s.username is not null
order by 3 desc;