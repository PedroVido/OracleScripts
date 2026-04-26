-- ########################################################################################################
--                                                                                                       --
-- File Name     : help_active_session_history.sql                                                       --
-- Description   : Displays info about wait events - in time                                             --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access the V$ views.                                                                  --
-- Call Syntax   : @help_active_session_history                                                          --
-- Last Modified : 05/02/2026                                                                            --
-- Author        : Pedro Vido - pedro.carvalho.vido@accenture.com                                        --
--                                                                                                       --
-- ########################################################################################################


--=================================================
--- Top Wait Events Query
--=================================================

-- Current top wait events
SELECT
EVENT,
TOTAL_WAITS,
TIME_WAITED_MICRO/1000000 AS time_waited_sec,
AVERAGE_WAIT/100 AS avg_wait_sec,
WAIT_CLASS
FROM V$SYSTEM_EVENT
WHERE WAIT_CLASS != 'Idle'
ORDER BY TIME_WAITED_MICRO DESC;
--FETCH FIRST 20 ROWS ONLY;

--=================================================
--- db file sequential read
--=================================================

-- Find sessions waiting on db file sequential read
SELECT SID, SERIAL#, USERNAME, SQL_ID, EVENT, P1, P2, P3
FROM V$SESSION
WHERE EVENT = 'db file sequential read';
-- P1=file#, P2=block#, P3=blocks

-- Find hot objects causing waits
SELECT
  o.OWNER,
  o.OBJECT_NAME,
  o.OBJECT_TYPE,
  COUNT(*) AS wait_count
FROM V$ACTIVE_SESSION_HISTORY ash
JOIN DBA_OBJECTS o ON ash.CURRENT_OBJ# = o.OBJECT_ID
WHERE ash.EVENT = 'db file sequential read'
  AND ash.SAMPLE_TIME > SYSDATE - 1/24
GROUP BY o.OWNER, o.OBJECT_NAME, o.OBJECT_TYPE
ORDER BY COUNT(*) DESC;
--FETCH FIRST 10 ROWS ONLY;

--=================================================
--- direct path read/write
--=================================================

-- Parallel queries, temp segments, LOBs

-- Check parallel operations
SELECT
  SID,
  SQL_ID,
  EVENT,
  P1TEXT || '=' || P1 AS detail
FROM V$SESSION
WHERE EVENT LIKE 'direct path%';


--=================================================
--- Log/Commit Wait Events
--=================================================

-- Waiting for redo to write to disk on COMMIT

-- Check log file sync waits
SELECT
  EVENT,
  TOTAL_WAITS,
  AVERAGE_WAIT/100 AS avg_wait_sec
FROM V$SYSTEM_EVENT
WHERE EVENT = 'log file sync';

-- Check log writer performance
SELECT
  NAME,
  VALUE
FROM V$SYSSTAT
WHERE NAME LIKE 'redo%';


--=================================================
--- log buffer space
--=================================================

-- Log buffer too small

-- Check log buffer configuration
SHOW PARAMETER log_buffer;

-- Check log buffer waits
SELECT * FROM V$SYSSTAT WHERE NAME LIKE '%log buffer%';



--=================================================
--- log file switch
--=================================================

-- log file switch (checkpoint incomplete)
-- Log files too small, checkpoint not complete

SELECT GROUP#, STATUS, BYTES/1024/1024 AS size_mb FROM V$LOG;

Resolution: Add more/larger redo log groups, tune checkpoint.



--=================================================
--- Buffer Pool Wait Events
--=================================================

-- Contention on hot blocks

-- Find hot blocks
SELECT
  o.OWNER,
  o.OBJECT_NAME,
  o.OBJECT_TYPE,
  ash.CURRENT_FILE#,
  ash.CURRENT_BLOCK#,
  COUNT(*) AS waits
FROM V$ACTIVE_SESSION_HISTORY ash
JOIN DBA_OBJECTS o ON ash.CURRENT_OBJ# = o.OBJECT_ID
WHERE ash.EVENT = 'buffer busy waits'
  AND ash.SAMPLE_TIME > SYSDATE - 1/24
GROUP BY o.OWNER, o.OBJECT_NAME, o.OBJECT_TYPE, ash.CURRENT_FILE#, ash.CURRENT_BLOCK#
ORDER BY COUNT(*) DESC
FETCH FIRST 10 ROWS ONLY;

Resolution: Reduce contention via partitioning, reverse key indexes, hash partitioning.


--=================================================
--- free buffer waits
--=================================================

-- No free buffers in buffer cache

-- Check buffer cache usage
SELECT
  NAME,
  BLOCK_SIZE,
  CURRENT_SIZE/1024/1024 AS current_mb,
  BUFFERS
FROM V$BUFFER_POOL;

Resolution: Increase buffer cache (DB_CACHE_SIZE), check for inefficient queries.


--=================================================
--- read by other session
--=================================================

-- Block being read by another session

-- Find concurrent block readers
SELECT SID, SERIAL#, EVENT, P1, P2, SQL_ID
FROM V$SESSION
WHERE EVENT = 'read by other session';

