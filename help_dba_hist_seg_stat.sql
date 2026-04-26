-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : help_dba_hist_seg_stat.sql                                                            --
-- Description   : Displays historical info about segments growth                                        --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @help_dba_hist_seg_stat                                                               --
-- Last Modified : 09/02/2026                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


--=========================================================
-- Why Use DBA_HIST_SEG_STAT for Growth Tracking?
--=========================================================

--> Understanding database growth trends is essential for several critical business functions:
--> Capacity Planning: Predict when you’ll need additional storage based on historical patterns
--> Budget Forecasting: Plan hardware purchases and cloud scaling costs effectively
--> Performance Optimization: Identify objects with rapid growth that may impact performance
--> Compliance Management: Meet regulatory requirements for data retention and storage planning

--==========================================================
-- Understanding DBA_HIST_SEG_STAT Columns
--==========================================================

/*
DBA_HIST_SEG_STAT captures comprehensive information about segments in historical form, including:

Space allocation and utilization (our primary focus for growth analysis)

SPACE_ALLOCATED_TOTAL: Total space allocated to the segment
SPACE_ALLOCATED_DELTA: Change in allocated space since last snapshot
SPACE_USED_TOTAL: Space actually used by data
SPACE_USED_DELTA: Change in used space since last snapshot
Logical reads and physical reads (performance metrics)

LOGICAL_READS_TOTAL: Total logical reads
LOGICAL_READS_DELTA: Change in logical reads
PHYSICAL_READS_TOTAL: Total physical reads
PHYSICAL_READS_DELTA: Change in physical reads
Key identifier columns:

SNAP_ID: Snapshot identifier (join with DBA_HIST_SNAPSHOT)
DBID: Database identifier
INSTANCE_NUMBER: Instance number in RAC environment
OWNER: Schema owner of the segment
OBJECT_NAME: Name of the database object
SUBOBJECT_NAME: Partition name (if applicable)
TABLESPACE_NAME: Tablespace containing the segment
OBJ#: Object number
DATAOBJ#: Data object number
TS#: Tablespace number
*/


--================================================
Issue 1: No Data in DBA_HIST_SEG_STAT
--================================================

Symptom: Query returns 0 rows
Cause: AWR snapshots not configured or retention too short

Fix:

-- SQLPlus formatting
SET LINESIZE 200
COLUMN snap_interval FORMAT A20
COLUMN retention FORMAT A20

-- Check AWR configuration - Nom CDB
SELECT 
    snap_interval,
    retention
FROM 
    dba_hist_wr_control;


-- Check AWR configuration - CDB

set lines 9999 pages 9999
col tablespace_name for a25
col src_dbname for a15
select 
       dbID, 
       con_id, 
       SRC_DBNAME,
       TABLESPACE_NAME,
       SNAP_INTERVAL, 
       RETENTION 
from 
       DBA_HIST_WR_CONTROL;


-- Modify if needed (requires SYSDBA)
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS( -
    retention => 10080,  -- 7 days in minutes -
    interval  => 60      -- 1 hour snapshots -
);

EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval  => 15,retention => 129600); -- Retencao de 90 dias e intervalo de 15 minutos


Verify AWR is enabled:

SELECT 
    dbid,
    snap_id,
    begin_interval_time,
    end_interval_time
FROM 
    dba_hist_snapshot
WHERE 
    begin_interval_time >= SYSDATE - 1
ORDER BY 
    snap_id DESC
FETCH FIRST 10 ROWS ONLY;


--=================================================
-- Issue 2: Growth Data Doesn’t Match Reality
--=================================================

Symptom: DBA_HIST_SEG_STAT shows different sizes than DBA_SEGMENTS
Cause: AWR snapshots are historical, not real-time

Solution:

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN owner FORMAT A20
COLUMN object_name FORMAT A40
COLUMN hist_size_mb FORMAT 999,990.99
COLUMN current_size_mb FORMAT 999,990.99
COLUMN diff_mb FORMAT 999,990.99

SELECT 
    o.owner,
    o.object_name,
    ROUND(h.space_allocated_total/1024/1024, 2) AS hist_size_mb,
    ROUND(s.bytes/1024/1024, 2) AS current_size_mb,
    ROUND((s.bytes - h.space_allocated_total)/1024/1024, 2) AS diff_mb
