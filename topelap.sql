-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : topelap.sql                                                                           --
-- Description   : Displays info about queries executions                                                --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ views.                                                              --
-- Call Syntax   : @topelap                                                                              --
-- Last Modified : 09/04/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

SET FEEDBACK OFF
SET SQLFORMAT
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
SET VERIFY OFF
SET PAGES 50
SET LINES 400
SET FEEDBACK ON

col Elapsed_Time   HEADING "(Elapsed Time avg ms)" format 9999,999,999,999,999.99
col executions     HEADING "Execs"                 format 999,999,999,999
col sql_id         HEADING  "SQL Id"               format a20
col sql_fulltext   HEADING  "Text"                 format a50 word_wrap trunc;


SELECT * FROM
(SELECT
    sql_fulltext,
    sql_id,
    elapsed_time,
    child_number,
    disk_reads,
    executions,
    first_load_time,
    last_load_time
FROM    v$sql
ORDER BY elapsed_time DESC)
WHERE ROWNUM < 10
/