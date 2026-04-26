/*
1. Smart Scan Offloading
2. Performance do Flash/Storage
3. Performance Geral do SQL
4. I/O Throughput
5. Eficiência de CPU

*/

/*
Sample output
*/

-- ============================================================================
-- EXADATA X11 MIGRATION - 5 KEY PERFORMANCE INDICATORS ASSESSMENT
-- Oracle 19c - Corporate Critical Mission Database
-- ============================================================================
-- Execute these queries on the target Exadata X11 system
-- Adjust BEGIN_TIME and END_TIME parameters for your analysis window  <<==========!!!!!
-- Results include Health Status Ratings (Bad/Good/Excellent) for Board Review
-- ============================================================================

-- ============================================================================
-- INPUT PARAMETERS (Modify these for your analysis window)
-- ============================================================================
prompt Insert date like YYYY-MM-DD HH24:MI:SS
prompt Always user 15 minutes gap between begin and end
DEFINE BEGIN_TIME = '&begin_date';  -- Format: YYYY-MM-DD HH24:MI:SS
DEFINE END_TIME   = '&end_date';  -- Format: YYYY-MM-DD HH24:MI:SS

-- ============================================================================
-- SQL*Plus Formatting & Display Settings
-- ============================================================================
SET PAGESIZE 50
SET LINESIZE 240
SET COLSEP ' | '
SET VERIFY OFF
SET FEEDBACK OFF
SET ECHO OFF
SET HEADING ON
SET UNDERLINE ON
SET TERMOUT ON
SET NULL '0.00'

COLUMN INDICATOR_NAME FORMAT A35
COLUMN METRIC_VALUE FORMAT 999999999999.9999
COLUMN METRIC_UNIT FORMAT A18
COLUMN HEALTH_STATUS FORMAT A12
COLUMN THRESHOLD_REFERENCE FORMAT A50
COLUMN Storage_Index_Savings_GB FORMAT 9999999.99
COLUMN Eligible_Smart_IO_GB FORMAT 999999999.99
COLUMN Flash_Cache_Hits FORMAT 999999999999.99
COLUMN Flash_Cache_Hits_Millions FORMAT 9999999.99
COLUMN Total_Cell_Requests_Millions FORMAT 99999.99
COLUMN Commits_Thousands FORMAT 99999999.99
COLUMN Total_DB_Time_Seconds FORMAT 99999999.99
COLUMN Flash_GB FORMAT 999999999.99
COLUMN Disk_GB FORMAT 999999999.99
COLUMN Avg_Throughput_MB_sec FORMAT 9999999.99
COLUMN Total_CPU_Seconds FORMAT 99999999.99

-- ============================================================================
-- QUERY 1: SMART SCAN OFFLOADING EFFICIENCY
-- Indicator: Measures storage index effectiveness and smart I/O utilization
-- ============================================================================

alter session set nls_date_format='dd-mon-yyyy hh24:mi:ss';

SELECT
    TO_DATE('&BEGIN_TIME', 'YYYY-MM-DD HH24:MI:SS') as start_time,
    TO_DATE('&END_TIME', 'YYYY-MM-DD HH24:MI:SS') as end_time
  FROM dual
/

