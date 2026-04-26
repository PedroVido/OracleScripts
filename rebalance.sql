-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : rebalance.sql                                                                         --
-- Description   : Displays info about disk rebalance operations.                                        --
-- Comments      : First query show de name of disks, base on 1 change the name on 2                     --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @rebalance                                                                            --
-- Last Modified : 24/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################
set lines 400
set pages 50
col name format a10
SELECT GROUP_NUMBER as "Group#", NAME FROM V$ASM_DISKGROUP;
SELECT O.GROUP_NUMBER as "Group#",case when o.group_number = 1 then 'DATAC1' else 'RECOC1' end as NAME,
       O.INST_ID,
       O.OPERATION,
       O.PASS,
           O.STATE,
           O.POWER,
           O.ACTUAL,
           O.SOFAR,
           O.EST_WORK,
           ROUND(SOFAR/greatest(EST_WORK,1)*100,2) "% Done", EST_RATE,
           O.EST_MINUTES,
       ROUND(O.EST_MINUTES/60,2) AS EST_HOURS
FROM GV$ASM_OPERATION O
WHERE EST_WORK >=0
ORDER BY GROUP_NUMBER;

col path format a40
col name format a30
col failgroup format a30
set linesize 200
select group_number, name from v$asm_diskgroup;
select inst_id,group_number,failgroup,mount_status,count(*) from gv$asm_disk
group by inst_id,group_number,failgroup,mount_status;
select inst_id,group_number,failgroup,mode_status,count(*) from gv$asm_disk
group by inst_id,group_number,failgroup,mode_status; 

--=================================================
-- Comandos para alterar power limit do rebalance
--=================================================

-- OBS: Descomentar apenas no caso de uso e alterar os valores com ATENCAO

--alter system set asm_power_limit=30;
--alter diskgroup DATAC1 rebalance power 20;