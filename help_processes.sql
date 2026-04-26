--==================================================
-- VER Consumo de processos e sessoes
--==================================================

set lines 9999
set pages 9999

COL RESOURCE_NAME FOR A25;
select resource_name,current_utilization,max_utilization from v$resource_limit where resource_name in ('processes','sessions');

--==================================================
-- alTERAR process e sessions
--==================================================


ALTER SYSTEM SET PROCESSES=7000 SCOPE=SPFILE;  
ALTER SYSTEM SET SESSIONS=7000 SCOPE=SPFILE;  

 -> Restart DB