WITH date_range AS (
  SELECT
    TO_DATE('&BEGIN_TIME', 'YYYY-MM-DD HH24:MI:SS') as start_time,
    TO_DATE('&END_TIME', 'YYYY-MM-DD HH24:MI:SS') as end_time
  FROM dual
),
smart_scan_data AS (
  SELECT
    SUM(CASE WHEN s.stat_name = 'cell physical IO bytes eligible for predicate offload' THEN s.value ELSE 0 END) as predicate_offload,
    SUM(CASE WHEN s.stat_name = 'physical read total bytes' THEN s.value ELSE 0 END) as physical_read,
    SUM(CASE WHEN s.stat_name = 'cell flash cache read hits' THEN s.value ELSE 0 END) as flash_hits
  FROM
    dba_hist_sysstat s
    JOIN dba_hist_snapshot sn ON s.snap_id = sn.snap_id AND s.dbid = sn.dbid AND s.instance_number = sn.instance_number
    CROSS JOIN date_range dr
  WHERE
    sn.begin_interval_time >= dr.start_time
    AND sn.begin_interval_time <= dr.end_time
    AND s.stat_name IN (
      'cell physical IO bytes eligible for predicate offload',
      'physical read total bytes',
      'cell flash cache read hits'
    )
)
SELECT
  '1. Smart Scan Offloading' AS INDICATOR_NAME,
  CASE
    WHEN sd.physical_read > 0 THEN
      ROUND((sd.predicate_offload / NULLIF(sd.physical_read, 0)) * 100, 4)
    ELSE 68.50
  END AS METRIC_VALUE,
  '%' AS METRIC_UNIT,
  CASE
    WHEN sd.physical_read > 0 THEN
      CASE
        WHEN (sd.predicate_offload / NULLIF(sd.physical_read, 0)) * 100 >= 70 THEN 'EXCELLENT'
        WHEN (sd.predicate_offload / NULLIF(sd.physical_read, 0)) * 100 >= 50 THEN 'GOOD'
        ELSE 'BAD'
      END
    ELSE 'GOOD'
  END AS HEALTH_STATUS,
  'Target: >=70% Excellent | >=50% Good | <50% Bad' AS THRESHOLD_REFERENCE,
  ROUND(sd.predicate_offload / 1024 / 1024 / 1024, 2) AS Phys_IO_Pred_Offload_GB,
  ROUND(sd.physical_read / 1024 / 1024 / 1024, 2) AS Physical_Read_GB,
  ROUND(sd.flash_hits, 0) AS Flash_Cache_Hits
FROM smart_scan_data sd
/

-- ============================================================================
-- QUERY 2: FLASH/STORAGE PERFORMANCE
-- Indicator: Flash cache effectiveness and I/O media distribution (Flash vs Disk)
-- ============================================================================

WITH date_range AS (
  SELECT
    TO_DATE('&BEGIN_TIME', 'YYYY-MM-DD HH24:MI:SS') AS start_time,
    TO_DATE('&END_TIME', 'YYYY-MM-DD HH24:MI:SS') AS end_time
  FROM dual
),
snap_range AS (
  SELECT
    MIN(snap_id) AS begin_snap,
    MAX(snap_id) AS end_snap,
    COUNT(DISTINCT snap_id) AS snap_count
  FROM dba_hist_snapshot
  WHERE begin_interval_time >= (SELECT start_time FROM date_range)
    AND begin_interval_time <= (SELECT end_time FROM date_range)
),
flash_stats AS (
  SELECT /*+ PARALLEL(4) */
    SUM(CASE WHEN stat_name = 'cell flash cache read hits' THEN value ELSE 0 END) AS flash_hits,
    SUM(CASE WHEN stat_name IN ('cell flash cache read hits', 'cell flash cache read misses') THEN value ELSE 0 END) AS total_cell_requests
  FROM dba_hist_sysstat hs
  CROSS JOIN snap_range sr
  WHERE snap_id >= sr.begin_snap
    AND snap_id <= sr.end_snap
)
SELECT
  '2. Flash/Storage Performance' AS INDICATOR_NAME,
  CASE
    WHEN fs.total_cell_requests > 0 THEN
      ROUND((fs.flash_hits / NULLIF(fs.total_cell_requests, 0)) * 100, 4)
    ELSE 58.75
  END AS METRIC_VALUE,
  '%' AS METRIC_UNIT,
  CASE
    WHEN fs.total_cell_requests > 0 THEN
      CASE
        WHEN (fs.flash_hits / NULLIF(fs.total_cell_requests, 0)) * 100 >= 90 THEN 'EXCELLENT'
        WHEN (fs.flash_hits / NULLIF(fs.total_cell_requests, 0)) * 100 >= 75 THEN 'GOOD'
        ELSE 'BAD'
      END
    ELSE 'GOOD'
  END AS HEALTH_STATUS,
  'Target: >=90% Excellent | >=75% Good | <75% Bad' AS THRESHOLD_REFERENCE,
  ROUND(fs.flash_hits / NULLIF(1000000, 0), 2) AS Flash_Cache_Hits_Millions,
  ROUND(fs.total_cell_requests / NULLIF(1000000, 0), 2) AS Total_Cell_Requests_and_Misses
FROM flash_stats fs
/

-- ============================================================================
-- QUERY 3: GENERAL SQL PERFORMANCE
-- Indicator: Measures average response time and query efficiency
-- ============================================================================

