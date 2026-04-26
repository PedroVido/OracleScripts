set verify off
set feedback off
alter session set nls_date_format='dd/mm Dy';
set sqlformat 
set pages 9999 lines 9999
col snap_date heading "Date" format a10
col h0  format 999,999,999,990
col h1  format 999,999,999,990
col h2  format 999,999,999,990
col h3  format 999,999,999,990
col h4  format 999,999,999,990
col h5  format 999,999,999,990
col h6  format 999,999,999,990
col h7  format 999,999,999,990
col h8  format 999,999,999,990
col h9  format 999,999,999,990
col h10 format 999,999,999,990
col h11 format 999,999,999,990
col h12 format 999,999,999,990
col h13 format 999,999,999,990
col h14 format 999,999,999,990
col h15 format 999,999,999,990
col h16 format 999,999,999,990
col h17 format 999,999,999,990
col h18 format 999,999,999,990
col h19 format 999,999,999,990
col h20 format 999,999,999,990
col h21 format 999,999,999,990
col h22 format 999,999,999,990
col h23 format 999,999,999,990
set feedback ON

-- resumo do relatorio
PROMP
PROMP Metrica...: User Commits
PROMP Qt. Dias..: &1


-- query
with awr as (
select 
TO_CHAR (END_INTERVAL_TIME, 'dd/mm/yyyy hh24') as hora,
min(hsnap.END_INTERVAL_TIME) begin_snap,
max(hsys.VALUE) as qtde
from dba_hist_sysstat hsys, dba_hist_snapshot hsnap
where hsys.snap_id = hsnap.snap_id
and hsnap.instance_number = hsys.instance_number
and hsnap.END_INTERVAL_TIME >= trunc(sysdate) - &1
and hsys.STAT_NAME='user commits'
GROUP BY TO_CHAR (END_INTERVAL_TIME, 'dd/mm/yyyy hh24')
)
SELECT TRUNC(begin_snap) snap_date,
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', qtde, 0)) "h0",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', qtde, 0)) "h1",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', qtde, 0)) "h2",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', qtde, 0)) "h3",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', qtde, 0)) "h4",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', qtde, 0)) "h5",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', qtde, 0)) "h6",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', qtde, 0)) "h7",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', qtde, 0)) "h8",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', qtde, 0)) "h9",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', qtde, 0)) "h10",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', qtde, 0)) "h11",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', qtde, 0)) "h12",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', qtde, 0)) "h13",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', qtde, 0)) "h14",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', qtde, 0)) "h15",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', qtde, 0)) "h16",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', qtde, 0)) "h17",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', qtde, 0)) "h18",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', qtde, 0)) "h19",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', qtde, 0)) "h20",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', qtde, 0)) "h21",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', qtde, 0)) "h22",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', qtde, 0)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;

