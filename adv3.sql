-- ########################################################################################################
--                                                                                                       --
-- File Name     : adv3.sql                                                                              --
-- Description   : Displays Recomendation for PGA and SGA ideal size.                                    --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @adv3                                                                                 --
-- Last Modified : 12/11/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################



PROMP ******************************* PGA Recomendation ******************************************************

COLUMN finding_time      FOR a20    HEAD 'Finding Time'
COLUMN current_target_mb FOR 999,999 HEAD 'Current SGA|Target (MB)'
COLUMN advised_target_mb FOR 999,999 HEAD 'Advised SGA|Target (MB)'

BREAK ON REPORT
COMPUTE maximum LABEL 'Recommended Min. PGA' OF advised_target_mb ON report

SELECT TO_CHAR( al.execution_start, 'dd Mon yyyy HH24:MI:SS') AS finding_time,
       aa.num_attr1/1048576 AS current_target_mb,
       aa.num_attr2/1048576 AS advised_target_mb
  FROM dba_advisor_actions  aa,
       dba_advisor_findings af,
       dba_advisor_log      al
 WHERE 1=1
   AND al.owner          = af.owner
   AND al.task_name      = af.task_name
   AND aa.owner          = af.owner
   AND aa.task_name      = af.task_name
   AND aa.execution_name = af.execution_name
   AND af.finding_name   = 'Undersized PGA'
   AND aa.attr1          = 'pga_aggregate_target'
 ORDER
    BY al.execution_start
;

PROMP ******************************* SGA Recomendation ******************************************************

COLUMN finding_time      FOR a20    HEAD 'Finding Time'
COLUMN current_target_mb FOR 999,999 HEAD 'Current SGA|Target (MB)'
COLUMN advised_target_mb FOR 999,999 HEAD 'Advised SGA|Target (MB)'

BREAK ON REPORT
COMPUTE maximum LABEL 'Recommended Min. SGA' OF advised_target_mb ON report

SELECT TO_CHAR( al.execution_start, 'dd Mon yyyy HH24:MI:SS') AS finding_time,
       aa.num_attr1/1048576 AS current_target_mb,
       aa.num_attr2/1048576 AS advised_target_mb
  FROM dba_advisor_actions  aa,
       dba_advisor_findings af,
       dba_advisor_log      al
 WHERE 1=1
   AND al.owner          = af.owner
   AND al.task_name      = af.task_name
   AND aa.owner          = af.owner
   AND aa.task_name      = af.task_name
   AND aa.execution_name = af.execution_name
   AND af.finding_name   = 'Undersized SGA'
   AND aa.attr1          = 'sga_target'
 ORDER
    BY al.execution_start
;