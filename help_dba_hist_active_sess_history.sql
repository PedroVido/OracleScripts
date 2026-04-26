
-- ########################################################################################################
--                                                                                                       --
-- File Name     : help_dba_hist_active_sess_history.sql                                                 --
-- Description   : Displays info about wait events - in time                                             --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access the DBA views.                                                                 --
-- Call Syntax   : @help_dba_hist_active_sess_history                                                    --
-- Last Modified : 05/02/2026                                                                            --
-- Author        : Pedro Vido - pedro.carvalho.vido@accenture.com                                        --
--                                                                                                       --
-- ########################################################################################################


--=================================================
--- Wait Event Resolution Quick Reference
--=================================================

/*
     Wait Event	            |        Likely Cause	       |              Resolution
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      
db file sequential read	    |  Index lookups, disk I/O	   |     Tune SQL, increase buffer cache
db file scattered read	    |      Full table scans	       |          Add indexes, partition
log file sync	            |      Slow redo writes	       |      Faster storage, batch commits
buffer busy waits	        |         Hot blocks	       |        Partitioning, hash clusters
enq: TX - row lock	        |       Row contention	       |           Application design
library cache lock	        |        Hard parsing	       |             Bind variables
latch: cache buffers chains	|   Buffer chain contention	   |            Reduce logical I/O
cursor: pin S wait on X	    |      Cursor contention	   |           Reduce version count
*/

-- > Uso: 
         --> Analisar um periodo passado
         --> Analisar eventos no momento do pico
         --> Analisar top sql_ids ofensores
         --> Analisar top bloqueadores
         --> Analisar top sessions comsumindo CPU
         --> Analisar consumo por aplication (Program)
         --> Analisar quantidade de sessoes ativa em um periodo


--===================================================================
-- Ocurrencies of Events in last X Hours - DBA_HIST_ACTIVE
--===================================================================

-- Analisar causa raiz, crises retroativas

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN wait_class FORMAT A15
COLUMN event FORMAT A40
COLUMN samples FORMAT 999,999
COLUMN pct_of_total FORMAT 990.99
COLUMN avg_wait_time_ms FORMAT 999,999,990.99

SELECT 
    wait_class,
    event,
    COUNT(*) AS samples,
	MIN(sample_time) AS first_seen,
    MAX(sample_time) AS last_seen,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS pct_of_total,
    ROUND(AVG(time_waited), 2) AS avg_wait_time_ms
FROM 
    dba_hist_active_sess_history
WHERE 
    sample_time BETWEEN TO_DATE('2026-02-05 22:38:00','YYYY-MM-DD HH24:MI:SS')
                    AND TO_DATE('2026-02-06 00:38:00','YYYY-MM-DD HH24:MI:SS')
    AND session_state = 'WAITING'
    AND wait_class != 'Idle'
GROUP BY 
    wait_class, event
ORDER BY 
    samples DESC
FETCH FIRST 15 ROWS ONLY;

--===================================================================
-- Ocurrencies of sql_id in last X Hours - DBA_HIST_ACTIVE
--===================================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN sql_id FORMAT A13
COLUMN sample_count FORMAT 999,999
COLUMN db_time_minutes FORMAT 999,990.99
COLUMN operation FORMAT A15
COLUMN top_wait_event FORMAT A30

SELECT 
    sql_id,
	MAX(sql_opname) AS operation,
	ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS pct_of_total,
    COUNT(*) AS sample_count,
    ROUND(COUNT(*) * 10 / 60, 2) AS db_time_minutes,
	NVL(wait_class, 'CPU') WAIT_CLASS,
    MAX(event) keep (dense_rank first order by event) AS top_wait_event
FROM 
    dba_hist_active_sess_history
WHERE 
    sample_time BETWEEN TO_DATE('2026-02-05 22:38:00','YYYY-MM-DD HH24:MI:SS')
                    AND TO_DATE('2026-02-06 00:38:00','YYYY-MM-DD HH24:MI:SS')
    AND sql_id IS NOT NULL
GROUP BY 
    sql_id,WAIT_CLASS
ORDER BY 
    sample_count DESC
FETCH FIRST 15 ROWS ONLY;


--===================================================================
-- Session Activity Over Time - DBA_HIST_ACTIVE
--===================================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN hour FORMAT A15
COLUMN active_sessions FORMAT 999
COLUMN total_samples FORMAT 999,999
COLUMN avg_active_sessions_per_minute FORMAT 990.99
COLUMN cpu_samples FORMAT 999,999
COLUMN wait_samples FORMAT 999,999

SELECT 
    TO_CHAR(sample_time, 'YYYY-MM-DD HH24') AS hour,
    COUNT(DISTINCT session_id) AS active_sessions,
    COUNT(*) AS total_samples,
    ROUND(COUNT(*) / 360, 2) AS avg_active_sessions_per_minute,
    SUM(CASE WHEN session_state = 'ON CPU' THEN 1 ELSE 0 END) AS cpu_samples,
    SUM(CASE WHEN session_state = 'WAITING' THEN 1 ELSE 0 END) AS wait_samples
FROM 
    dba_hist_active_sess_history
WHERE 
    sample_time BETWEEN TO_DATE('2026-02-05 22:38:00','YYYY-MM-DD HH24:MI:SS')
                    AND TO_DATE('2026-02-06 00:38:00','YYYY-MM-DD HH24:MI:SS')
