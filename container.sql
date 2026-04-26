
COLUMN container_name        FORMAT a30 HEADING NAME
COLUMN container_restricted  FORMAT a10 HEADING RESTRICTED

SELECT
     con_id,
     name container_name,
     open_mode,
     restricted container_restricted,
     open_time,
     total_size/1024/1024 size_mb,
     dbid,
     create_scn
FROM v$containers
ORDER BY con_id;

ALTER SESSION SET CONTAINER=DBERPGOP_PDB1;
ALTER PLUGGABLE DATABASE OPEN READ ONLY;
ALTER PLUGGABLE DATABASE DBERPGOP_PDB1 SAVE STATE;
