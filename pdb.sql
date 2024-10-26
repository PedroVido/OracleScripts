-- ########################################################################################################
--                                                                                                       --
-- File Name     : pdb.sql                                                                               --
-- Description   : Displays info about pluggable databases.                                              --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @pdb                                                                                  --
-- Last Modified : 07/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

COLUMN pdb_name        FORMAT a30  HEADING NAME
COLUMN pdb_restricted  FORMAT a10   HEADING RESTRICTED

SELECT
     p.con_id,
     p.name pdb_name,
     p.open_mode,
     p.restricted pdb_restricted,
     TO_CHAR(p.open_time, 'dd/mm/yyyy hh24:mi') open_time,
     p.total_size/1024/1024 size_mb,
     p.dbid,
     p.create_scn
FROM v$pdbs p, v$containers c
WHERE c.con_id = p.con_id 
ORDER BY p.con_id;