--===================================================================
-- DIR LOGS
--===================================================================

$GRID_HOME/log/<node_name>/crsd/crsd.log


--===================================================================
-- RAC problems after storage reboot 
--===================================================================
-- Db on node was not enable after reboot
[oracle@lxorccon1 ogg19]$ srvctl start database -d dbconpd
PRCR-1079 : Falha ao iniciar o recurso ora.dbconpd.db
CRS-2665: Resource 'ora.dbconpd.db' is disabled on 'lxorccon2'


-- list rac parameter 
crsctl stat res ora.database_name.db -p


[oracle@lxorccon1 ogg19]$ srvctl enable -h

O comando enable do SRVCTL ativa o objeto nomeado, de forma que ele possa ser executado Oracle Clusterware para inicialização automática, failover ou reinicialização.

Uso: srvctl enable database -d <db_unique_name> [-n <node_name>]
Uso: srvctl enable instance -d <db_unique_name> -i "<inst_name_list>"
Uso: srvctl enable service -d <db_unique_name> -s "<service_name_list>" [-i <inst_name> | -n <node_name>]
Uso: srvctl enable asm [-n <node_name>]
Uso: srvctl enable listener [-l <lsnr_name>] [-n <node_name>]
Uso: srvctl enable nodeapps [-g] [-v]
Uso: srvctl enable vip -i <vip_name> [-v]
Uso: srvctl enable scan [-i <ordinal_number>]
Uso: srvctl enable scan_listener [-i <ordinal_number>]
Uso: srvctl enable oc4j [-n <node_name>] [-v]
Uso: srvctl enable filesystem -d <volume_device>
Uso: srvctl enable diskgroup -g <dg_name> [-n "<node_list>"]
Uso: srvctl enable gns [-n <node_name>] [-v]
Uso: srvctl enable cvu [-n <node_name>]
Para obter ajuda detalhada sobre comandos e objetos e o uso de suas opções:
  srvctl <command> <object> -h
[oracle@lxorccon1 ogg19]$ srvctl enable database -d dbconpd -n lxorccon2
[oracle@lxorccon1 ogg19]$


--===================================================================
-- 1) Then check the status of the clusterware globally as follows:
--===================================================================

crsctl check cluster -all
crsctl check crs
crsctl check has


--===================================================================
-- 2) srvctl 
--===================================================================

-- Comando de Stop e START

srvctl stop instance -d <DB_NAME> -i <INSTANCE_NAME>  -- stop instsance
srvctl start instance -d <DB_NAME> -i <INSTANCE_NAME> -- start instance
srvctl stop database -d asplprd_gru1hq                -- stop database
srvctl start database -d asplprd_gru1hq               -- start database
srvctl status database -d asplprd_gru1hq -v           -- status database

--===================================================================
-- 3) status cluster 
--===================================================================

-- Status do cluster detailed

crsctl status res -t

-- status cluster during startup

crsctl status res -t -init

--===================================================================
-- 4) Query voting disks 
--===================================================================

sudo /u01/app/11.2.0/grid/bin/crsctl query css votedisk

--===================================================================
-- 5) Enable disable autostart
--===================================================================

-- RAC

crsctl enable crs
crsctl disable crs

-- Single Instance + ASM

crsctl enable has
crsctl disable has

--===================================================================
-- 6) Infos de rede  do Cluster
--===================================================================

gpnptool get

--===================================================================
-- 7) start RAC - ALL
--===================================================================

crsctl start cluster

--===================================================================
-- 8) Start/Stop resource
--===================================================================

crsctl stop resource -all
crsctl start resource -all

-- Subir o CRSD
sudo /u01/app/11.2.0/grid/bin/crsctl start res ora.crsd -init

-- Subir o DG RECO
/u01/app/11.2.0/grid/bin/srvctl start diskgroup -g RECO -n lxorcrib2


--===================================================================
-- 9) Stop CRS/HAS 
--===================================================================

-- RAC

crsctl start crs 
crsctl stop crs 
crsctl stop crs -f


-- Single instance + ASM

crsctl start has 
crsctl stop has
crsctl stop has - f

--===================================================================
-- 10) Stop/Start ASM 
--===================================================================

srvctl start asm
srvctl stop asm
srvctl stop asm -f 

-- Erro ao subir ASM

--> ERRO: ORA-15063: ASM discovered an insufficient number of disks for diskgroup "DATA"

Validar os discos, como achar os discos :

Rodar o comando : crsctl stat resource ora.asm -f
Procurar o campo : ASM_DISKSTRING 

Depois rodar o comando  :  ls -lart /dev/sd*

Olhar as permissoes do banco, deve estar com oracle:dba

apos arrumar a permissao, subir o cluster

--===================================================================
-- 11) Stop/Start DB INSTANCE mount/Ready Only
--===================================================================

srvctl start database -d apdatamtz -o nomount
srvctl start database -d apdatamtz -o "read only"

srvctl stop database -d apdatamtz

--===================================================================
-- 12) Stop/Start service (*.svc)
--===================================================================

-- SAIDA DO COMANDO crsctl status res -t

ora.dbbmapd.svbmastd.svc
      1        ONLINE  OFFLINE  <----- Deveria estar online apenas na inst 1
      2        OFFLINE OFFLINE



-- Comando para subir o comando na inst 1 

srvctl start service -d dbbmapd -s svbmastd -i dbbmapd1  -- start service on one node
srvctl start service -d dbribpd -s svribstd              -- start service on all nodes
srvctl stop service -d dbribpd -s svribstd               -- stop service on all nodes


srvctl config service -d R102 -s ora.r102_std.r102_bi_dlake.svc


--===================================================================
-- 13) Stop/Start oracleasm
--===================================================================

oracleasm status
oracleasm stop
oracleasm init

--===================================================================
-- 14) Comandos oracleasm
--===================================================================

oracleasm listdisks
oracleasm scandisks

--===================================================================
-- 15) Limpar cache do RAC 
--===================================================================

sync; echo 1 > /proc/sys/vm/drop_caches 
sync; echo 2 > /proc/sys/vm/drop_caches 
sync; echo 3 > /proc/sys/vm/drop_caches


--===================================================================
-- 16)  Ver o status do cluster e o patch level
--===================================================================

<$GI_HOME>/bin/crsctl  query crs activeversion -f

--===================================================================
-- 17)  Comandos para ver status e parar servicos
--===================================================================

crsctl status resource
crsctl status resource ora.oc4j -f | egrep '^(NAME|ENABLED|STATE|TARGET)='
crsctl status resource ora.cvu -f | egrep '^(NAME|ENABLED|STATE|TARGET)='


crsctl stop resource ora.oc4j -f
crsctl status resource ora.oc4j -f

crsctl modify resource ora.oc4j -attr "ENABLED=0" -f
srvctl disable oc4j -v

find  | egrep 'STARTING|scriptagent|java|qos|23792'


--===================================================================
-- 18)  Comandos para ver multipath
--===================================================================

multipath -ll | grep mpath | wc -l