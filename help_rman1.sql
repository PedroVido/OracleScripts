select * from dual;

--===================================================================
-- 1) Limpar archives expirados
--===================================================================


CROSSCHECK ARCHIVELOG ALL;
CROSSCHECK BACKUP DEVICE TYPE DISK;
DELETE EXPIRED ARCHIVELOG ALL;
DELETE OBSOLETE DEVICE TYPE DISK;

DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO SBT_TAPE COMPLETED BEFORE 'SYSDATE - 1';
DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO SBT_TAPE COMPLETED BEFORE 'SYSDATE - 2';


-- OCI 

RUN {
ALLOCATE CHANNEL DISK_1 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_2 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_3 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_4 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_5 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_6 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_7 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_8 DEVICE TYPE DISK ;
set command id to '241c707c98d811ecac760010e0f67232';
DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO SBT_TAPE COMPLETED BEFORE 'SYSDATE - 1';
""}



--===================================================================
-- 2) Limpar archives sem confirmacao
--===================================================================

DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-1';
DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-2';
DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-2/24';
DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-1/12';
DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-30';
DELETE ARCHIVELOG UNTIL TIME 'SYSDATE-90';

--===================================================================
-- 3) Restore archives
--===================================================================

-- Restore using sequences

oracle@sc01dbclient0201:/scripts/eprprd1$ rman target / catalog rman_user/rmanprd@catrman

Recovery Manager: Release 11.2.0.4.0 - Production on Seg Mar 22 05:28:47 2021

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: EPRPRD (DBID=3594585501)
connected to recovery catalog database

RMAN> run {
2> restore archivelog from logseq=111270 until logseq=111300 thread=2;
3> }

RUN {
ALLOCATE CHANNEL DISK_1 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_2 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_3 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_4 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_5 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_6 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_7 DEVICE TYPE DISK ;
ALLOCATE CHANNEL DISK_8 DEVICE TYPE DISK ;
restore archivelog from logseq=111270 until logseq=111300 thread=2;
}
 
--===================================================================
-- 4) CHEGAR ERROS NO COMANDO
--===================================================================

rman CHECKSYNTAX

--===================================================================
-- 5) RESYNC CATALOG
--===================================================================

-- BANCO DO RMAN (CATALOG)

rman target /
run
{
resync catalog;
crosscheck archivelog all;
crosscheck copy;
crosscheck backup;
delete noprompt obsolete;
delete noprompt expired copy;
delete noprompt expired archivelog all;
delete noprompt expired backup;
}

-- BANCO PRODUTIVO (LOGANDO NO CATALOG)

rman target / catalog username/pass@TNS_CATALOGO

rman target /
run
{
resync catalog;
crosscheck archivelog all;
crosscheck copy;
crosscheck backup;
delete noprompt obsolete;
delete noprompt expired copy;
delete noprompt expired archivelog all;
delete noprompt expired backup;
}

-- AMBIENTES STANDBY 

rman target / catalog username/pass@TNS_CATALOGO

resync catalog;
resync catalog from db_unique_name dbwmpdgr_dg;


--===================================================================
-- 6) Configuring parameters on RMAN
--===================================================================

CONFIGURE DB_UNIQUE_NAME 'dbwmpdgr_dg' CLEAR;                          -- retorna o parametro para default

CONFIGURE DB_UNIQUE_NAME 'dbwmpdgr_dg' CONNECT IDENTIFIER 'DBWMPDGR';  -- configura novo valor
CONFIGURE DB_UNIQUE_NAME 'dbwmddgr' CONNECT IDENTIFIER 'DBWMDDGR';

