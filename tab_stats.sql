-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : tab_stats.sql                                                                         --
-- Description   : Displays info about table                                                             --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @tab_stats (schema-name) (table-name)                                                 --
-- Last Modified : 15/07/2022                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

SET LINESIZE 300 VERIFY OFF

COLUMN owner FORMAT A20
COLUMN table_name FORMAT A30
COLUMN index_name FORMAT A30

SELECT owner,
       table_name,
       num_rows,
       blocks,
       empty_blocks,
       avg_space
       chain_cnt,
       avg_row_len,
       last_analyzed
FROM   dba_tables
WHERE  owner      = UPPER('&1')
AND    table_name = UPPER('&2');

SELECT index_name,
       blevel,
       leaf_blocks,
       distinct_keys,
       avg_leaf_blocks_per_key,
       avg_data_blocks_per_key,
       clustering_factor,
       num_rows,
       last_analyzed
FROM   dba_indexes
WHERE  table_owner = UPPER('&1')
AND    table_name  = UPPER('&2')
ORDER BY index_name;

COLUMN column_name FORMAT A30
COLUMN low_value FORMAT A40
COLUMN high_value FORMAT A40
COLUMN endpoint_actual_value FORMAT A30

SELECT column_id,
       column_name,
       num_distinct,
       avg_col_len,
       histogram,
       low_value,
       high_value
FROM   dba_tab_columns
WHERE  owner       = UPPER('&1')
AND    table_name  = UPPER('&2')
ORDER BY column_id;
prompt

SET VERIFY ON