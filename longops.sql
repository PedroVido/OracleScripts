prompt
prompt
set heading off;
set feedback off;
select '------------------------' from dual;
select '   LONG OPERATIONS ' from dual;
select '------------------------' from dual;
prompt
prompt 
set heading on;
set feedback on;
column i_lops_sid       heading SID                      for a5
column s.username       heading USERNAME                 for a15
column i_lops_nmae      heading 'OPERATION'              for a33
column i_lops_targ      heading 'TARGET'                 for a40
column i_lops_sof       heading 'BLK|READS'              for 999999999999999
column i_lops_work      heading 'BLK|TOTAL'              for 999999999999999
column i_lops_pct       heading 'PCT(%)'                 for 990.90
column i_lops_star      heading 'DT_START'               for a11
column i_lops_elap      heading 'ELAPSED|DD:HH:MI:SS'    for a11
column i_lops_rem       heading 'REMAINING|DD:HH:MI:SS'  for a11
column i_lops_blk       heading 'BLK'                    for a3

column MESSAGE format a60
select
        s.inst_id,
        to_char(l.sid) i_lops_sid,
		s.username,
        s.sql_id,
/*      decode(l.opname,
                'Hash Join', 'Hash Join',
                'Index Fast Full Scan', 'Index Scan',
                'Sort Output', 'Sort Output',
                'Sort/Merge', 'Sort Merge',
                'Table Scan', 'Table Scan',
        l.opname) i_lops_nmae,*/
        l.opname i_lops_nmae,
        l.target i_lops_targ,
        l.sofar  i_lops_sof,
        l.totalwork i_lops_work,
        --MESSAGE,
        trunc((l.sofar/l.totalwork)*100,2) i_lops_pct,
        to_char(l.start_time, 'DD/MM HH24:MI') i_lops_star,
        trunc(l.elapsed_seconds/86400) || ':' || to_char(to_date(mod(l.elapsed_seconds,86400), 'SSSSS'), 'HH24:MI:SS') i_lops_elap,
        trunc(l.time_remaining/86400)|| ':' || to_char(to_date(mod(l.time_remaining,86400), 'SSSSS'), 'HH24:MI:SS') i_lops_rem
from
        gv$session_longops l, gv$session s
where   time_remaining > 0
and      l.sid = s.sid (+)
and     sofar <> totalwork
and l.inst_id = s.inst_id
order by i_lops_pct desc;