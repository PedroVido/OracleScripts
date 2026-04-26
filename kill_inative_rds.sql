set lines 9999 pages 9999
column KILL format a55;
column DISCONNECT format a60;            
SELECT 'exec rdsadmin.rdsadmin_util.kill('||sid||','||serial#||');' as "KILL",
  FROM gv$session 
 WHERE status ='INACTIVE' 
 --and username = 'CTMSERVICE'
   AND type not in ('BACKGROUND','FOREGROUND')
   order by LAST_CALL_ET DESC;





set lines 9999 pages 9999
set heading on;
set feedback on; 
column KILL format a55;
column DISCONNECT format a60;            
SELECT username, 
      sid||','||serial#||',@'||inst_id as "SID/SERIAL",
      machine, 
      sql_id,
      status,
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
                                              TRUNC(last_call_et / (60 * 60 * 24))) * 24)) * 60))) * 60) || 'S ' AS LAST_CALL_ET,
                                              'exec rdsadmin.rdsadmin_util.kill('||sid||','||serial#||');' as "KILL"
  FROM gv$session 
 WHERE status ='INACTIVE' 
 --and username = 'CTMSERVICE'
   AND type not in ('BACKGROUND')
   order by LAST_CALL_ET ASC;
















set linesize 200 pagesize 300
select 'exec rdsadmin.rdsadmin_util.kill('||s.sid||','||s.serial#||', ''IMMEDIATE'''||');' kill 
from v$session s
where 1=1 
and username = upper('USR_MS_PAGTO_PRD')
and STATUS != 'ACTIVE'
and s.Type != 'BACKGROUND';



exec rdsadmin.rdsadmin_util.kill('1907','34608', 'IMMEDIATE');