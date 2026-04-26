-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : fragmentation.sql                                                                     --
-- Description   : Displays info about objects fragmentation                                             --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ and DBA views.                                                      --
-- Call Syntax   : N/A                                                                                   --
-- Last Modified : 0514/08/2025                                                                          --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


-- ===========================================
-- Find objects in tbs file 

COL OWNER FOR A20;
COL SEGMENT_NAME FOR A40;
SELECT SEGMENT_NAME,OWNER, SEGMENT_TYPE, TABLESPACE_NAME, trunc(BYTES/1024/1024/1024,2) as BYTES_GB, BLOCKS
FROM DBA_SEGMENTS
WHERE HEADER_FILE = 299;

-- ==========================================
--   Table size GB

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off
COLUMN tabela           FORMAT a25            HEAD 'segment Name'
COLUMN own              FORMAT a20            HEAD 'Schema|Name'
COLUMN tipo             FORMAT a10            HEAD 'Object|Type'
COLUMN tab              FORMAT a17            HEAD 'Tablespace|Name'
COLUMN size_gb          FORMAT 9999.99        HEAD 'Size GB'

break on report on schema_name skip 1
compute sum label "Grand Total: " of size_gb  on report
   
SELECT
     segment_name                     tabela
    ,owner                            own
    ,segment_type                     tipo
    ,tablespace_name                  tabs
    ,trunc(bytes/1024/1024/1024,2)    size_gb
FROM  dba_segments
WHERE segment_name IN ( 'LABOR_MSG_DTL','ORDER_LINE_ITEM' )
AND   owner = 'RDARCH17GRU'
ORDER BY size_gb DESC;     
/



-- ==========================================
--      Find objects fragmented

--> QUERY 1
COL TOTAL_SIZE       FOR 999,999,990  HEADING 'Total size|GB'
COL ACTUAL_SIZE      FOR 999,999,990  HEADING 'Atual size|GB'
COL FRAGMENTED_SPACE FOR 999,999,990  HEADING 'Fra Size|GB'
COL TABLE_NAME       FOR A30          HEADING 'Table|Name'
COL OWNER            FOR A30          HEADING 'Table|Owner'
COL TABLESPACE_NAME  FOR A30          HEADING 'Tablespace|Name'
COL AVG_ROW_LEN      FOR A20          HEADING 'AVG Row|Lengh'
COL PERCENTAGE       FOR 990          HEADING 'PCT |Fra %'

SELECT 
TABLE_NAME,
OWNER,
TABLESPACE_NAME,
AVG_ROW_LEN,
TOTAL_SIZE,
ACTUAL_SIZE,
FRAGMENTED_SPACE,
PERCENTAGE
 FROM (
        SELECT
        table_name,
		owner,
		TABLESPACE_NAME,
        avg_row_len,
        ROUND(((blocks*8/1024/1024)),2) AS "TOTAL_SIZE",
        ROUND((num_rows*avg_row_len/1024/1024/1024),2) AS "ACTUAL_SIZE",
        ROUND(((blocks*8/1024/1024) - (num_rows*avg_row_len/1024/1024/1024)),2) AS "FRAGMENTED_SPACE",
        (ROUND(((blocks*8/1024/1024) - (num_rows*avg_row_len/1024/1024/1024)),2) / ROUND(((blocks*8/1024/1024)),2)) * 100 AS "PERCENTAGE"
        FROM all_tables
        WHERE ROUND(((blocks*8/1024/1024)),2) > 0
ORDER BY 7 desc
)
WHERE ROWNUM <=20;

