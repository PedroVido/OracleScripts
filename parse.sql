-- Find Hard Parse Queries

col sql_opname for a20;
col module for a15;
with pivot2 as
(
SELECT
ASH.inst_id,
ASH.user_id,
ASH.session_id sid,
ASH.session_serial# serial#,
ASH.sql_opname,
ASH.module,
ASH.top_level_sql_id,
ASH.sql_id,
ASH.sql_exec_id,
ASH.SQL_PLAN_HASH_VALUE,
ASH.in_hard_parse,
    NVL(ASH.sql_exec_start, min(sample_time)) sql_start_time,
    MAX(sample_time) sql_end_time,
    (CAST(MAX(sample_time)  AS DATE) - CAST( NVL(ASH.sql_exec_start, min(sample_time)) AS DATE)) * 3600*24 etime_secs
from gv$active_session_history ASH
WHERE ASH.session_type = 'FOREGROUND'
and  ASH.sql_id is not null
group by ASH.inst_id, ASH.user_id, ASH.session_id, ASH.session_serial#, ASH.sql_opname, ASH.module, ASH.top_level_sql_id, ASH.sql_id,  ASH.sql_exec_id, ASH.sql_plan_hash_value, ASH.in_hard_parse, sql_exec_start
)
select SM.*
from pivot2 SM
inner join dba_users T1 on T1.user_id = SM.user_id
and rownum <=20
order by sql_start_time asc;