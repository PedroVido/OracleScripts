-- ########################################################################################################
--                                                                                                       --
-- File Name     : dbwaitmetric.sql                                                                      --
-- Description   : Displays info about CPU and Wait time                                                 --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access the V$ views.                                                                  --
-- Call Syntax   : @dbwaitmetric                                                                         --
-- Last Modified : 23/10/2025                                                                            --
-- Author        : Pedro Vido - pedro.carvalho.vido@accenture.com                                        --
--                                                                                                       --
-- ########################################################################################################


SELECT METRIC_NAME, VALUE, METRIC_UNIT
FROM V$SYSMETRIC
WHERE METRIC_NAME IN ('Database CPU Time Ratio','Database Wait Time Ratio')
  AND INTSIZE_CSEC = (SELECT MAX(INTSIZE_CSEC) FROM V$SYSMETRIC); 