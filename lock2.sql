-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : lockx.sql                                                                             --
-- Description   : Displays info about locks                                                             --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the GV$ views.                                                              --
-- Call Syntax   : @lockx                                                                                --
-- Last Modified : 05/07/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


SET LINES 400
SET PAGES 50
COL sess FORMAT A20
COL serial# FORMAT A20
COL status FORMAT A12
COL MACHINE FORMAT A20 TRUNC
COL LOCKED_OBJECT FORMAT A30
COL USERNAME FORMAT A15
COL SQL_ADDRESS FORMAT A20
COL SQL_ID FORMAT A18
SELECT DECODE(request, 0, 'Holder: ', 'Waiter: ') || gv$lock.sid sess,
       gv$session.sid,
       gv$session.serial#,
       gv$session.status,
       gv$lock.INST_ID,
       gv$session.sql_id,
       --gv$session.username,
       --substr(machine,1,instr(machine,'.')-1) as machine,
       do.object_name as locked_object,
       id1,
       id2,
       lmode,
       request,
       gv$lock.type,gv$session.sql_address,
gv$session.sid,gv$session.inst_id,gv$session.sql_hash_value,gv$session.sql_id
  FROM gv$lock
  join gv$session
    on gv$lock.sid = gv$session.sid
   and gv$lock.inst_id = gv$session.inst_id
  join gv$locked_object lo
    on gv$lock.SID = lo.SESSION_ID
   and gv$lock.inst_id = lo.inst_id
  join dba_objects do
    on lo.OBJECT_ID = do.OBJECT_ID
WHERE (id1, id2, gv$lock.type) IN
       (SELECT id1, id2, type FROM gv$lock WHERE request > 0)
ORDER BY id1, request;




    SELECT 'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||',@'||inst_id||''' IMMEDIATE;' as "KILL"
    --       'ALTER SYSTEM DISCONNECT SESSION '''||sid||','||serial#||',@'||inst_id||''' IMMEDIATE;' as "DISCONNECT"
      FROM gv$session
     WHERE SID IN(select blocking_session
                   from gv$session
                   where blocking_session IS NOT NULL)
     AND type not in ('BACKGROUND','FOREGROUND')
       AND status ='INACTIVE'
    order by LAST_CALL_ET DESC;