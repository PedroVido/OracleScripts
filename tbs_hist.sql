-- ########################################################################################################
--                                                                                                       --
-- File Name     : tbs_hist.sql                                                                          --
-- Description   : Displays info about tbs usage and growth for Capacity                                 --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ and DBA views.                                                       --
-- Call Syntax   : @tbs_hist                                                                             --
-- Last Modified : 18/03/2025                                                                            --
-- Author        : Adriano Francisco - adfrancisco@accenture.com                                         --
--                                                                                                       --
-- ########################################################################################################

set lines 9999 pages 9999
SELECT 
     FN.TS_NAME 
    ,FN."BEGIN USED GB"
    ,FN."USED GB"
    ,FN."ALLOC GB"
    ,FN."MAX GB"
    ,FN."DIFF_GB"
    ,FN."DAYS"
    ,FN."MAX GB UTIL"
    ,ROUND(CASE WHEN FN."DIFF_GB" > 0 THEN ("MAX GB UTIL" - FN."USED GB") / (FN."DIFF_GB" / FN."DAYS") ELSE NULL END) AS "DAYS UTIL"
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
) CF JOIN DBA_TABLESPACES T ON CF.TS_NAME=T.TABLESPACE_NAME WHERE T.CONTENTS='PERMANENT') FN




--- Outro Script 


-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN owner FORMAT A20
COLUMN object_name FORMAT A40
COLUMN growth_mb FORMAT 999,990.99

SELECT 
    o.owner,
    o.object_name,
	o.OBJECT_TYPE,
	o.TEMPORARY,
    ROUND((end_size - start_size)/1024/1024, 2) AS growth_mb
FROM (
    SELECT 
        obj#,
        MIN(space_allocated_total) AS start_size,
        MAX(space_allocated_total) AS end_size
    FROM 
        dba_hist_seg_stat
    WHERE 
        snap_id BETWEEN (SELECT MAX(snap_id)-168 FROM dba_hist_snapshot)
                    AND (SELECT MAX(snap_id) FROM dba_hist_snapshot)
    GROUP BY 
        obj#
    HAVING 
        MAX(space_allocated_total) > MIN(space_allocated_total)
) growth
JOIN dba_objects o ON growth.obj# = o.object_id
ORDER BY 
    (end_size - start_size) DESC
FETCH FIRST 10 ROWS ONLY;