FROM 
    dba_hist_seg_stat h
    JOIN dba_objects o ON h.obj# = o.object_id
    JOIN dba_segments s ON o.owner = s.owner AND o.object_name = s.segment_name
WHERE 
    h.snap_id = (SELECT MAX(snap_id) FROM dba_hist_snapshot)
    AND ABS(s.bytes - h.space_allocated_total) > 100*1024*1024  -- Diff > 100MB
ORDER BY 
    ABS(s.bytes - h.space_allocated_total) DESC;

Interpretation: Large differences indicate rapid growth between snapshots or manual AWR snapshot timing.

--=================================================
-- Issue 3: Partition Growth Tracking
--=================================================

Problem: Need to track individual partition growth

Solution:

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN owner FORMAT A20
COLUMN table_name FORMAT A30
COLUMN partition_name FORMAT A30
COLUMN growth_mb FORMAT 999,990.99

SELECT 
    o.owner,
    o.object_name AS table_name,
    o.subobject_name AS partition_name,
    ROUND((MAX(h.space_allocated_total) - MIN(h.space_allocated_total))/1024/1024, 2) AS growth_mb
FROM 
    dba_hist_seg_stat h
    JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
    JOIN dba_objects o ON h.obj# = o.object_id AND h.dataobj# = o.data_object_id
WHERE 
    s.begin_interval_time >= SYSDATE - 7
    AND o.subobject_name IS NOT NULL  -- Only partitions
    AND o.owner = 'YOUR_SCHEMA'
GROUP BY 
    o.owner, o.object_name, o.subobject_name
HAVING 
    MAX(h.space_allocated_total) > MIN(h.space_allocated_total)
ORDER BY 
    growth_mb DESC;


--=================================================
-- Issue 4: AWR Retention vs. Analysis Period
--=================================================

Problem: Want to analyze more than retention period allows
Solution: Create a custom tracking table


-- Create tracking table
CREATE TABLE dba_growth_tracking (
    capture_date DATE,
    owner VARCHAR2(128),
    object_name VARCHAR2(128),
    tablespace_name VARCHAR2(30),
    size_bytes NUMBER,
    PRIMARY KEY (capture_date, owner, object_name)
);

-- Populate via scheduled job (run daily)
INSERT INTO dba_growth_tracking
SELECT 
    TRUNC(SYSDATE),
    owner,
    segment_name,
    tablespace_name,
    bytes
FROM 
    dba_segments
WHERE 
    owner NOT IN ('SYS', 'SYSTEM', 'OUTLN', 'DBSNMP');

COMMIT;


Then query historical data:

-- SQLPlus formatting
SET LINESIZE 200
COLUMN owner FORMAT A20
COLUMN object_name FORMAT A40
COLUMN growth_12months_gb FORMAT 999,990.99

SELECT 
    owner,
    object_name,
    ROUND((MAX(size_bytes) - MIN(size_bytes))/1024/1024/1024, 2) AS growth_12months_gb
FROM 
    dba_growth_tracking
WHERE 
    capture_date >= ADD_MONTHS(TRUNC(SYSDATE), -12)
GROUP BY 
    owner, object_name
HAVING 
    MAX(size_bytes) > MIN(size_bytes)
ORDER BY 
    growth_12months_gb DESC
FETCH FIRST 20 ROWS ONLY;

--=================================================
-- Issue 5: High-Frequency Growth Analysis
--=================================================

Problem: Hourly snapshots show too much noise
Solution: Smooth data using moving averages

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN snap_date FORMAT A12
COLUMN raw_growth_mb FORMAT 999,990.99
COLUMN smoothed_growth_mb FORMAT 999,990.99

SELECT 
    TO_CHAR(snap_date, 'YYYY-MM-DD') AS snap_date,
    ROUND(daily_growth/1024/1024, 2) AS raw_growth_mb,
    ROUND(AVG(daily_growth) OVER (ORDER BY snap_date ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING)/1024/1024, 2) AS smoothed_growth_mb
FROM (
    SELECT 
        TRUNC(s.begin_interval_time) AS snap_date,
        SUM(h.space_allocated_delta) AS daily_growth
    FROM 
        dba_hist_seg_stat h
        JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
        JOIN dba_objects o ON h.obj# = o.object_id
    WHERE 
        s.begin_interval_time >= SYSDATE - 30
        AND o.owner = 'YOUR_SCHEMA'
    GROUP BY 
        TRUNC(s.begin_interval_time)
)
ORDER BY 
    snap_date;