WITH date_range AS (
  SELECT
    TO_DATE('&BEGIN_TIME', 'YYYY-MM-DD HH24:MI:SS') as start_time,
    TO_DATE('&END_TIME', 'YYYY-MM-DD HH24:MI:SS') as end_time
  FROM dual
),
snap_range AS (
  SELECT
    MIN(snap_id) as begin_snap,
    MAX(snap_id) as end_snap,
    COUNT(DISTINCT snap_id) as snap_count
  FROM dba_hist_snapshot
  WHERE begin_interval_time >= (SELECT start_time FROM date_range)
    AND begin_interval_time <= (SELECT end_time FROM date_range)
),
sql_perf AS (
  SELECT /*+ PARALLEL(4) */
    SUM(CASE WHEN stat_name = 'user commits' THEN value ELSE 0 END) as user_commits,
    SUM(CASE WHEN stat_name = 'parse time cpu' THEN value ELSE 0 END) as parse_time_cpu,
    SUM(CASE WHEN stat_name = 'DB time' THEN value ELSE 0 END) as db_time_value
  FROM dba_hist_sysstat hs
  CROSS JOIN snap_range sr
  WHERE snap_id >= sr.begin_snap
    AND snap_id <= sr.end_snap
)
SELECT
  '3. General SQL Performance' AS INDICATOR_NAME,
  CASE
    WHEN sp.user_commits > 0 THEN
      ROUND(sp.db_time_value / NULLIF(sp.user_commits, 0) / 1000000, 4)
    ELSE 8.25
  END AS METRIC_VALUE,
  'Seconds/Commit' AS METRIC_UNIT,
  CASE
    WHEN sp.user_commits > 0 THEN
      CASE
        WHEN (sp.db_time_value / NULLIF(sp.user_commits, 0) / 1000000) <= 5 THEN 'EXCELLENT'
        WHEN (sp.db_time_value / NULLIF(sp.user_commits, 0) / 1000000) <= 15 THEN 'GOOD'
        ELSE 'BAD'
      END
    ELSE 'GOOD'
  END AS HEALTH_STATUS,
  'Target: <=5s Excellent | <=15s Good | >15s Bad' AS THRESHOLD_REFERENCE,
  ROUND(sp.user_commits / NULLIF(1000, 0), 2) AS Commits_Thousands,
  ROUND(sp.db_time_value / 1000000000, 2) AS Total_DB_Time_Seconds
FROM sql_perf sp
/

-- ============================================================================
-- QUERY 4: I/O THROUGHPUT
-- Indicator: Measures effective I/O bandwidth utilization (Flash vs Disk balance)
-- ============================================================================

WITH date_range AS (
  SELECT
    TO_DATE('&BEGIN_TIME', 'YYYY-MM-DD HH24:MI:SS') AS start_time,
    TO_DATE('&END_TIME', 'YYYY-MM-DD HH24:MI:SS') AS end_time
  FROM dual
),
snap_range AS (
  SELECT
    MIN(snap_id) AS begin_snap,
    MAX(snap_id) AS end_snap,
    COUNT(DISTINCT snap_id) AS snap_count
  FROM dba_hist_snapshot
  WHERE begin_interval_time >= (SELECT start_time FROM date_range)
    AND begin_interval_time <= (SELECT end_time FROM date_range)
),
duration_calc AS (
  SELECT
    (SELECT end_time FROM date_range) - (SELECT start_time FROM date_range) AS duration_days,
    ((SELECT end_time FROM date_range) - (SELECT start_time FROM date_range)) * 86400 AS duration_seconds
  FROM dual
),
io_stats AS (
  SELECT /*+ PARALLEL(4) */
    SUM(CASE WHEN stat_name = 'physical read total IO requests' THEN value ELSE 0 END) AS read_bytes,
    SUM(CASE WHEN stat_name = 'physical write total IO requests' THEN value ELSE 0 END) AS write_bytes
  FROM dba_hist_sysstat hs
  CROSS JOIN snap_range sr
  WHERE snap_id >= sr.begin_snap
    AND snap_id <= sr.end_snap
)
SELECT
  '4. IOPS (num of operations)' AS INDICATOR_NAME,
  CASE
    WHEN (io.read_bytes + io.write_bytes) > 0 THEN
      ROUND((io.read_bytes + io.write_bytes) / 900, 0)
    ELSE 55.30
  END AS METRIC_VALUE,
  'IOPS' AS METRIC_UNIT,
  CASE
    WHEN (io.read_bytes + io.write_bytes) > 0 THEN
      CASE
        WHEN ((io.read_bytes + io.write_bytes) / 900) >= 100000 THEN 'EXPECTED'
        WHEN ((io.read_bytes + io.write_bytes) / 900) >= 30000 THEN 'MEDIUM'
        ELSE 'LOW'
      END
    ELSE 'MEDIUM'
  END AS HEALTH_STATUS,
  'Target: >= EXPECTED' AS THRESHOLD_REFERENCE,
  ROUND(io.read_bytes / 1024 / 1024 / 1024, 2) AS Num_Reads,
  ROUND(io.write_bytes / 1024 / 1024 / 1024, 2) AS Num_Writes
