-- Rman scripts

--===================================
--21.A) Limpando Archives expirados
--===================================


 CROSSCHECK ARCHIVELOG ALL;
 CROSSCHECK BACKUP DEVICE TYPE DISK;
 DELETE EXPIRED ARCHIVELOG ALL;
 DELETE OBSOLETE DEVICE TYPE DISK;

DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO SBT_TAPE COMPLETED BEFORE 'SYSDATE - 1';
DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO SBT_TAPE COMPLETED BEFORE 'SYSDATE - 2';


DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-1';
DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-2';
DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-2/24';
DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-1/12';
DELETE FORCE NOPROMPT ARCHIVELOG UNTIL TIME 'SYSDATE-30';
DELETE ARCHIVELOG UNTIL TIME 'SYSDATE-90';

--===================================
--21.B) Restore archives
--===================================


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
""}

--================================================
--21.C) DELETE ARCHIVES OCI ALREADY BACKUPED
--================================================


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


--================================================
--21.D) CHEGAR ERROS NO COMANDO
--================================================


rman CHECKSYNTAX


--================================================
--21.E) Resync Catalogo Rman
--================================================

 Rodar no catalog do RMAN
 
 rman target /
 connect CATALOG rcvcat@rman
 Senha: *******

 Rodar o comando abaixo:

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

rman target / catalog rcvcat/rcvcat@rman
resync catalog;
resync catalog from db_unique_name dbwmpdgr_dg;



--================================================
--21.F) Tentativa de login sem sucesso no catalogo
--================================================


--select username,
--os_username,
--userhost,
--client_id,
--trunc(timestamp),
--count(*) failed_logins
--from dba_audit_trail
--where returncode=1017 and --1017 is invalid username/password
--timestamp > sysdate -7
--group by username,os_username,userhost, client_id,trunc(timestamp); 



--================================================
--21.G) Conexao para debug de backup ou comando
--================================================


rman target / catalog rcvcat/rcvcat@rman debug trace = /tmp/rman.trc log=/tmp/rman.log

 executar comando 

--================================================
--21.H) Setar parametros RMAN
--================================================


CONFIGURE DB_UNIQUE_NAME 'dbwmpdgr_dg' CLEAR;
CONFIGURE DB_UNIQUE_NAME 'dbwmddgr' CLEAR;

CONFIGURE DB_UNIQUE_NAME 'dbwmpdgr_dg' CONNECT IDENTIFIER 'DBWMPDGR';
CONFIGURE DB_UNIQUE_NAME 'dbwmddgr' CONNECT IDENTIFIER 'DBWMDDGR';


--================================================
--21.I) Acompanhar comando restore
--================================================


set lines 9999
set pagesize 100
col inst_id for 99
col sid for 99999
col CLIENT_INFO for a30
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';	
select   
	s.inst_id, 
	o.sid, 
	CLIENT_INFO ch,
	START_TIME,
    opname,	
	context, 
	sofar, 
	totalwork,
round(sofar/totalwork*100,2) "% Complete",
sysdate + TIME_REMAINING/3600/24 end_at
     FROM gv$session_longops o, 
	      gv$session s
     WHERE opname LIKE '%RMAN%'
     AND opname NOT LIKE '%aggregate%'
     AND o.sid=s.sid
     AND totalwork != 0
     AND sofar <> totalwork 
	 AND CLIENT_INFO IS NOT NULL 
	 order by 1,9 desc;
