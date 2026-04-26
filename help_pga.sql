
set pagesize 999

column name  format a40
column value format 999,999,999,999,999

select inst_id
      ,name
      ,value
      ,unit
from gv$pgastat
order by name, inst_id



set linesize 9999
set pagesize 9999

col TYPE format a25
col MB format 999,999
col event format a50
col SESS format A15
col logon_time for a25

select  ss.sid||','||ss.serial# as SESS,
        ss.username,
        ss.status,
        ss.machine,
        ss.sql_id,
        ss.event,
        ss.logon_time,
        sn.name "TYPE",
        ceil(st.value / 1024 / 1024) "MB"
  from  v$sesstat st,
        v$statname sn,
        v$session ss
 where  st.statistic# = sn.statistic#
   and  st.sid = ss.sid
   and  upper(sn.name) like '%PGA%'
   and ceil(st.value / 1024 / 1024) > 100
 order by ceil(st.value / 1024 / 1024) desc, st.sid, st.value desc;



ALTER SYSTEM SET PGA_AGGREGATE_TARGET = 10240M SCOPE=BOTH;