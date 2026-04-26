--========================================================
-- KIll - Detailed
--========================================================

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
      'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||',@'||inst_id||''' IMMEDIATE;' as "KILL"
--       ,'ALTER SYSTEM DISCONNECT SESSION '''||sid||','||serial#||',@'||inst_id||''' IMMEDIATE;' as "DISCONNECT"
  FROM gv$session 
 WHERE status ='INACTIVE'
 and sql_id is null
 and Type != 'BACKGROUND'
 and username not in ('SYSRAC', 'DATADOG','SYS' )
 order by LAST_CALL_ET ASC;


--========================================================
-- KIll - SIMPLE
--========================================================

set lines 9999 pages 9999
set heading on;
set feedback on; 
column KILL format a55;
column DISCONNECT format a60; 
col username for a20;          
SELECT 
      'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||',@'||inst_id||''' IMMEDIATE;' as "KILL"
  FROM gv$session 
 WHERE status ='INACTIVE'
 and sql_id is null
 and Type != 'BACKGROUND'
 and username not in ('SYSRAC', 'DATADOG','SYS','OGGADM' )
 order by LAST_CALL_ET ASC;



--========================================================
-- KIll - LOOP
--========================================================

select count(*), inst_id, status from gv$session where status = 'INACTIVE' group by status, inst_id;
--
BEGIN
  FOR r IN (select sid, serial#  from v$session where status = 'INACTIVE' and machine like '%W2K16APDATAWEB%' and rownum <=100)
  LOOP
    EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid || ',' || r.serial# || ''' immediate';
  END LOOP;
END;
/
--
BEGIN
  FOR r IN (select sid, serial#  from v$session where status = 'INACTIVE' and username like '%OGGFORBD%' and rownum <=100)
  LOOP
    EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid || ',' || r.serial# || ''' immediate';
  END LOOP;
END;
/
--
BEGIN
  FOR r IN (select sid, serial#  from v$session where status = 'INACTIVE' and rownum <=100)
  LOOP
    EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid || ',' || r.serial# || ''' immediate';
  END LOOP;
END;
/

--========================================================
-- KIll - USING SQL_ID AND USERNAME
--========================================================

       set lines 9999 pages 9999
SELECT 'ALTER SYSTEM KILL SESSION '''||sid||','||serial#||',@'||inst_id||''' IMMEDIATE;' as "KILL"
  --       'ALTER SYSTEM DISCONNECT SESSION '''||sid||','||serial#||',@'||inst_id||''' IMMEDIATE;' as "DISCONNECT"
    FROM gv$session
   WHERE sql_id ='gpgv35arkux1g'
     and username = 'RDWMS17GRU'
     --and inst_id =3
       order by LAST_CALL_ET DESC;