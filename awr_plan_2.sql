-- ########################################################################################################
--                                                                                                       --
-- File Name     : awr_plan_2.sql                                                                        --
-- Description   : Display Execution plan from AWR.                                                      --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ views.                                                              --
-- Call Syntax   : @awr_plan_2 <SQL_ID>                                                                  --
--               : @awr_plan_2 <SQL_ID> <plan_hash_value>                                                --
--               : @awr_plan_2 <SQL_ID> <%>                                                              --
-- Last Modified : 05/07/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

/*
*
*  Purpose    : Display Execution plan from AWR
*  Parameters : 1 - SQL_ID
*             : 2 - PLAN_HASH_VALUE (Use % for ALL)
*/

SET verify OFF

VARIABLE sql_id VARCHAR2(13)
VARIABLE plan_hash_value VARCHAR2(20)
variable dbid       number;
BEGIN
   SELECT DISTINCT dbid
              INTO :dbid
              FROM v$database;
END;
/


BEGIN
   :sql_id := '&&1';
   :plan_hash_value := '%';
   IF :plan_hash_value = '' OR :plan_hash_value IS NULL THEN
      :plan_hash_value := '0';
   END IF;
   IF :plan_hash_value = '%' THEN
              :plan_hash_value := NULL;
   END IF;
END;
/

PROMPT
PROMPT #################################################################
PROMPT #       A L L    S Q L     P L A N   H A S H   V A L U E
PROMPT #################################################################

COLUMN sql_id               HEADING "SQL_ID"                 FORMAT a13
COLUMN plan_hash_value      HEADING "PLAN_HASH_VALUE"        FORMAT 9999999999999999
COLUMN cost                 HEADING "Cost"                   FORMAT 9999999999
COLUMN last_used            HEADING "Last_Used"               FORMAT a20
COLUMN first_used           HEADING "First_Used"              FORMAT a20
COLUMN first_parsed         HEADING "First_Parsed"            FORMAT a20
set lin 1000

SELECT p.sql_id
     , p.plan_hash_value
     , p.cost
     , to_char(MAX(s.end_interval_time) ,'DD-MON-YY HH24:MI:SS') last_used
     , to_char(MIN(s.end_interval_time) ,'DD-MON-YY HH24:MI:SS') first_used
     , to_char(MIN(p.timestamp) ,'DD-MON-YY HH24:MI:SS')         first_parsed
  FROM v$database d
            , dba_hist_sql_plan p
     , dba_hist_sqlstat ss
            , dba_hist_snapshot s
 WHERE d.dbid = p.dbid
   AND p.dbid = ss.dbid (+)
   AND p.sql_id = ss.sql_id (+)
   AND p.plan_hash_value = ss.plan_hash_value
   AND ss.dbid = s.dbid (+)
   AND ss.instance_number = s.instance_number (+)
   AND ss.snap_id = s.snap_id (+)
   AND p.id = 0 -- Top row which has cost as well
   AND p.sql_id = :sql_id
GROUP BY p.sql_id
       , p.plan_hash_value
       , p.cost
ORDER BY MAX(s.end_interval_time) ASC
/


DEF sql_id = '&&1';
PRO
WITH
p AS (
SELECT plan_hash_value
  FROM gv$sql_plan
 WHERE sql_id = TRIM('&&1')
   AND other_xml IS NOT NULL
 UNION
SELECT plan_hash_value
  FROM dba_hist_sql_plan
 WHERE sql_id = TRIM('&&1')
   AND other_xml IS NOT NULL ),
m AS (
SELECT plan_hash_value,
       SUM(elapsed_time)/SUM(executions) avg_et_secs
  FROM gv$sql
 WHERE sql_id = TRIM('&&1')
   AND executions > 0
 GROUP BY
       plan_hash_value ),
a AS (
SELECT plan_hash_value,
       SUM(elapsed_time_total)/SUM(executions_total) avg_et_secs
  FROM dba_hist_sqlstat
 WHERE sql_id = TRIM('&&1')
   AND executions_total > 0
 GROUP BY
       plan_hash_value )
SELECT p.plan_hash_value,
       ROUND(NVL(m.avg_et_secs, a.avg_et_secs)/1e6, 3) avg_et_secs
  FROM p, m, a
 WHERE p.plan_hash_value = m.plan_hash_value(+)
   AND p.plan_hash_value = a.plan_hash_value(+)
 ORDER BY
       avg_et_secs NULLS LAST;