--================================================
-- Top 10 Growing Segments (Last 7 Days)
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN owner FORMAT A20
COLUMN object_name FORMAT A40
COLUMN growth_mb FORMAT 999,990.99

SELECT 
    o.owner,
    o.object_name,
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


--================================================
-- Tablespace Growth Trend (Last 30 Days)
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN tablespace_name FORMAT A30
COLUMN growth_gb FORMAT 999,990.99

SELECT 
    ts.name AS tablespace_name,
    ROUND((MAX(h.space_allocated_total) - MIN(h.space_allocated_total))/1024/1024/1024, 2) AS growth_gb
FROM 
    dba_hist_seg_stat h
    JOIN v$tablespace ts ON h.ts# = ts.ts#
    JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
WHERE 
    s.begin_interval_time >= SYSDATE - 30
GROUP BY 
    ts.name
HAVING 
    MAX(h.space_allocated_total) > MIN(h.space_allocated_total)
ORDER BY 
    growth_gb DESC;


--================================================
-- Daily Growth Rate
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN snap_date FORMAT A12
COLUMN daily_growth_mb FORMAT 999,990.99

SELECT 
    TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD') AS snap_date,
    ROUND(SUM(h.space_allocated_delta)/1024/1024, 2) AS daily_growth_mb
FROM 
    dba_hist_seg_stat h
    JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
WHERE 
    s.begin_interval_time >= SYSDATE - 7
GROUP BY 
    TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD')
ORDER BY 
    snap_date;



--================================================
-- Query 1: Object Growth Over Last 30 Days
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN owner FORMAT A20
COLUMN object_name FORMAT A40
COLUMN subobject_name FORMAT A30
COLUMN start_size_mb FORMAT 999,990.99
COLUMN end_size_mb FORMAT 999,990.99
COLUMN growth_mb FORMAT 999,990.99
COLUMN growth_pct FORMAT 990.99

SELECT 
    o.owner,
    o.object_name,
    o.subobject_name,
    ROUND(g.start_size/1024/1024, 2) AS start_size_mb,
    ROUND(g.end_size/1024/1024, 2) AS end_size_mb,
    ROUND((g.end_size - g.start_size)/1024/1024, 2) AS growth_mb,
    ROUND(((g.end_size - g.start_size)/NULLIF(g.start_size, 0)) * 100, 2) AS growth_pct
FROM (
    SELECT 
        obj#,
        dataobj#,
        MIN(space_allocated_total) AS start_size,
        MAX(space_allocated_total) AS end_size
    FROM 
        dba_hist_seg_stat h
        JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
    WHERE 
        s.begin_interval_time >= SYSDATE - 30
    GROUP BY 
        obj#, dataobj#
    HAVING 
        MAX(space_allocated_total) > MIN(space_allocated_total)
) g
JOIN dba_objects o ON g.obj# = o.object_id AND (g.dataobj# = o.data_object_id OR o.data_object_id IS NULL)
ORDER BY 
    (g.end_size - g.start_size) DESC
FETCH FIRST 20 ROWS ONLY;


--What this shows:
Objects that grew the most in last 30 days
Both absolute growth (MB) and percentage growth
Helps identify rapidly growing tables/indexes


--================================================
-- Query 2: Tablespace Growth Trend Analysis
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN tablespace_name FORMAT A30
COLUMN snap_date FORMAT A12
COLUMN size_gb FORMAT 999,990.99
COLUMN growth_gb FORMAT 999,990.99

SELECT 
    tablespace_name,
    TO_CHAR(snap_date, 'YYYY-MM-DD') AS snap_date,
    ROUND(total_size/1024/1024/1024, 2) AS size_gb,
    ROUND((total_size - LAG(total_size) OVER (PARTITION BY tablespace_name ORDER BY snap_date))/1024/1024/1024, 2) AS growth_gb
FROM (
    SELECT 
        ts.name AS tablespace_name,
        TRUNC(s.begin_interval_time) AS snap_date,
        SUM(h.space_allocated_total) AS total_size
    FROM 
        dba_hist_seg_stat h
        JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
        JOIN v$tablespace ts ON h.ts# = ts.ts#
    WHERE 
        s.begin_interval_time >= SYSDATE - 30
    GROUP BY 
        ts.name,
        TRUNC(s.begin_interval_time)
)
ORDER BY 
    tablespace_name, snap_date;

