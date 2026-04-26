-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : loadnode.sql                                                                          --
-- Description   : Displays info about db load per DB Node                                               --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @loadnode <Qtde dias>                                                                 --
-- Last Modified : 07/10/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

SET SQLFORMAT 
SET FEEDBACK OFF
SET VERIFY OFF
SET LINES 400
SET PAGES 50
COL SNAP_ID FORMAT 9999999
COL BEGIN_TIME FORMAT A20
COL NODE1 FORMAT 999.99
COL NODE2 FORMAT 999.99
COL NODE3 FORMAT 999.99
COL NODE4 FORMAT 999.99
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI';

SELECT O.SNAP_ID,
       MIN(S.BEGIN_INTERVAL_TIME) AS BEGIN_TIME, 
       ROUND( SUM( DECODE(O.INSTANCE_NUMBER,1,VALUE,0) ) ,2) AS NODE1,
       ROUND( SUM( DECODE(O.INSTANCE_NUMBER,2,VALUE,0) ) ,2) AS NODE2,
       ROUND( SUM( DECODE(O.INSTANCE_NUMBER,3,VALUE,0) ) ,2) AS NODE3,
       ROUND( SUM( DECODE(O.INSTANCE_NUMBER,4,VALUE,0) ) ,2) AS NODE4
    --
       -- add more instances ...
    --
FROM DBA_HIST_SNAPSHOT S
JOIN DBA_HIST_OSSTAT O ON (S.SNAP_ID = O.SNAP_ID AND S.DBID = O.DBID AND S.INSTANCE_NUMBER = O.INSTANCE_NUMBER)
WHERE S.BEGIN_INTERVAL_TIME >= TRUNC(SYSDATE)-&1
AND O.STAT_NAME LIKE '%LOAD%'
GROUP BY O.SNAP_ID
ORDER BY 1;