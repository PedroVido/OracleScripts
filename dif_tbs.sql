-- ########################################################################################################
--                                                                                                       --
-- File Name     : dif_tbs.sql                                                                           --
-- Description   : Displays info about tablaspaces growth over the months.                               --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA and V$ views.                                                       --
-- Call Syntax   : @dif_tbs                                                                              --
-- Last Modified : 17/02/2025                                                                            --
-- Author        : Adriano Francisco - Acc - ZABBIX                                                      --
--                                                                                                       --
-- ########################################################################################################

alter session set nls_date_format='dd/mm/yyyy';

SELECT * FROM 
(SELECT
     CF.TS_NAME
    ,CF.MES
    ,ROUND(((CF.DIFF)*T.BLOCK_SIZE)/1024/1024/1024) AS DIFF_GB 
FROM 
(SELECT 
    NVL((SELECT NAME FROM V$TABLESPACE V WHERE CL.TABLESPACE_ID=V.TS#),'DROPED')AS TS_NAME
    ,CL.MES
    ,CL.USED
    ,CL.DIFF 
FROM 
(SELECT  
     A.DBID
    ,TABLESPACE_ID
    ,TRUNC(END_INTERVAL_TIME, 'MONTH') MES
    ,MAX(TABLESPACE_USEDSIZE) USED
    ,LAG(MAX(TABLESPACE_USEDSIZE),1,0) OVER (PARTITION BY TABLESPACE_ID ORDER BY TRUNC(END_INTERVAL_TIME, 'MONTH'))PREV
    ,(MAX(TABLESPACE_USEDSIZE)-(LAG(MAX(TABLESPACE_USEDSIZE),1,0) OVER (PARTITION BY TABLESPACE_ID ORDER BY TRUNC(END_INTERVAL_TIME, 'MONTH'))))DIFF
    FROM DBA_HIST_TBSPC_SPACE_USAGE A INNER JOIN DBA_HIST_SNAPSHOT S ON S.SNAP_ID=A.SNAP_ID AND S.DBID=A.DBID 
GROUP BY 
     A.DBID
    ,TABLESPACE_ID
    ,TRUNC(END_INTERVAL_TIME, 'MONTH') ORDER BY 2,3) CL 
WHERE  CL.TABLESPACE_ID IS NOT NULL) CF JOIN DBA_TABLESPACES T ON CF.TS_NAME=T.TABLESPACE_NAME 
)
PIVOT (
MAX (DIFF_GB) FOR MES IN (
'01/09/2026' AS "SET-26",
'01/10/2026' AS "OUT-26",
'01/11/2026' AS "NOV-26",
'01/12/2026' AS "DEZ-26",
'01/01/2026' AS "JAN-26"
));



--------

set lines 9999 pages 9999
SELECT 
     FN.TS_NAME AS "TABLESPACE NAME"
    ,FN."DAYS" AS "ANALYSIS WINDOW (DAYS)"
    ,FN."BEGIN USED GB" AS "USED SPACE BEGIN WINDOW (GB)"
    ,FN."USED GB" AS "USED SPACE END WINDOW (GB)"
    ,FN."ALLOC GB" AS "ALLOCATED SPACE (GB)"
    ,FN."MAX GB"   AS "MAX SIZE (GB)" 
    ,FN."MAX GB UTIL" AS "MAX SIZE UTIL (GB)"
    ,FN."DIFF_GB" AS "GROWTH (GB)"
    ,ROUND(CASE WHEN FN."DIFF_GB" > 0 THEN ("MAX GB UTIL" - FN."USED GB") / (FN."DIFF_GB" / FN."DAYS") ELSE NULL END) AS "FREE SPACE (DAYS)"
FROM 
(SELECT
     CF.TS_NAME
    ,ROUND(((CF.USEDPREV)*T.BLOCK_SIZE)/1024/1024/1024) AS "BEGIN USED GB"
    ,ROUND(((CF.USED)*T.BLOCK_SIZE)/1024/1024/1024) AS "USED GB"
    ,ROUND(((CF.ALLOC)*T.BLOCK_SIZE)/1024/1024/1024) AS "ALLOC GB"
    ,ROUND(((CF."MAX")*T.BLOCK_SIZE)/1024/1024/1024) AS "MAX GB"
    ,ROUND(((CF.DIFF)*T.BLOCK_SIZE)/1024/1024/1024,1) AS DIFF_GB 
    ,CF."DAYS"
    ,ROUND(CASE WHEN ROUND(((CF.USED)*T.BLOCK_SIZE)/1024/1024/1024) <= 200 THEN ROUND(((CF."MAX")*T.BLOCK_SIZE)/1024/1024/1024) * 0.7 
          WHEN ROUND(((CF.USED)*T.BLOCK_SIZE)/1024/1024/1024) > 200 AND ROUND(((CF.USED)*T.BLOCK_SIZE)/1024/1024/1024) <= 800 THEN ROUND(((CF."MAX")*T.BLOCK_SIZE)/1024/1024/1024) * 0.8
          WHEN ROUND(((CF.USED)*T.BLOCK_SIZE)/1024/1024/1024) > 800 AND ROUND(((CF.USED)*T.BLOCK_SIZE)/1024/1024/1024) <= 10000 THEN ROUND(((CF."MAX")*T.BLOCK_SIZE)/1024/1024/1024) * 0.9
          WHEN ROUND(((CF.USED)*T.BLOCK_SIZE)/1024/1024/1024) > 10000  THEN ROUND(((CF."MAX")*T.BLOCK_SIZE)/1024/1024/1024) * 0.97 ELSE NULL END) "MAX GB UTIL"
FROM 
(SELECT 
    NVL((SELECT NAME FROM V$TABLESPACE V WHERE CL.TABLESPACE_ID=V.TS#),'DROPED')AS TS_NAME
    ,CL."USED"
    ,CL.ALLOC
    ,CL."MAX"
    ,CL."USEDPREV"
    ,CL."DIFF"
    ,CL."DAYS"
FROM 
(SELECT  
     A.DBID
    ,A.TABLESPACE_ID
    ,MAX(MX.TABLESPACE_USEDSIZE) "USED"
    ,MAX(MX.TABLESPACE_SIZE) "ALLOC"
    ,MAX(MX.TABLESPACE_MAXSIZE) "MAX"
    ,MIN(MN.TABLESPACE_USEDSIZE) "USEDPREV"
    ,(MAX(MX.TABLESPACE_USEDSIZE)- MIN(MN.TABLESPACE_USEDSIZE))DIFF
    ,COUNT(DISTINCT TO_CHAR(S.END_INTERVAL_TIME, 'YYYY-MM-DD')) "DAYS"
    FROM DBA_HIST_TBSPC_SPACE_USAGE A INNER JOIN DBA_HIST_SNAPSHOT S ON S.SNAP_ID=A.SNAP_ID AND S.DBID=A.DBID 
                                      INNER JOIN (SELECT DBID,TABLESPACE_ID,TABLESPACE_USEDSIZE,TABLESPACE_SIZE,TABLESPACE_MAXSIZE FROM DBA_HIST_TBSPC_SPACE_USAGE WHERE SNAP_ID=(SELECT MAX(SNAP_ID) FROM DBA_HIST_TBSPC_SPACE_USAGE))MX
                                                  ON A.DBID=MX.DBID AND A.TABLESPACE_ID=MX.TABLESPACE_ID
                                      INNER JOIN (SELECT DBID,TABLESPACE_ID,TABLESPACE_USEDSIZE,TABLESPACE_SIZE,TABLESPACE_MAXSIZE FROM DBA_HIST_TBSPC_SPACE_USAGE WHERE SNAP_ID=(SELECT MIN(SNAP_ID) FROM DBA_HIST_TBSPC_SPACE_USAGE))MN  
                                                  ON A.DBID=MN.DBID AND A.TABLESPACE_ID=MN.TABLESPACE_ID  
GROUP BY 
     A.DBID
    ,A.TABLESPACE_ID    
    ORDER BY 2,3) CL  
WHERE  CL.TABLESPACE_ID IS NOT NULL 
) CF JOIN DBA_TABLESPACES T ON CF.TS_NAME=T.TABLESPACE_NAME WHERE T.CONTENTS='PERMANENT') FN;