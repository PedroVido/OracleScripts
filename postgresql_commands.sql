

-- How to identify the long-running queries?

SELECT
  userid :: regrole,
  dbid,
  mean_exec_time / 1000 as mean_exec_time_secs,
  max_exec_time / 1000 as max_exec_time_secs,
  min_exec_time / 1000 as min_exec_time_secs,
  stddev_exec_time,
  calls,
  query
from
  pg_stat_statements
order by
  mean_exec_time DESC limit 3;

-- How to identify I/O-intensive queries?

SELECT 
  mean_exec_time / 1000 as mean_exec_time_secs, 
  calls, 
  rows, 
  shared_blks_hit, 
  shared_blks_read, 
  shared_blks_hit /(shared_blks_hit + shared_blks_read):: NUMERIC * 100 as hit_ratio, 
  (blk_read_time + blk_write_time)/calls as average_io_time_ms, 
  query 
FROM 
  pg_stat_statements 
where 
  shared_blks_hit > 0 
ORDER BY 
  (blk_read_time + blk_write_time)/calls DESC;


-- How to identify tables with the highest frequency of sequential scans ?

SELECT 
  schemaname, 
  relname, 
  Seq_scan, 
  idx_scan seq_tup_read, 
  seq_tup_read / seq_scan as avg_seq_read 
FROM 
  pg_stat_all_tables 
WHERE 
  seq_scan > 0 AND schemaname not in (‘pg_catalog’,’information_schema’) 
ORDER BY 
  Avg_seq_read DESC LIMIT 3;


-- How to identify infrequently accessed tables?

SELECT
  schemaname,
  relname,
  seq_scan,
  idx_scan,
  (COALESCE(seq_scan, 0) + COALESCE(idx_scan, 0)) as
total_scans_performed
FROM
  pg_stat_all_tables
WHERE
  (COALESCE(seq_scan, 0) + COALESCE(idx_scan, 0)) < 10
AND schemaname not in (‘pg_catalog’, ‘information_schema’)
ORDER BY
  5 DESC;


-- Finding long-running queries by time

SELECT 
  datname AS database_name, 
  usename AS user_name, 
  application_name, 
  client_addr AS client_address, 
  client_hostname, 
  query AS current_query, 
  state, 
  query_start, 
  now() - query_start AS query_duration 
FROM 
  pg_stat_activity 
WHERE 
  state = 'active' AND now() - query_start > INTERVAL '10 sec' 
ORDER BY 
  query_start DESC;


-- View Performance 

EXPLAIN <query> ;

EXPLAIN ANLYZE <query> ;


-- Using pg_stat_statements - The pg_stat_statements view provides detailed information about query performance, including execution time and frequency.

SELECT round((100 * total_time / sum(total_time) over ())::numeric, 2) percent,
round(total_time::numeric, 2) as total,
calls,
round(mean_time::numeric, 2) as mean,
stddev_time,
substring(query, 1, 40) as query
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;


-- Running VACUUM and ANALYZE commands helps maintain performance by reclaiming storage space and updating statistics.

VACUUM ANALYZE users;