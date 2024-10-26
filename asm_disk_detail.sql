-- ########################################################################################################
--                                                                                                       --
-- File Name     : asm_disk_detail.sql                                                                   --
-- Description   : Displays info about diskgroups.                                                       --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @asm_disk_detail                                                                      --
-- Last Modified : 30/07/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

set lines 255
col path for a40
col Diskgroup for a15
col DiskName for a20
col disk# for 999
col header_status for a15
col total_mb for 999,999,999
col free_mb for 999,999,999
col mount_status for a14;
compute sum of total_mb on DiskGroup
compute sum of free_mb on DiskGroup
break on DiskGroup skip 1 on report
set pages 255
select a.name DiskGroup, b.disk_number Disk#, b.name DiskName, b.MOUNT_STATUS,b.MODE_STATUS,b.MOUNT_DATE,b.PATH, b.os_mb,b.total_mb, b.free_mb, b.path, b.header_status
from v$asm_disk b, v$asm_diskgroup a
where a.group_number (+) =b.group_number
order by b.group_number, b.path, b.disk_number, b.name;


--set lines 255
--col path for a40
--col Diskgroup for a15
--col DiskName for a20
--col disk# for 999
--col header_status for a15
--col total_mb for 999,999,999
--col free_mb for 999,999,999
--compute sum of total_mb on DiskGroup
--compute sum of free_mb on DiskGroup
--break on DiskGroup skip 1 on report
--set pages 255
--select a.name DiskGroup, b.disk_number Disk#, b.name DiskName, b.os_mb,b.total_mb, b.free_mb, b.path, b.header_status
--from v$asm_disk b, v$asm_diskgroup a
--where a.group_number (+) =b.group_number
--order by b.group_number, b.path, b.disk_number, b.name;