Table                          Table                          Tablespace                                  AVG Row   Total size   Atual size     Fra Size   PCT
Name                           Owner                          Name                                          Lengh           GB           GB           GB Fra %
------------------------------ ------------------------------ ------------------------------ -------------------- ------------ ------------ ------------ -----
LABOR_MSG_DTL                  RDARCH17GRU                    ARCHIVE_DT_TBS                                  146          298          208           90    30
ORDER_LINE_ITEM                RDARCH17GRU                    ARCHIVE_DT_TBS                                  262          180          103           77    43
TRAN_LOG_RESPONSE_MESSAGE      RDWMS17GRU                     LEMA_LGTXN_DT_TBS                              3975           62            8           55    87
PKT_DTL                        RDARCH17GRU                    ARCHIVE_DT_TBS                                  274          157          105           52    33
TRAN_LOG_MESSAGE               RDWMS17GRU                     LEMA_LGTXN_DT_TBS                              3985           56            8           48    86
PROD_TRKG_TRAN                 RDARCH17GRU                    ARCHIVE_DT_TBS                                  230          197          164           33    17
TASK_DTL                       RDARCH17GRU                    ARCHIVE_DT_TBS                                  292          206          174           32    16
OUTPT_ORDER_LINE_ITEM          RDARCH17GRU                    ARCHIVE_DT_TBS                                  200           99           69           30    30
MSG_LOG                        RDARCH17GRU                    ARCHIVE_DT_TBS                                  224          168          140           28    17
TRAN_LOG_MESSAGE               RDMIF17GRU                     IFW_DT_TBS                                     3342           56           27           28    51
OUTPT_ORDER_LINE_ITEM          RDWMS17GRU                     LLMDATA                                         193           77           49           28    36
LPN_DETAIL                     RDWMS17GRU                     CBO_TXN8K_DT_TBS                                162           54           29           25    47
BATCH_HIST_SHIP                RDARCH17GRU                    ARCHIVE_DT_TBS                                  129           82           57           25    30
PKT_DTL                        RDWMS17GRU                     LLMDATA                                         263           61           37           25    40
ORDER_LINE_ITEM                RDWMS17GRU                     CBO_TXORLN_DT_TBS                               263           63           38           24    39
LPN_DETAIL                     RDARCH17GRU                    ARCHIVE_DT_TBS                                  181          132          107           24    19
OUTPT_LPN_DETAIL               RDARCH17GRU                    ARCHIVE_DT_TBS                                  144           84           60           24    28
OUTPT_LPN_DETAIL               RDWMS17GRU                     LLMDATA                                         132           55           36           19    35
PROD_TRKG_TRAN                 RDWMS17GRU                     LLMDATA                                         229           36           18           18    50
ALLOC_INVN_DTL                 RDWMS17GRU                     LLMDATA                                         236           53           36           17    33

20 rows selected.

SYS@dbwmpdgr_dg>





--> QUERY 2 
COL SIZE_MB          FOR 999,999,990  HEADING 'Total size|MB'
COL ACTUAL_SIZE_MB   FOR 999,999,990  HEADING 'Atual size|MB'
COL WASTED_SPACE_MB  FOR 999,999,990  HEADING 'Fra Size|MB'
COL TABLE_NAME       FOR A30          HEADING 'Table|Name'
COL OWNER            FOR A30          HEADING 'Table|Owner'
COL TABLESPACE_NAME  FOR A30          HEADING 'Tablespace|Name'
COL RECLAIMABLE_SPACE_PCT       FOR 990          HEADING 'PCT |Fra %'


