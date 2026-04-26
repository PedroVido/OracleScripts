-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : asm1.sql                                                                              --
-- Description   : Displays info of ASM Disks.                                                           --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @asm1                                                                                 --
-- Last Modified : 23/10/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

SET LINESIZE 200
SET PAGESIZE 100
COLUMN name FORMAT A25
COLUMN type FORMAT A10
COLUMN total_mb FORMAT 9,999,999,999
COLUMN free_mb FORMAT 999,999,999
COLUMN usable_file_mb FORMAT 999,999,999
COLUMN offline_disks FORMAT 999
COLUMN required_mirror_free_mb FORMAT 999,999,999
COLUMN block_size FORMAT 99999
COLUMN allocation_unit_size FORMAT 999,999,999
COLUMN state FORMAT A10

spool asm_disk_usage.log

PROMPT ===[ Oracle ASM Diskgroup Summary ]===
SELECT name, type, total_mb, free_mb, usable_file_mb, required_mirror_free_mb, offline_disks, state
FROM v$asm_diskgroup
ORDER BY name;

PROMPT ===[ ASM Disk Redundancy and Storage Efficiency ]===
SELECT g.name, g.type, g.allocation_unit_size,
       ROUND((g.total_mb/1024),2) AS total_gb,
       ROUND((g.free_mb/1024),2) AS free_gb,
       ROUND((g.usable_file_mb/1024),2) AS usable_gb,
       g.required_mirror_free_mb,
       (g.total_mb - g.free_mb) AS used_mb,
       ROUND((1 - (g.free_mb/g.total_mb)) * 100, 2) AS used_pct
FROM v$asm_diskgroup g
ORDER BY g.name;


PROMPT ===[ ASM Rebalancing Operations (if any) ]===
SELECT group_number, operation, state, est_work, est_rate, est_minutes
FROM v$asm_operation;

PROMPT ===[ Completed - ASM Disk Analysis Finished! ]===
spool off

