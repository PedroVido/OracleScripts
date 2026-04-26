-- ########################################################################################################
--                                                                                                       --
-- File Name     : info_undo.sql                                                                         --
-- Description   : Displays info about redo                                                              --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @info_undo                                                                            --
-- Last Modified : 13/03/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/RRRR HH24:MI:SS';
ALTER SESSION SET NLS_LANGUAGE='BRAZILIAN PORTUGUESE';
ALTER SESSION SET NLS_TERRITORY='BRAZIL';

set serverout on size 1000000;
set feedback off;
set heading off;
set linesize 300;
set trimspool on;

select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
select 'INFORME DE ESTIMATIVA DE UNDO_RETENTION ' 																				FROM dual;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;

declare
cursor get_undo_stat is
        select d.undo_size/(1024*1024) "C1",
               substr(e.value,1,25)    "C2",
               (to_number(e.value) * to_number(f.value) * g.undo_block_per_sec) / (1024*1024) "C3",
               round((d.undo_size / (to_number(f.value) * g.undo_block_per_sec)))             "C4"
          from (select sum(a.bytes) undo_size
                  from v$datafile      a,
                       v$tablespace    b,
                       dba_tablespaces c
                 where c.contents = 'UNDO'
                   and c.status = 'ONLINE'
                   and b.name = c.tablespace_name
                   and a.ts# = b.ts#)  d,
               v$parameter e,
               v$parameter f,
               (select max(undoblks/((end_time-begin_time)*3600*24)) undo_block_per_sec from v$undostat)  g
         where e.name = 'undo_retention'
           and f.name = 'db_block_size';
begin
dbms_output.put_line(chr(10)||chr(10)||chr(10)||chr(10) || 'Para otimizar UNDO você tem duas escolhas :');
dbms_output.put_line('====================================================' || chr(10));
for rec1 in get_undo_stat loop
dbms_output.put_line('A) ajustar o tamanho da UNDO tablespace de acordo com UNDO_RETENTION:' || chr(10));
dbms_output.put_line(rpad('ACTUAL UNDO SIZE ',65,'.')|| ' : ' ||TO_CHAR(rec1.c1,'999999') || ' MB');
dbms_output.put_line(rpad('OPTIMAL UNDO SIZE WITH ACTUAL UNDO_RETENTION (' || ltrim(TO_CHAR(rec1.c2/1,'999999'))
|| ' SEGS)',65,'.') || ' : ' || TO_CHAR(rec1.c3,'99999999') || ' MB' );
dbms_output.put_line(chr(10));
dbms_output.put_line('B) ajustar o UNDO_RETENTION de acordo com o tamanho da UNDO tablespace:' || chr(10));
dbms_output.put_line(rpad('ACTUAL UNDO RETENTION ',65,'.') || ' : ' || TO_CHAR(rec1.c2/1,'999999') || ' SEGS');
dbms_output.put_line(rpad('OPTIMAL UNDO RETENTION WITH ACTUAL UNDO SIZE (' || ltrim(TO_CHAR(rec1.c1/1,'999999')) || ' SEGS) ',65,'.')
|| ' : '|| TO_CHAR(rec1.c4/1,'999999')|| ' SEGS');
end loop;
dbms_output.put_line(chr(10)||chr(10));
end;
/

select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
select 'ESTATISTICAS SESSOES ORACLE:' 																						FROM dual;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;


select 'Number of "ORA-01555 (Snapshot too old)" encountered since the last startup of the instance : ' || sum(ssolderrcnt)
from v$undostat;

select '' AS "Estatisticas errors ORA-01555"
  From dual
UNION ALL
select TO_CHAR(TRUNC(BEGIN_TIME),'DD/MM/RRRR')||' -> [' || sum(ssolderrcnt) ||'] ocurrencias'
from v$undostat
GROUP BY TRUNC(BEGIN_TIME);

select 'OBSERVACOES:'||CHR(10)||CHR(13)||'-Instancia  ' || instance_name || ' en ' || host_name|| ' foi iniciada em  '||to_char(startup_time,'DD/MM/RRRR HH24:MI:SS')|| ' ... '
from v$instance;

select '-UNDO_RETENTION esta configurado em : [' || value || '] SEGUNDOS, o que corresponde a ['||value/60|| '] MINUTOS ou, ['||value/60/60|| '] HORAS'
from v$parameter
where name = 'undo_retention';



select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
select  'SHOW ROLLBACK INFORMATION BY SESSION: 																				' FROM dual;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
SET PAGESIZE 60
SET LINESIZE 300
SET HEADING ON;
 
COLUMN username FORMAT A20
--COLUMN sid FORMAT 9999
COLUMN serial# FORMAT 99999
 
SELECT s.username,
       s.sid,
       s.serial#,
	   nvl(s.sql_id,s.prev_sql_id) as SQL,
       s.status,
       t.used_ublk,
       t.used_urec,
       rs.segment_name,
       round(r.rssize/1024/1024) USAGE_MB,
       r.status   
FROM   v$transaction t,
       v$session s,
       v$rollstat r,
       dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr
AND    t.xidusn = r.usn
AND   rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC
/

SET HEADING OFF;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
select  'SHOW UNDO INFORMATION BY SESSION: 																				' FROM dual;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
SET PAGESIZE 60
SET LINESIZE 300
SET HEADING ON;

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.program,
	s.sql_id,
    t.used_urec AS undo_records,
    t.used_ublk AS undo_blocks,
    ROUND(t.used_ublk * (SELECT value FROM v$parameter WHERE name = 'db_block_size') / 1024, 2) AS undo_size_kb,
    s.status,
    s.osuser,
    s.machine,
    s.logon_time
FROM
    v$session s
JOIN
    v$transaction t
ON
    s.saddr = t.ses_addr
ORDER BY
    t.used_ublk DESC
/



set feedback off;
set heading off;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
select  'HISTORICAL USE OF UNDO TBS: 																				' FROM dual;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
SET PAGESIZE 60
SET LINESIZE 300
SET HEADING ON;


with t as (
select ss.run_time,
       ts.name,round(su.tablespace_size*dt.block_size/1024/1024/1024,2) alloc_size_gb,
       round(su.tablespace_usedsize*dt.block_size/1024/1024/1024,2) used_size_gb
from dba_hist_tbspc_space_usage su,
     (select trunc(BEGIN_INTERVAL_TIME) run_time,max(snap_id) snap_id from dba_hist_snapshot group by trunc(BEGIN_INTERVAL_TIME) ) ss,
     v$tablespace ts,
     dba_tablespaces dt
where su.snap_id = ss.snap_id
and su.tablespace_id = ts.ts#
and ts.name like '%UNDO%1'
and ts.name = dt.tablespace_name )
select * from (
select e.run_time,
       e.name,
	   e.alloc_size_gb,
	   e.used_size_gb curr_used_size_gb,
	   b.used_size_gb prev_used_size_gb, 
	   (e.used_size_gb - b.used_size_gb) as variance
from t e, t b
where e.run_time = b.run_time + 1
order by 1 desc)
where rownum <=30;


-----

with t as (
select ss.run_time,
       ts.name,round(su.tablespace_size*dt.block_size/1024/1024/1024,2) alloc_size_gb,
       round(su.tablespace_usedsize*dt.block_size/1024/1024/1024,2) used_size_gb
from dba_hist_tbspc_space_usage su,
     (select trunc(BEGIN_INTERVAL_TIME) run_time,max(snap_id) snap_id from dba_hist_snapshot group by trunc(BEGIN_INTERVAL_TIME) ) ss,
     v$tablespace ts,
     dba_tablespaces dt
where su.snap_id = ss.snap_id
and su.tablespace_id = ts.ts#
and ts.name like '%UNDO%2'
and ts.name = dt.tablespace_name )
select * from (
select e.run_time,
       e.name,
	   e.alloc_size_gb,
	   e.used_size_gb curr_used_size_gb,
	   b.used_size_gb prev_used_size_gb, 
	   (e.used_size_gb - b.used_size_gb) as variance
from t e, t b
where e.run_time = b.run_time + 1
order by 1 desc)
where rownum <=30;

-----

with t as (
select ss.run_time,
       ts.name,round(su.tablespace_size*dt.block_size/1024/1024/1024,2) alloc_size_gb,
       round(su.tablespace_usedsize*dt.block_size/1024/1024/1024,2) used_size_gb
from dba_hist_tbspc_space_usage su,
     (select trunc(BEGIN_INTERVAL_TIME) run_time,max(snap_id) snap_id from dba_hist_snapshot group by trunc(BEGIN_INTERVAL_TIME) ) ss,
     v$tablespace ts,
     dba_tablespaces dt
where su.snap_id = ss.snap_id
and su.tablespace_id = ts.ts#
and ts.name like '%UNDO%3'
and ts.name = dt.tablespace_name )
select * from (
select e.run_time,
       e.name,
	   e.alloc_size_gb,
	   e.used_size_gb curr_used_size_gb,
	   b.used_size_gb prev_used_size_gb, 
	   (e.used_size_gb - b.used_size_gb) as variance
from t e, t b
where e.run_time = b.run_time + 1
order by 1 desc)
where rownum <=30;

-----

with t as (
select ss.run_time,
       ts.name,round(su.tablespace_size*dt.block_size/1024/1024/1024,2) alloc_size_gb,
       round(su.tablespace_usedsize*dt.block_size/1024/1024/1024,2) used_size_gb
from dba_hist_tbspc_space_usage su,
     (select trunc(BEGIN_INTERVAL_TIME) run_time,max(snap_id) snap_id from dba_hist_snapshot group by trunc(BEGIN_INTERVAL_TIME) ) ss,
     v$tablespace ts,
     dba_tablespaces dt
where su.snap_id = ss.snap_id
and su.tablespace_id = ts.ts#
and ts.name like '%UNDO%4'
and ts.name = dt.tablespace_name )
select * from (
select e.run_time,
       e.name,
	   e.alloc_size_gb,
	   e.used_size_gb curr_used_size_gb,
	   b.used_size_gb prev_used_size_gb, 
	   (e.used_size_gb - b.used_size_gb) as variance
from t e, t b
where e.run_time = b.run_time + 1
order by 1 desc)
where rownum <=30;


set heading off;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;
select 'FINAL INFORME '||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') 															  FROM dual;
select '-------------------------------------------------------------------------------------------------------------------' FROM dual;

SET FEEDBACK OFF;
SET ECHO OFF;
SET FEEDBACK ON;
SET HEADING ON;
