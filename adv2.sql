PROMP ******************************* SGA Advisor ******************************************************
SET LINES 400
SET PAGES 100
COL INST_ID FORMAT 99
COL SGA_SIZE                HEADING "SGA Size (GB)" FORMAT 999,999,999,999,999
COL SGA_SIZE_FACTOR         FORMAT 999.99
COL ESTD_DB_TIME            FORMAT 999,999,999,999,999
COL ESTD_DB_TIME_FACTOR     FORMAT 999.99
COL ESTD_PHYSICAL_READS     FORMAT 999,999,999,999,999
COL ESTD_BUFFER_CACHE_SIZE  HEADING "Buffer Cache (GB)" FORMAT 999,999,999,999,999
COL ESTD_SHARED_POOL_SIZE   heading "Shared Pool (GB)"  FORMAT 999,999,999,999,999
COL CON_ID                  FORMAT 999,999,999,999,999
SELECT INST_ID,
SGA_SIZE/1024 AS SGA_SIZE,
SGA_SIZE_FACTOR,
ESTD_DB_TIME,
ESTD_DB_TIME_FACTOR,
ESTD_PHYSICAL_READS
--ESTD_BUFFER_CACHE_SIZE/1024 AS ESTD_BUFFER_CACHE_SIZE,
--ESTD_SHARED_POOL_SIZE/1024 AS ESTD_SHARED_POOL_SIZE
--CON_ID
FROM GV$SGA_TARGET_ADVICE
ORDER BY 1,3;

PROMP ******************************* Buffer Cache Advisor **********************************************
SET PAGES 100
COLUMN inst_id                    FORMAT 999
COLUMN block_size                 FORMAT a10 heading 'Block Size'
COLUMN size_for_estimate          FORMAT 999,999,999,999 heading 'Cache Size (GB)'
COLUMN buffers_for_estimate       FORMAT 999,999,999 heading 'Buffers'
COLUMN estd_physical_read_factor  FORMAT 999.99 heading 'Estd Phys|Read Factor'
COLUMN estd_physical_reads        FORMAT 999,999,999,999,999 heading 'Estd Phys| Reads'
SELECT inst_id,
       block_size/1024 || 'k' as block_size, 
       size_factor,
       size_for_estimate/1024 as size_for_estimate, 	   
	   buffers_for_estimate, 
	   estd_physical_read_factor, 
	   estd_physical_reads
 FROM GV$DB_CACHE_ADVICE
WHERE name = 'DEFAULT'
  AND advice_status = 'ON';
  
PROMP ******************************* PGA Advisor ******************************************************
SET LINES 400
SET PAGES 50
COL INST_ID FORMAT 99
COL PGA_GBYTES FORMAT 999,999,999,999,999
COL PGA_TARGET_FACTOR FORMAT 999.99
COL ADVICE_STATUS FORMAT A5
COL MB_PROCESSED FORMAT 999,999,999,999,999
COL ESTD_TIME FORMAT 999,999,999,999,999
COL ESTD_EXTRA_MB_RW FORMAT 999,999,999,999,999
COL ESTD_PGA_CACHE_HIT_PERCENTAGE FORMAT 999.99
COL ESTD_OVERALLOC_COUNT FORMAT 999,999,999,999,999
SELECT INST_ID, PGA_TARGET_FOR_ESTIMATE/1024/1024/1024 AS PGA_GBYTES
      ,PGA_TARGET_FACTOR
      ,ADVICE_STATUS
      ,BYTES_PROCESSED/1024/1024 AS MB_PROCESSED
      ,ESTD_TIME
      ,ESTD_EXTRA_BYTES_RW/1024/1024 AS ESTD_EXTRA_MB_RW
      ,ESTD_PGA_CACHE_HIT_PERCENTAGE
      ,ESTD_OVERALLOC_COUNT
FROM GV$PGA_TARGET_ADVICE
ORDER BY 1,3;