Resolution: Usually transient. If persistent, investigate the SQL reading the same blocks.


--=================================================
--- Lock/Enqueue Wait Events
--=================================================

-- enq: TX - row lock contention

-- Find blocking sessions
SELECT
  s1.SID AS blocked_sid,
  s1.USERNAME AS blocked_user,
  s2.SID AS blocking_sid,
  s2.USERNAME AS blocking_user,
  s1.EVENT,
  s1.SQL_ID
FROM V$SESSION s1
JOIN V$SESSION s2 ON s1.BLOCKING_SESSION = s2.SID
WHERE s1.EVENT LIKE 'enq: TX%';

Resolution: Application design, reduce transaction scope, timeout handling.

--=================================================
--- enq: TM - contention
--=================================================

-- Table-level lock (usually DML on unindexed FK)

-- Find missing indexes on foreign keys
SELECT
  c.TABLE_NAME,
  c.CONSTRAINT_NAME,
  cc.COLUMN_NAME
FROM DBA_CONSTRAINTS c
JOIN DBA_CONS_COLUMNS cc ON c.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
WHERE c.CONSTRAINT_TYPE = 'R'
  AND NOT EXISTS (
    SELECT 1 FROM DBA_IND_COLUMNS ic
    WHERE ic.TABLE_NAME = c.TABLE_NAME
      AND ic.COLUMN_NAME = cc.COLUMN_NAME
  );

Resolution: Add indexes on foreign key columns.

--=================================================
--- library cache lock/pin
--=================================================

-- Shared pool contention

-- Check library cache stats
SELECT
  NAMESPACE,
  GETS,
  GETHITS,
  PINS,
  PINHITS,
  INVALIDATIONS
FROM V$LIBRARYCACHE;

Resolution: Reduce hard parsing (use bind variables), increase shared pool.

--=================================================
--- SQL*Net message from client
--=================================================

This is an idle wait. High values indicate application processing time between database calls.


--=================================================
--- SQL*Net message to client
--=================================================

Sending data to client

-- Check network waits
SELECT EVENT, TIME_WAITED_MICRO/1000000 AS secs
FROM V$SESSION_EVENT
WHERE SID = &sid
  AND EVENT LIKE 'SQL*Net%';

Resolution: Network latency, result set size, fetch size.


--=================================================
---SQL*Net more data to client
--=================================================

-- Large result sets

Resolution: Reduce result set size, increase SDU_SIZE.

--=================================================
---Cluster Wait Events (RAC)
--=================================================

--gc buffer busy

-- Check GC waits
SELECT EVENT, TOTAL_WAITS, TIME_WAITED_MICRO/1000000 AS secs
FROM V$SYSTEM_EVENT
WHERE EVENT LIKE 'gc%'
ORDER BY TIME_WAITED_MICRO DESC;

--=================================================
---gc cr/current block receive
--=================================================
Receiving blocks from remote instance

Resolution: Reduce inter-instance traffic, application partitioning.


--=================================================
---Current Session Waits
--=================================================

SELECT
  SID,
  SERIAL#,
  USERNAME,
  STATUS,
  EVENT,
  WAIT_CLASS,
  SECONDS_IN_WAIT,
  STATE,
  SQL_ID
FROM V$SESSION
WHERE USERNAME IS NOT NULL
  AND WAIT_CLASS != 'Idle'
ORDER BY SECONDS_IN_WAIT DESC;

--=================================================
--- Historical Wait Analysis (ASH)
--=================================================

-- Last X hours
SELECT
  EVENT,
  COUNT(*) AS samples,
  ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM V$ACTIVE_SESSION_HISTORY
WHERE SAMPLE_TIME > SYSDATE - 1/24
  AND WAIT_CLASS != 'Idle'
GROUP BY EVENT
ORDER BY COUNT(*) DESC
FETCH FIRST 10 ROWS ONLY;



-- last X minutos
SELECT
  EVENT,
  COUNT(*) AS samples,
  ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM V$ACTIVE_SESSION_HISTORY
WHERE SAMPLE_TIME > SYSDATE - (30/(24*60))
  AND WAIT_CLASS != 'Idle'
GROUP BY EVENT
ORDER BY COUNT(*) DESC
FETCH FIRST 10 ROWS ONLY;




--=================================================
--- Wait Event Resolution Quick Reference
--=================================================

     Wait Event	            |        Likely Cause	         |              Resolution
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -      
db file sequential read	    |  Index lookups, disk I/O	   |     Tune SQL, increase buffer cache
db file scattered read	    |      Full table scans	       |          Add indexes, partition
log file sync	              |      Slow redo writes	       |      Faster storage, batch commits
buffer busy waits	          |         Hot blocks	         |        Partitioning, hash clusters
enq: TX - row lock	        |       Row contention	       |           Application design
library cache lock	        |        Hard parsing	         |             Bind variables
latch: cache buffers chains	|   Buffer chain contention	   |            Reduce logical I/O
cursor: pin S wait on X	    |      Cursor contention	     |           Reduce version count


