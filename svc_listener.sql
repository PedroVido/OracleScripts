-- Service Issues 


The V$ACTIVE_SERVICES view in Oracle provides information about the currently active database services. 
It is particularly useful for monitoring and managing services in both single-instance and RAC (Real Application Clusters) environments.



-- Practical Use Cases :

Service Monitoring: Identify which services are currently active in your database.
Troubleshooting: Verify if a specific service is running when connection issues occur.
Load Balancing: Monitor active services across RAC nodes to ensure proper distribution.
This view is essential for database administrators managing Oracle environments with multiple services.





--====================================
--> Validar service :
--====================================

-- On CDB :

sqlplus / as sysdba

show con_name

-- On PDB :

sqlplus / as sysdba

select name, pdb from v$services;

alter session set container ='PDB';

show con_name



--> Only active services - Ver servico ativo

set lines 9999
set pages 9999
col name for a35;
col network_name for a100;
SELECT name,
network_name,
CREATION_DATE
FROM v$active_services
ORDER BY name;


--> All services - Ver se o servio existe
col name for a35;
col network_name for a100;
SELECT name,
network_name,
CREATION_DATE
FROM dba_services
ORDER BY name;

--====================================
--> Create new service :
--====================================

-- OBS: parameters are the the SERVICE_NAME and the NETWORK_NAME, 
--      which represent the internal name of the service in the data dictionary and the name of the service presented by the listener respectively.

BEGIN
  DBMS_SERVICE.create_service(
    service_name => 'my_new_service',
    network_name => 'my_new_service'
  );
END;
/

BEGIN
  DBMS_SERVICE.create_service(
    service_name => 'dberpgop_pdb1',
    network_name => 'dberpgop_pdb1.raiadrogasil.com.br'
  );
END;
/



-- OU

 exec dbms_service.create_service('orcl1_svc_new','orcl1_svc_new');



-- Criar servico no grid caso necessario

--> -d   : database in grid
--> -pdb : pdb if is a container database
--> -s   : Name of service you want create
--> -i   : inst name instead of pdb if not is a container database

srvctl add service -d dbwmsrsp_prim -pdb DBWMPDRS_PDB1 -s DBWMSRSP_PDB1
srvctl add service -d dbwmsrsp_prim -i DBWMPDRS1 -s DBWMSRSP1

--====================================
--> Start service :
--====================================

 BEGIN
  DBMS_SERVICE.start_service(
    service_name => 'my_new_service'
  );
END;
/

 BEGIN
  DBMS_SERVICE.start_service(
    service_name => 'DBWMSRSP_PDB1'
  );
END;
/



--====================================
--> Parar service :
--====================================

BEGIN
  DBMS_SERVICE.stop_service(
    service_name => 'my_new_service'
  );
END;
/

--====================================
--> Deletar service :
--====================================


BEGIN
  DBMS_SERVICE.delete_service(
    service_name => 'my_new_service'
  );
END;
/


--====================================
--> Disconnect Sessions :
--====================================

/*
The DISCONNECT_SESSION procedure disconnects all sessions currently connected to the service. The disconnection can take one of three forms, indicated by package constants.

POST_TRANSACTION : Sessions disconnect once their current transaction ends with a commit or rollback. This is the default value (0).
IMMEDIATE : Sessions disconnect immediately. Value (1).
NOREPLAY : Sessions disconnect immediately, and are flagged not to be replayed by application continuity. Value (2).
Here is an example of its usage.
*/

BEGIN
  DBMS_SERVICE.disconnect_session(
   service_name      => 'my_new_service',
   disconnect_option => DBMS_SERVICE.immediate
  );
END;
/