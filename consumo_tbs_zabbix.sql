-- ########################################################################################################
--                                                                                                       --
-- File Name     : consumo_tbs_zabbix.sql                                                                --
-- Description   : Displays info tablaspaces.                                                            --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @consumo_tbs_zabbix                                                                   --
-- Last Modified : 05/07/2024                                                                            --
-- Author        : Accenture - Adriano Francisco                                                         --
--                                                                                                       --
-- ########################################################################################################

SELECT 
   TB.TABLESPACE_NAME AS TABLESPACE,
   TB.CONTENTS AS TYPE,
   ROUND(VL.BYTES_ALLOC) AS BYTES_ALLOC, 
   ROUND(NVL(TBM.USED_SPACE,0) * TB.BLOCK_SIZE) AS USED_BYTES,
   ROUND(VL.MAXBYTES) AS MAX_BYTES,
   ROUND(VL.BYTES_ALLOC-(NVL(TBM.USED_SPACE,0) * TB.BLOCK_SIZE)) AS FREE_BYTES,
   REPLACE(ROUND(NVL(TBM.USED_PERCENT,0),2),',','.') AS USED_PCT,
   DECODE(TB.STATUS, 'ONLINE', 1, 'OFFLINE', 2, 'READ ONLY', 3, 0) AS STATUS,
  (SELECT DECODE(DATABASE_ROLE, 'SNAPSHOT STANDBY', 1, 'LOGICAL STANDBY', 2, 'PHYSICAL STANDBY', 3, 'PRIMARY', 4, 'FAR SYNC', 5, 0) AS ROLE FROM V$DATABASE) AS DATABASE_ROLE,
   DECODE (TB.CONTENTS,'PERMANENT',1,'UNDO',2,'TEMPORARY',3) AS CONTENTS,
   VL.DATCOUNT AS "FILES"
FROM  DBA_TABLESPACES TB           
    LEFT OUTER JOIN DBA_TABLESPACE_USAGE_METRICS TBM  ON TB.TABLESPACE_NAME = TBM.TABLESPACE_NAME
    JOIN 
(SELECT 
                 F.TABLESPACE_NAME AS TABLESPACE,
                 SUM (F.BYTES) BYTES_ALLOC,
                 SUM (DECODE (F.AUTOEXTENSIBLE,'YES', GREATEST(F.MAXBYTES,F.BYTES),'NO', F.BYTES))MAXBYTES,
                 COUNT(1) DATCOUNT
        FROM DBA_DATA_FILES F
        GROUP BY TABLESPACE_NAME
) VL ON TB.TABLESPACE_NAME=VL.TABLESPACE
UNION ALL
SELECT 
     TF.TABLESPACE AS TABLESPACE
    ,TT.CONTENTS AS TYPE
    ,TF."BYTES_ALLOC"
    ,TF."USED_BYTES"
    ,TF."MAX_BYTES"
    ,TF."FREE_BYTES"
    ,TF."USED_PCT"
    ,DECODE(TT.STATUS, 'ONLINE', 1, 'OFFLINE', 2, 'READ ONLY', 3, 0) AS "STATUS"
    ,(SELECT DECODE(DATABASE_ROLE, 'SNAPSHOT STANDBY', 1, 'LOGICAL STANDBY', 2, 'PHYSICAL STANDBY', 3, 'PRIMARY', 4, 'FAR SYNC', 5, 0) AS ROLE FROM V$DATABASE) AS DATABASE_ROLE
    ,DECODE (TT.CONTENTS,'PERMANENT',1,'UNDO',2,'TEMPORARY',3) AS CONTENTS
    ,TF.FILE_QTD AS FILES
FROM     
(SELECT 
         DBA.TABLESPACE_NAME AS      "TABLESPACE",
         (NVL(GVS.TOTAL,0)*DBA.BLOCK_SIZE)  "BYTES_ALLOC",
         (NVL(GVS.USED,0)*DBA.BLOCK_SIZE)   "USED_BYTES",
          DBA.MAX_BYTES              "MAX_BYTES",
         (NVL(GVS.FREE,0)*DBA.BLOCK_SIZE)   "FREE_BYTES",
         REPLACE(ROUND(((NVL(GVS.USED,0)*DBA.BLOCK_SIZE) / DBA.MAX_BYTES)* 100,2),',','.') USED_PCT,
         DBA.DATCOUNT AS FILE_QTD
FROM 
(SELECT 
     G.TABLESPACE_NAME,
     MAX(G.BLOCK_SIZE) BLOCK_SIZE,
     ROUND (SUM (DECODE (F.AUTOEXTENSIBLE,'YES', F.MAXBYTES,'NO', F.BYTES))) MAX_BYTES,
     COUNT(1) AS DATCOUNT     
FROM DBA_TABLESPACES G INNER JOIN DBA_TEMP_FILES F ON F.TABLESPACE_NAME=G.TABLESPACE_NAME
GROUP BY G.TABLESPACE_NAME) DBA LEFT OUTER JOIN 
(SELECT 
    TABLESPACE_NAME,
    NVL(SUM(FREE_BLOCKS),0) FREE,
    NVL(SUM(USED_BLOCKS),0) USED,
    NVL(SUM(TOTAL_BLOCKS),0)TOTAL
FROM GV$SORT_SEGMENT 
GROUP BY TABLESPACE_NAME) GVS ON DBA.TABLESPACE_NAME=GVS.TABLESPACE_NAME)TF INNER JOIN DBA_TABLESPACES TT ON TF.TABLESPACE=TT.TABLESPACE_NAME ORDER BY 1;