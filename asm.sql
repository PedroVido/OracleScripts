-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : asm.sql                                                                               --
-- Description   : Displays info of ASM Diskgroups.                                                      --
-- Comments      : Taking count Redundance of disks -> (Line 25)                                         --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @asm                                                                                  --
-- Last Modified : 07/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################
set lines 9999
set pages 9999
SET SQLFORMAT
COL NAME HEADING "Disksgroup"
COL TYPE HEADING "Redundancy"
COL TOTAL_GB HEADING "Total GB" FORMAT 999,999,999,999  
COL FREE_GB  HEADING "Free GB"  FORMAT 999,999,999,999 
COL PERCFREE HEADING "Free %"   FORMAT 999.99 

SELECT NAME, TYPE, TOTAL_GB, FREE_GB, ROUND(FREE_GB/TOTAL_GB*100,2) AS PERCFREE
FROM (
	SELECT NAME, 
	       TYPE,
		   ( TOTAL_MB / DECODE(TYPE,'HIGH',3,'NORMAL',2,1) ) / 1024 AS TOTAL_GB, 
		   USABLE_FILE_MB/1024 AS FREE_GB
	FROM V$ASM_DISKGROUP
);


--

SET SQLFORMAT
COL NAME HEADING "Disksgroup"
COL TYPE HEADING "Redundancy"
COL total_mb HEADING "Total MB" FORMAT 999,999,999,999  
COL free_mb  HEADING "Free MB"  FORMAT 999,999,999,999 
COL required_mirror_free_mb  HEADING "Required MB"  FORMAT 999,999,999,999 
COL usable_file_mb  HEADING "Usable MB"  FORMAT 999,999,999,999
COL PERCFREE HEADING "Free %"   FORMAT 999.99 
COL OFFLINE_DISKS HEADING "Offline Disks "  FORMAT 999

SELECT group_number, NAME, TYPE, REDUN_COPIES, TOTAL_MB, FREE_MB,required_mirror_free_mb, usable_file_mb, OFFLINE_DISKS, ROUND(FREE_MB/TOTAL_MB*100,2) AS PERCFREE
FROM (
SELECT group_number, name, type,
DECODE(TYPE,'HIGH',3,'NORMAL',2,1) AS REDUN_COPIES,  
TOTAL_MB / DECODE(TYPE,'HIGH',3,'NORMAL',2,1) AS TOTAL_MB, 
free_mb / DECODE(TYPE,'HIGH',3,'NORMAL',2,1) AS free_mb,
required_mirror_free_mb, usable_file_mb, OFFLINE_DISKS FROM v$asm_diskgroup ORDER BY name
);