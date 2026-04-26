set lines 9999 
set pages 9999 
set verify off
col value for a10;
prompt *  Info tables  *
ACCEPT b PROMPT "Enter table_name: "
ACCEPT c PROMPT "Enter owner_name: "

set heading off;
set feedback off;
prompt
prompt
select '-----------------------------------------------------' from dual;
select '   DESC  - &c - &b  ' from dual;
select '-----------------------------------------------------' from dual;
prompt
prompt    
set heading on;
set feedback on;

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
WHERE  owner      = UPPER('&&c')
AND    table_name = UPPER('&&b');

set heading off;
set feedback off;
prompt
prompt
select '-----------------------------------------------------' from dual;
select '   SIZE  - &&c - &&b  ' from dual;
select '-----------------------------------------------------' from dual;
prompt
prompt    
set heading on;
set feedback on;

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off
COLUMN tabela           FORMAT a25            HEAD 'segment Name'
COLUMN own              FORMAT a35            HEAD 'Schema|Name'
COLUMN tipo             FORMAT a10            HEAD 'Object|Type'
COLUMN tab              FORMAT a17            HEAD 'Tablespace|Name'
COLUMN size_gb          FORMAT 9999.99        HEAD 'Size GB'

break on report on schema_name skip 1
compute sum label "Grand Total: " of size_gb  on report
   
SELECT
     segment_name                     tabela
    ,owner                            own
    ,segment_type                     tipo
    ,tablespace_name                  tabs
    ,trunc(bytes/1024/1024/1024,2)    size_gb
FROM  dba_segments
WHERE segment_name IN ('&&b')
AND   owner = '&&c'
ORDER BY size_gb DESC;   



set heading off;
set feedback off;
prompt
prompt
select '-----------------------------------------------------' from dual;
select '   INDEX - &&c - &&b  ' from dual;
select '-----------------------------------------------------' from dual;
prompt
prompt    
set heading on;
set feedback on; 

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
WHERE  table_owner = UPPER('&&c')
AND    table_name  = UPPER('&&b')
ORDER BY index_name;


select index_owner, 
       index_name, 
       table_owner, 
       table_name, 
       column_name 
from   dba_ind_columns
where table_owner = UPPER('&&c')
AND   table_name  = UPPER('&&b');