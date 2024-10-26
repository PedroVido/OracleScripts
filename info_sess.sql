-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : info_sess.sql                                                                         --
-- Description   : Displays info about sessions                                                          --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @info_sess <STATUS> <inst_id> or 0 for role cluster                                   --
-- Last Modified : 15/08/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

COLUMN username FORMAT A19
COLUMN osuser FORMAT A12 WORD_WRAP TRUNC
COLUMN spid FORMAT A9
COLUMN service_name FORMAT A15
COLUMN machine FORMAT A15 WORD_WRAP TRUNC
COLUMN program FORMAT A10 WORD_WRAP TRUNC
COLUMN SID/SERIAL FORMAT A14
COLUMN LAST_CALL_ET FORMAT A10
COLUMN action FORMAT A24 WORD_WRAP TRUNC
COLUMN module FORMAT A210 WORD_WRAP TRUNC
COLUMN state FORMAT A17 WORD_WRAP TRUNC
COLUMN status FORMAT A12 WORD_WRAP TRUNC
COLUMN resource_consumer_group FORMAT A18 WORD_WRAP TRUNC
COLUMN event FORMAT A10 WORD_WRAP TRUNC
COLUMN sql_id FORMAT a15
COLUMN inst_id FORMAT a9
COLUMN SID_BLOCK FORMAT a10;
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &2 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&2 = 0 or inst_id = &2);
SET termout ON


-- resumo do relatorio
PROMP
PROMP Metrica...: SESSOES &1
PROMP Instance..: &VNODE
PROMP


SELECT NVL(s.username, '(oracle)') AS username,
       --s.osuser,
           s.sid || ',' || s.serial#||',@'||s.inst_id as "SID/SERIAL",
       p.spid,
       s.status,
	   s.event,
       s.machine,
       s.action,
       s.module,
	   s.blocking_session as SID_BLOCK,
--	   s.resource_consumer_group,
	   s.sql_id,
	   logon_time,
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
 --      ,round(p.pga_used_mem/1024/1024,2) as PGA_USED_MEM_MB
FROM   gv$session s,
       gv$process p
WHERE  s.paddr  = p.addr
AND    s.status = '&1'
AND    s.inst_id = p.inst_id
AND   (&2 = 0 or s.inst_id = &2)
AND    s.type not in ('BACKGROUND', 'FOREGROUND')
AND    s.SERVICE_NAME not in('SYS$BACKGROUND')
AND s.sid != (SELECT sid FROM v$mystat WHERE ROWNUM=1)
ORDER BY 11,12 desc;