GROUP BY 
    TO_CHAR(sample_time, 'YYYY-MM-DD HH24')
ORDER BY 
    hour;


--> Interpretation:

    -- colunm "active_sessions", show total of active sessions
    -- colunm "avg_active_sessions_per_minute", show session activer per minute during the hour
    -- More wait samples than CPU samples (potential bottleneck)



--===================================================================
-- Application Module Analysis - DBA_HIST_ACTIVE
--===================================================================

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN application_module FORMAT A50
COLUMN unique_sessions FORMAT 999
COLUMN total_samples FORMAT 999,999
COLUMN db_hours FORMAT 999,990.99
COLUMN avg_wait_ms FORMAT 999,999,999,990.99

SELECT 
    NVL(module, 'Unknown') AS application_module,
    COUNT(DISTINCT session_id) AS unique_sessions,
    COUNT(*) AS total_samples,
    ROUND(COUNT(*) * 10 / 3600, 2) AS db_hours,
    ROUND(AVG(CASE WHEN session_state = 'WAITING' 
                   THEN time_waited END), 2) AS avg_wait_ms
FROM 
    dba_hist_active_sess_history
WHERE 
    sample_time BETWEEN TO_DATE('2026-02-05 22:38:00','YYYY-MM-DD HH24:MI:SS')
                    AND TO_DATE('2026-02-06 00:38:00','YYYY-MM-DD HH24:MI:SS')
    AND session_type = 'FOREGROUND'
GROUP BY 
    module
ORDER BY 
    total_samples DESC
FETCH FIRST 30 ROWS ONLY;



--===================================================================
-- CPU Intensive Sessions - DBA_HIST_ACTIVE
--===================================================================

-- Problem: “Which sessions were consuming the most CPU during business hours?”

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN session_id FORMAT 999999
COLUMN session_serial# FORMAT 999999
COLUMN program FORMAT A50
COLUMN module FORMAT A25
COLUMN sql_id FORMAT A13
COLUMN cpu_samples FORMAT 999,999
COLUMN pct_cpu_time FORMAT 990.99

SELECT 
    session_id,
    session_serial#,
    program,
    module,
    sql_id,
    COUNT(*) AS cpu_samples,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS pct_cpu_time
FROM 
    dba_hist_active_sess_history
WHERE 
    sample_time BETWEEN TO_DATE('2026-02-05 13:38:00','YYYY-MM-DD HH24:MI:SS')
                    AND TO_DATE('2026-02-06 00:38:00','YYYY-MM-DD HH24:MI:SS')
    AND session_state = 'ON CPU'
    AND session_type = 'FOREGROUND'
GROUP BY 
    session_id, session_serial#, program, module, sql_id
HAVING 
--    COUNT(*) >= 180  -- At least 30 minutes on CPU
--    COUNT(*) >= 150  -- At least 25 minutes on CPU
--    COUNT(*) >= 120  -- At least 20 minutes on CPU
--    COUNT(*) >= 90  -- At least 15 minutes on CPU
--    COUNT(*) >= 60  -- At least 10 minutes on CPU
	COUNT(*) >= 30  -- At least 5 minutes on CPU
ORDER BY 
    cpu_samples DESC
FETCH FIRST 10 ROWS ONLY;

-- > 1 sample is equal 10 Seconds
-- > 1 minute has 6 samples 
-- > 6 samples * 30 minutes = 180 samples


--===================================================================
-- Identify Blocking Sessions - DBA_HIST_ACTIVE
--===================================================================

-- Problem: “Were there blocking sessions causing slowness last night?”

-- SQLPlus formatting
SET LINESIZE 200
SET PAGESIZE 50
COLUMN sample_time FORMAT A20
COLUMN blocker_sid FORMAT 999,999
COLUMN blocked_session_count FORMAT 999
COLUMN total_blocked_samples FORMAT 999,999
COLUMN blocked_time_minutes FORMAT 999,990.99
COLUMN blocker_sql FORMAT A13

SELECT 
    TO_CHAR(sample_time, 'YYYY-MM-DD HH24:MI:SS') AS sample_time,
    blocking_session AS blocker_sid,
    COUNT(DISTINCT session_id) AS blocked_session_count,
    COUNT(*) AS total_blocked_samples,
    ROUND(COUNT(*) * 10 / 60, 2) AS blocked_time_minutes,
    MAX(sql_id) keep (dense_rank first order by sql_id) AS blocker_sql
FROM 
    dba_hist_active_sess_history
WHERE 
    sample_time >= TRUNC(SYSDATE) - 1  -- Last 24 hours
--	    sample_time BETWEEN TO_DATE('2026-02-05 13:38:00','YYYY-MM-DD HH24:MI:SS')
--                      AND TO_DATE('2026-02-06 00:38:00','YYYY-MM-DD HH24:MI:SS')
    AND blocking_session IS NOT NULL
    AND blocking_session_status = 'VALID'
GROUP BY 
    TO_CHAR(sample_time, 'YYYY-MM-DD HH24:MI:SS'),
    blocking_session
HAVING 
    COUNT(*) >= 30  -- Blocked for at least 5 minutes
ORDER BY 
    total_blocked_samples DESC;