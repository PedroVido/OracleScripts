-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : loadavg.sql                                                                           --
-- Description   : Displays info about db load                                                           --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @loadavg <Qtde dias> <inst> (Onde Inst ID = 0 soma todas as instancias do cluster)    --
-- Last Modified : 07/10/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################



set verify off
set feedback off
alter session set nls_date_format='dd/mm Dy';
set sqlformat 
set pages 999 lines 400
col snap_date heading "Date" format a10
col h0  format 999.99
col h1  format 999.99
col h2  format 999.99
col h3  format 999.99
col h4  format 999.99
col h5  format 999.99
col h6  format 999.99
col h7  format 999.99
col h8  format 999.99
col h9  format 999.99
col h10 format 999.99
col h11 format 999.99
col h12 format 999.99
col h13 format 999.99
col h14 format 999.99
col h15 format 999.99
col h16 format 999.99
col h17 format 999.99
col h18 format 999.99
col h19 format 999.99
col h20 format 999.99
col h21 format 999.99
col h22 format 999.99
col h23 format 999.99
set feedback ON

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &2 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&2 = 0 or inst_id = &2);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Load Average
PROMP Qt. Dias..: &1
PROMP Instance..: &VNODE
PROMP

-- query
with awr as (
  select a.snap_id, b.begin_interval_time as begin_snap,
	     max(value) load_avg
	from DBA_HIST_OSSTAT a
	join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.dbid = b.dbid and a.instance_number = b.instance_number)
	where 1=1
	and a.STAT_NAME = 'LOAD'
	and (&2 = 0 or b.instance_number = &2)
	and b.begin_interval_time >= trunc(sysdate) - &1
	group by a.snap_id, b.begin_interval_time
)
SELECT TRUNC(begin_snap) snap_date,
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', load_avg, null)) "h0",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', load_avg, null)) "h1",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', load_avg, null)) "h2",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', load_avg, null)) "h3",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', load_avg, null)) "h4",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', load_avg, null)) "h5",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', load_avg, null)) "h6",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', load_avg, null)) "h7",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', load_avg, null)) "h8",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', load_avg, null)) "h9",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', load_avg, null)) "h10",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', load_avg, null)) "h11",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', load_avg, null)) "h12",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', load_avg, null)) "h13",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', load_avg, null)) "h14",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', load_avg, null)) "h15",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', load_avg, null)) "h16",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', load_avg, null)) "h17",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', load_avg, null)) "h18",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', load_avg, null)) "h19",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', load_avg, null)) "h20",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', load_avg, null)) "h21",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', load_avg, null)) "h22",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', load_avg, null)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;