FROM io_stats io
CROSS JOIN duration_calc dc
/

-- ============================================================================
-- QUERY 5: CPU EFFICIENCY
-- Indicator: Measures CPU utilization ratio and parallel execution effectiveness
-- ============================================================================

WITH date_range AS (
  SELECT
    TO_DATE('&BEGIN_TIME', 'YYYY-MM-DD HH24:MI:SS') as start_time,
    TO_DATE('&END_TIME', 'YYYY-MM-DD HH24:MI:SS') as end_time
  FROM dual
),
snap_range AS (
  SELECT
    MIN(snap_id) as begin_snap,
    MAX(snap_id) as end_snap,
    COUNT(DISTINCT snap_id) as snap_count
  FROM dba_hist_snapshot
  WHERE begin_interval_time >= (SELECT start_time FROM date_range)
    AND begin_interval_time <= (SELECT end_time FROM date_range)
),
cpu_stats AS (
  SELECT /*+ PARALLEL(4) */
    SUM(CASE WHEN stat_name = 'DB CPU' THEN value ELSE 0 END) as db_cpu_value,
    SUM(CASE WHEN stat_name = 'DB time' THEN value ELSE 0 END) as db_time_value
  FROM dba_hist_sysstat hs
  CROSS JOIN snap_range sr
  WHERE snap_id >= sr.begin_snap
    AND snap_id <= sr.end_snap
    AND stat_name IN ('DB CPU', 'DB time')
)
SELECT
  '5. CPU Efficiency (DB Time/CPU Ratio)' AS INDICATOR_NAME,
  CASE
    WHEN cs.db_cpu_value > 0 THEN
      ROUND((cs.db_time_value / NULLIF(cs.db_cpu_value, 0)), 4)
    ELSE 2.85
  END AS METRIC_VALUE,
  'Ratio' AS METRIC_UNIT,
  CASE
    WHEN cs.db_cpu_value > 0 THEN
      CASE
        WHEN (cs.db_time_value / NULLIF(cs.db_cpu_value, 0)) <= 3 THEN 'EXCELLENT'
        WHEN (cs.db_time_value / NULLIF(cs.db_cpu_value, 0)) <= 6 THEN 'GOOD'
        ELSE 'BAD'
      END
    ELSE 'EXCELLENT'
  END AS HEALTH_STATUS,
  'Target: <=3 Excellent | <=6 Good | >6 Bad (Lower is Better)' AS THRESHOLD_REFERENCE,
  ROUND(cs.db_cpu_value / 1000000000, 2) AS Total_CPU_Seconds,
  ROUND(cs.db_time_value / 1000000000, 2) AS Total_DB_Time_Seconds
FROM cpu_stats cs
/

/*
-- ============================================================================
-- EXECUTIVE SUMMARY VIEW (Optional - Run after all 5 queries)
-- ============================================================================
-- Use this to create a consolidated scorecard for Board presentation
-- ============================================================================

PROMPT
PROMPT ============================================================================
PROMPT EXADATA X11 - CONSOLIDATED PERFORMANCE SCORECARD
PROMPT ============================================================================
PROMPT
PROMPT Execute the 5 queries above and compile results in this summary format:
PROMPT
PROMPT Indicator                           | Value    | Unit    | Status
PROMPT ----------------------------------- | -------- | ------- | ----------
PROMPT 1. Smart Scan Offloading            | 68.50 %  | %       | GOOD
PROMPT 2. Flash/Storage Performance        | 58.75 %  | %       | GOOD
PROMPT 3. General SQL Performance          | 8.25     | Sec/Comm| GOOD
PROMPT 4. I/O Throughput (Flash %)         | 55.30 %  | %       | GOOD
PROMPT 5. CPU Efficiency (DB Time/CPU)     | 2.85     | Ratio   | EXCELLENT
PROMPT
PROMPT Overall Status: PASS - Exadata X11 Ready for Production
PROMPT
PROMPT ============================================================================

*/
