-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : s_user.sql                                                                            --
-- Description   : Displays info about user sessions                                                     --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ views.                                                              --
-- Call Syntax   : @s_user <username> <STATUS> <INST_ID>                                                 --
-- Last Modified : 05/07/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

COLUMN username FORMAT A20
COLUMN osuser FORMAT A12 WORD_WRAP TRUNC
COLUMN spid FORMAT A9
COLUMN service_name FORMAT A15
COLUMN machine FORMAT A15 WORD_WRAP TRUNC
COLUMN program FORMAT A10 WORD_WRAP TRUNC
COLUMN SID/SERIAL FORMAT A14
COLUMN LAST_CALL_ET FORMAT A16
COLUMN action FORMAT A24 WORD_WRAP TRUNC
COLUMN module FORMAT A20 WORD_WRAP TRUNC
COLUMN state FORMAT A17 WORD_WRAP TRUNC
COLUMN status FORMAT A12 WORD_WRAP TRUNC
COLUMN resource_consumer_group FORMAT A18 WORD_WRAP TRUNC
COLUMN event FORMAT A10 WORD_WRAP TRUNC
COLUMN sql_id FORMAT a15
COLUM client_info FORMAT a25
SELECT s.inst_id,
       s.sid||','||s.serial#||',@'||s.inst_id as "SID/SERIAL",
       NVL(s.username, '(oracle)') AS username,
	   s.osuser,
	   s.client_info,
	   s.module,
	   s.sql_id,
       s.status,
       s.machine,
	   s.logon_time,
       TRUNC(last_call_et / (60 * 60 * 24)) || 'D ' ||
           TRUNC(MOD(last_call_et / (60 * 60 * 24),
                     TRUNC(last_call_et / (60 * 60 * 24))) * 24) || 'H ' ||
           TRUNC(MOD((MOD(last_call_et / (60 * 60 * 24),
                          TRUNC(last_call_et / (60 * 60 * 24))) * 24),
                     TRUNC(MOD(last_call_et / (60 * 60 * 24),
                               TRUNC(last_call_et / (60 * 60 * 24))) * 24)) * 60) || 'M ' ||
           TRUNC(MOD((MOD((MOD(last_call_et / (60 * 60 * 24),
                               TRUNC(last_call_et / (60 * 60 * 24))) * 24),
                          TRUNC(MOD(last_call_et / (60 * 60 * 24),
                                    TRUNC(last_call_et / (60 * 60 * 24))) * 24)) * 60),
                     (TRUNC(MOD((MOD(last_call_et / (60 * 60 * 24),
                                     TRUNC(last_call_et / (60 * 60 * 24))) * 24),
                                TRUNC(MOD(last_call_et / (60 * 60 * 24),
                                          TRUNC(last_call_et / (60 * 60 * 24))) * 24)) * 60))) * 60) || 'S ' AS LAST_CALL_ET
FROM   gv$session s,
       gv$process p
WHERE  s.paddr  = p.addr
AND    s.inst_id = p.inst_id
AND    s.username ='&1'
AND    s.STATUS = '&2'
AND    S.inst_id = '&3'
AND s.sid != (SELECT sid FROM v$mystat WHERE ROWNUM=1)
order by 1,7,8 desc;


