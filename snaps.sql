/*
 Script para gerar uma matriz com a lista de SNAP ID do AWR do início de cada Hora do Dia
 Sintaxe: SQL>@snaps <Qtd. Dias>
 Exemplo: SQL>@snaps 30
 
 Maicon Carneiro | Salvador-BA, 23/11/2022
*/

set verify off
set feedback off
alter session set nls_date_format='dd/mm Dy';
set sqlformat 
set pages 999 lines 400
col snap_date heading "Date" format a10
col h0  format 999999
col h1  format 999999
col h2  format 999999
col h3  format 999999
col h4  format 999999
col h5  format 999999
col h6  format 999999
col h7  format 999999
col h8  format 999999
col h9  format 999999
col h10 format 999999
col h11 format 999999
col h12 format 999999
col h13 format 999999
col h14 format 999999
col h15 format 999999
col h16 format 999999
col h17 format 999999
col h18 format 999999
col h19 format 999999
col h20 format 999999
col h21 format 999999
col h22 format 999999
col h23 format 999999
set feedback ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Snap ID do AWR
PROMP Qt. Dias..: &1


-- query
with awr as (
SELECT TO_CHAR (END_INTERVAL_TIME, 'dd/mm/yyyy hh24') as hora,
       min(END_INTERVAL_TIME) as begin_snap,
	   min(SNAP_ID) as snap_id
 FROM DBA_HIST_SNAPSHOT
 WHERE END_INTERVAL_TIME >= trunc(sysdate) - &1
GROUP BY TO_CHAR (END_INTERVAL_TIME, 'dd/mm/yyyy hh24')
)
SELECT TRUNC(begin_snap) snap_date,
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', snap_id, 0)) "h0",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', snap_id, 0)) "h1",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', snap_id, 0)) "h2",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', snap_id, 0)) "h3",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', snap_id, 0)) "h4",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', snap_id, 0)) "h5",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', snap_id, 0)) "h6",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', snap_id, 0)) "h7",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', snap_id, 0)) "h8",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', snap_id, 0)) "h9",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', snap_id, 0)) "h10",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', snap_id, 0)) "h11",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', snap_id, 0)) "h12",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', snap_id, 0)) "h13",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', snap_id, 0)) "h14",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', snap_id, 0)) "h15",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', snap_id, 0)) "h16",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', snap_id, 0)) "h17",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', snap_id, 0)) "h18",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', snap_id, 0)) "h19",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', snap_id, 0)) "h20",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', snap_id, 0)) "h21",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', snap_id, 0)) "h22",
 max (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', snap_id, 0)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;