--What this shows:
Daily tablespace growth patterns
Growth trends over 30 days
Helps predict when tablespace will need expansion


--================================================
--Query 3: Schema-Level Growth Summary
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN owner FORMAT A30
COLUMN total_objects FORMAT 999,999
COLUMN total_size_gb FORMAT 999,990.99
COLUMN growth_gb FORMAT 999,990.99
COLUMN avg_daily_growth_mb FORMAT 999,990.99

SELECT 
    owner,
    COUNT(DISTINCT obj#) AS total_objects,
    ROUND(MAX(total_size)/1024/1024/1024, 2) AS total_size_gb,
    ROUND((MAX(total_size) - MIN(total_size))/1024/1024/1024, 2) AS growth_gb,
    ROUND((MAX(total_size) - MIN(total_size))/1024/1024/30, 2) AS avg_daily_growth_mb
FROM (
    SELECT 
        o.owner,
        h.obj#,
        h.snap_id,
        SUM(h.space_allocated_total) OVER (PARTITION BY o.owner, h.snap_id) AS total_size
    FROM 
        dba_hist_seg_stat h
        JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
        JOIN dba_objects o ON h.obj# = o.object_id
    WHERE 
        s.begin_interval_time >= SYSDATE - 30
)
GROUP BY 
    owner
HAVING 
    MAX(total_size) > MIN(total_size)
ORDER BY 
    growth_gb DESC;


--What this shows:
Growth by schema/owner
Average daily growth rate
Useful for multi-tenant or schema-per-application architectures


--================================================
-- Query 4: Growth Rate Per Day (Detailed)
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN owner FORMAT A20
COLUMN object_name FORMAT A40
COLUMN mb_per_day FORMAT 999,990.99
COLUMN snapshots_analyzed FORMAT 999

SELECT 
    o.owner,
    o.object_name,
    ROUND((MAX(h.space_allocated_total) - MIN(h.space_allocated_total))/1024/1024/30, 2) AS mb_per_day,
    COUNT(DISTINCT h.snap_id) AS snapshots_analyzed
FROM 
    dba_hist_seg_stat h
    JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
    JOIN dba_objects o ON h.obj# = o.object_id
WHERE 
    s.begin_interval_time >= SYSDATE - 30
GROUP BY 
    o.owner, o.object_name
HAVING 
    MAX(h.space_allocated_total) > MIN(h.space_allocated_total)
ORDER BY 
    mb_per_day DESC
FETCH FIRST 10 ROWS ONLY;

--What this shows:
Which objects are growing fastest per day
Number of snapshots included in calculation
Helps identify objects needing immediate attention


--================================================
-- Predicting Storage Needs
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN tablespace_name FORMAT A30
COLUMN current_size_gb FORMAT 999,990.99
COLUMN growth_rate_gb_month FORMAT 999,990.99
COLUMN projected_90days_gb FORMAT 999,990.99
COLUMN projected_180days_gb FORMAT 999,990.99

SELECT 
    tablespace_name,
    ROUND(current_size/1024/1024/1024, 2) AS current_size_gb,
    ROUND(growth_rate/1024/1024/1024, 2) AS growth_rate_gb_month,
    ROUND((current_size + (growth_rate * 3))/1024/1024/1024, 2) AS projected_90days_gb,
    ROUND((current_size + (growth_rate * 6))/1024/1024/1024, 2) AS projected_180days_gb
FROM (
    SELECT 
        ts.name AS tablespace_name,
        MAX(h.space_allocated_total) AS current_size,
        (MAX(h.space_allocated_total) - MIN(h.space_allocated_total)) / 
            NULLIF(MONTHS_BETWEEN(MAX(s.begin_interval_time), MIN(s.begin_interval_time)), 0) AS growth_rate
    FROM 
        dba_hist_seg_stat h
        JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
        JOIN v$tablespace ts ON h.ts# = ts.ts#
    WHERE 
        s.begin_interval_time >= SYSDATE - 90
    GROUP BY 
        ts.name
)
WHERE 
    growth_rate > 0
ORDER BY 
    growth_rate DESC;

--Use this for:
Storage capacity planning
Budget forecasting
Hardware procurement decisions


--================================================
-- Identifying Growth Anomalies
--================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN owner FORMAT A20
COLUMN object_name FORMAT A40
COLUMN snap_date FORMAT A12
COLUMN daily_growth_mb FORMAT 999,990.99
COLUMN avg_growth_mb FORMAT 999,990.99
COLUMN deviation FORMAT 999,990.99

WITH daily_growth AS (
    SELECT 
        o.owner,
        o.object_name,
        TRUNC(s.begin_interval_time) AS snap_date,
        SUM(h.space_allocated_delta)/1024/1024 AS daily_growth_mb
    FROM 
        dba_hist_seg_stat h
        JOIN dba_hist_snapshot s ON h.snap_id = s.snap_id
        JOIN dba_objects o ON h.obj# = o.object_id
    WHERE 
        s.begin_interval_time >= SYSDATE - 30
    GROUP BY 
        o.owner, o.object_name, TRUNC(s.begin_interval_time)
),
growth_stats AS (
    SELECT 
        owner,
        object_name,
        snap_date,
        daily_growth_mb,
        AVG(daily_growth_mb) OVER (PARTITION BY owner, object_name) AS avg_growth_mb,
        STDDEV(daily_growth_mb) OVER (PARTITION BY owner, object_name) AS stddev_growth
    FROM 
        daily_growth
)
SELECT 
    owner,
    object_name,
    TO_CHAR(snap_date, 'YYYY-MM-DD') AS snap_date,
    ROUND(daily_growth_mb, 2) AS daily_growth_mb,
    ROUND(avg_growth_mb, 2) AS avg_growth_mb,
    ROUND(ABS(daily_growth_mb - avg_growth_mb), 2) AS deviation
FROM 
    growth_stats
WHERE 
    ABS(daily_growth_mb - avg_growth_mb) > (2 * stddev_growth)
    AND stddev_growth > 0
ORDER BY 
    deviation DESC;

--Use this to identify:
Unusual growth spikes
Data load issues
Potential runaway processes


--=============================================================================
-- Combining with Other Oracle Views
--=============================================================================

--===================================================
-- DBA_HIST_SEG_STAT + DBA_HIST_TBSPC_SPACE_USAGE
--===================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN tablespace_name FORMAT A30
COLUMN snap_date FORMAT A12
COLUMN used_gb FORMAT 999,990.99
COLUMN segment_growth_gb FORMAT 999,990.99

SELECT 
    ts.name AS tablespace_name,
    TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD') AS snap_date,
    ROUND(t.tablespace_usedsize * dt.block_size / 1024 / 1024 / 1024, 2) AS used_gb,
    ROUND(SUM(h.space_allocated_delta)/1024/1024/1024, 2) AS segment_growth_gb
FROM 
    dba_hist_tbspc_space_usage t
    JOIN dba_hist_snapshot s ON t.snap_id = s.snap_id
    JOIN v$tablespace ts ON t.tablespace_id = ts.ts#
    JOIN dba_tablespaces dt ON ts.name = dt.tablespace_name
    LEFT JOIN dba_hist_seg_stat h ON h.snap_id = t.snap_id AND h.ts# = t.tablespace_id
WHERE 
    s.begin_interval_time >= SYSDATE - 7
GROUP BY 
    ts.name,
    TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD'),
    t.tablespace_usedsize,
    dt.block_size
ORDER BY 
    ts.name, snap_date;


--===================================================    
-- DBA_HIST_SEG_STAT + DBA_HIST_SQLSTAT
--===================================================

Find which SQL is causing object growth:

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN sql_id FORMAT A13
COLUMN owner FORMAT A20
COLUMN object_name FORMAT A40
COLUMN executions FORMAT 999,999,999
COLUMN growth_mb FORMAT 999,990.99

SELECT 
    sq.sql_id,
    o.owner,
    o.object_name,
    SUM(sq.executions_delta) AS executions,
    ROUND(SUM(h.space_allocated_delta)/1024/1024, 2) AS growth_mb
FROM 
    dba_hist_sqlstat sq
    JOIN dba_hist_seg_stat h ON sq.snap_id = h.snap_id
    JOIN dba_objects o ON h.obj# = o.object_id
WHERE 
    sq.snap_id >= (SELECT MIN(snap_id) 
                  FROM dba_hist_snapshot 
                  WHERE begin_interval_time >= SYSDATE - 7)
    AND sq.executions_delta > 0
    AND h.space_allocated_delta > 0
GROUP BY 
    sq.sql_id, o.owner, o.object_name
ORDER BY 
    growth_mb DESC
FETCH FIRST 10 ROWS ONLY;
