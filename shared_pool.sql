--==========================================
-- Shared Pool - Total
--==========================================

SELECT pool, sum(bytes)/1024/1024/1024 AS "Size (GB)" FROM v$sgastat WHERE pool = 'shared pool' GROUP BY pool;

--==========================================
-- Shared Pool - Free
--==========================================

SELECT INST_ID,
POOL,
NAME,
round(BYTES / 1024 / 1024,2) AS "SPACE MB"
FROM gv$sgastat
WHERE NAME = 'free memory'
AND POOL = 'shared pool'
ORDER BY INST_ID;

--==========================================
-- Shared Pool Size Factor
--==========================================

SELECT shared_pool_size_for_estimate AS "Size of Shared Pool in MB",
shared_pool_size_factor AS "Size Factor",
estd_lc_time_saved AS "Time Saved in sec"
FROM v$shared_pool_advice;

--=========================================
-- Shared Pool Consumidores
--=========================================

set lines 9999
set pages 9999

col sql_id for a15
col "Memory (GB)" for 999,999,999,990
Col executions fro a10
Col sql_text for a40 word_wrap trunc


SELECT sql_id,
inst_id,
round(sharable_mem / 1024 /1024,2) AS "Memory (MB)",
executions,
sql_text
FROM gv$sql
ORDER BY 2,3 DESC
FETCH FIRST 30 ROWS ONLY;

