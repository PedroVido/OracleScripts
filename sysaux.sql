-- ########################################################################################################
--                                                                                                       --
-- File Name     : sysaux.sql                                                                            --
-- Description   : Displays info about tablaspaces sysaux consumo                                        --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA and V$ views.                                                       --
-- Call Syntax   : @sysaux                                                                               --
-- Last Modified : 10/12/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

col occupant_name for a20
col OCCUPANT_DESC for a50 word_wrap trunc
col schema_name for a15
COL SPACE  HEADING "Consumo em MB" FORMAT 999,999,999,999 

SELECT occupant_name,  
OCCUPANT_DESC,
SCHEMA_NAME,
trunc(space_usage_kbytes/1024/1024,2) as SPACE
FROM V$SYSAUX_OCCUPANTS
WHERE space_usage_kbytes >0
order by 4 desc;