select
TABLE_NAME,
OWNER,
TABLESPACE_NAME,
round(SIZE_KB/1024,2) as SIZE_MB,
round(ACTUAL_DATA_KB/1024,2) as ACTUAL_SIZE_MB,
round(WASTED_SPACE_KB/1024,2) as WASTED_SPACE_MB,
RECLAIMABLE_SPACE_PCT
from 
(
select OWNER,
       TABLE_NAME,
	   TABLESPACE_NAME,
	   round((blocks*8),2) "SIZE_KB" ,
       round((num_rows*avg_row_len/1024),2) "ACTUAL_DATA_KB",
       (round((blocks*8),2) - round((num_rows*avg_row_len/1024),2)) "WASTED_SPACE_KB", 
	   ((round((blocks * 8), 2) - round((num_rows * avg_row_len / 1024), 2)) / round((blocks * 8), 2)) * 100 - 10 "RECLAIMABLE_SPACE_PCT"
from dba_tables
where Tablespace_name in ('LEMA_LGTXN_DT_TBS') 
  and (round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
order by 6 desc 
) 
where rownum < 25;


Table                          Table                          Tablespace                       Total size   Atual size     Fra Size   PCT
Name                           Owner                          Name                                     MB           MB           MB Fra %
------------------------------ ------------------------------ ------------------------------ ------------ ------------ ------------ -----
TRAN_LOG_RESPONSE_MESSAGE      RDWMS17GRU                     LEMA_LGTXN_DT_TBS                    63,981        8,112       55,869    77
TRAN_LOG_MESSAGE               RDWMS17GRU                     LEMA_LGTXN_DT_TBS                    56,903        8,161       48,742    76
TRAN_LOG                       RDWMS17GRU                     LEMA_LGTXN_DT_TBS                       465            5          460    89
SECURITY_PARAM                 RDMDA17GRU                     LEMA_LGTXN_DT_TBS                        19           14            4    14
XTILE                          RDWMS17GRU                     LEMA_LGTXN_DT_TBS                         6            4            2    24
SECURITY_POLICY_GROUP          RDMDA17GRU                     LEMA_LGTXN_DT_TBS                         3            2            1    35
RESOURCES                      RDWMS17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    30
UIB_QUERY_DETAILS              RDMDA17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    20
CL_SERVER_CONFIG               RDWMS17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    90
CL_MACHINE_XREF                RDWMS17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    89
UIB_SP_DETAILS                 RDMDA17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    87
USER_GROUP_USERS               RDMDA17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    90
RESOURCES                      RDMDA17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    29
XTILE                          RDMDA17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    78
LICENSE                        RDMDA17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    87
OAUTH_CLIENT_DETAILS           RDWMS17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    85
OAUTH_CLIENT_DETAILS           RDMDA17GRU                     LEMA_LGTXN_DT_TBS                         0            0            0    85

17 rows selected.

SYS@dbwmpdgr_dg>



-- ======================================================
-- Find inserts with append


-- Append clouse prevent oracle to use empyt spaces between data, this generates fragmentation

col sql_text for a100 word_wrap trunc;

select distinct 
sql_id, 
sql_text
from gv$sql
where sql_text like 'INSERT%';

desc v$sql




























--================================================
-- automate fragmentation

-- Define the schema and table names to check
DECLARE
    v_schema_name   VARCHAR2(30) := 'RDARCH17GRU';  -- Replace with your schema name
    v_table_name    VARCHAR2(30) := 'LABOR_MSG_DTL'; -- Replace with your table name
--    v_index_name    VARCHAR2(30) := 'YOUR_INDEX_NAME'; -- Replace with your index name
BEGIN
    -- Analyze table fragmentation
    DBMS_OUTPUT.PUT_LINE('Analyzing Table Fragmentation...');
    FOR rec IN (
        SELECT table_name, 
               num_rows, 
               blocks, 
               empty_blocks, 
               avg_row_len
          FROM dba_tables
         WHERE owner = v_schema_name
           AND table_name = v_table_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Table: ' || rec.table_name);
        DBMS_OUTPUT.PUT_LINE('Rows: ' || rec.num_rows);
        DBMS_OUTPUT.PUT_LINE('Blocks: ' || rec.blocks);
        DBMS_OUTPUT.PUT_LINE('Empty Blocks: ' || rec.empty_blocks);
        DBMS_OUTPUT.PUT_LINE('Average Row Length: ' || rec.avg_row_len);
    END LOOP;

-- Analyze index fragmentation
--    DBMS_OUTPUT.PUT_LINE('Analyzing Index Fragmentation...');
--    FOR rec IN (
--        SELECT index_name,
--               table_name,
--               NUM_ROWS,
--               LEAF_BLOCKS,
--               DISTINCT_KEYS,
--               AVG_LEAF_BLOCKS
--          FROM dba_indexes
--         WHERE owner = v_schema_name
--           AND index_name = v_index_name
--    ) LOOP
--        DBMS_OUTPUT.PUT_LINE('Index: ' || rec.index_name);
--        DBMS_OUTPUT.PUT_LINE('Table: ' || rec.table_name);
--        DBMS_OUTPUT.PUT_LINE('Rows: ' || rec.NUM_ROWS);
--        DBMS_OUTPUT.PUT_LINE('Leaf Blocks: ' || rec.LEAF_BLOCKS);
--        DBMS_OUTPUT.PUT_LINE('Distinct Keys: ' || rec.DISTINCT_KEYS);
--        DBMS_OUTPUT.PUT_LINE('Average Leaf Blocks: ' || rec.AVG_LEAF_BLOCKS);
--    END LOOP;
END;
/