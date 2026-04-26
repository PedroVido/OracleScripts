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
WHERE segment_name IN ('TB_BF_CLIENTE_CARTAO')
AND   owner = 'USR_MS_UFINANCIAL'
ORDER BY size_gb DESC;   
/