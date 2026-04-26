-- Dataguard Commands

--========================================================
--17.1) Listando msg aplicacao do servico de archives MRP
--========================================================

 set lines 9999 pages 9999
 alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
 select instance_name, host_name,logins, startup_time from gv$instance;
 select name, db_unique_name, DATABASE_ROLE, LOG_MODE, open_mode from v$database;



set lines 1000 pages 9999
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
col message format a120
select timestamp, message from v$dataguard_status;

select PID, PROCESS, STATUS, GROUP#, THREAD#,SEQUENCE#, BLOCK#, BLOCKS from v$managed_standby;



--=============================================================
--17.2) Aplicacao de archives dataguard (Pode rodar em ambos)
--=============================================================


alter session set nls_date_format = 'DD-MON-YY HH24:MI:SS';
set lines 9999
set pages 9999
COLUMN NAME FORMAT A80
COLUMN CREATOR FORMAT A10
COLUMN APPLIED FORMAT A10
COLUMN COMPLETION_TIME FORMAT A20
COLUMN status FORMAT A7
COLUMN STANDBY_DEST FORMAT A15

select * from (
SELECT NAME, CREATOR, SEQUENCE#, status, STANDBY_DEST, APPLIED, COMPLETION_TIME 
FROM V$ARCHIVED_LOG
where completion_time >= to_date('17-DEC-25, 00:00:00', 'DD-MON-YY, HH24:MI:SS')
and rownum <40)
;


set head off
set numf 99999999999
set feedback off
set echo off
set serveroutput on
select CASE WHEN
((extract(second from to_dsinterval(value)) + extract(minute from to_dsinterval(value)) * 60 + extract(hour from to_dsinterval(value)) *60*60 + extract(day from to_dsinterval(value)) *60*60*24)> 900) 
THEN 'Critical Data Guard lag more than 15mins'
WHEN value is null THEN 'Critical Data Broken status'
WHEN (((sysdate - to_date(DATUM_TIME,'MM/DD/YYYY HH24:MI:SS'))*24*60*60) > 900) THEN 'Critical Data Guard Network broken'
ELSE 'Data Guard OK'
END
from v$dataguard_stats where name='apply lag';


--========================================================
--17.3) Status do processo de aplicao (Standby)
--========================================================

COLUMN status FORMAT A20
select process, client_process,thread#,sequence#,status from v$managed_standby where process like '%MRP%';


--========================================================
--17.4) Sequencias aplicadas
--========================================================


select * from (
select thread#,sequence#,first_time,next_time,applied from gv$archived_log where applied='YES'
order by first_time desc)
where rownum < 40
order by 1,3 desc;


--========================================================
--17.5) Ver tempo de lag de transport e apply
--========================================================

 Rodar no Standby

col value FORMAT A20
set lines 9999 pages 9999
SELECT NAME, VALUE FROM V$DATAGUARD_STATS;


--========================================================
--17.6) Ver diferencia de apply  (Pode rodar me ambos)
--========================================================


ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';
set lines 255;
set pages 255;
break on report on thread skip 1
compute sum label "gap total: " of gap on report
select a.thread# as thread,
b.last_seq,
a.applied_seq,
a.last_app_timestamp,
b.last_seq - a.applied_seq gap
from ( select thread#,
max (sequence#) applied_seq,
max (next_time) last_app_timestamp
from gv$archived_log
where applied = 'YES'
group by thread#) a,
( select thread#, max (sequence#) last_seq
from gv$archived_log
group by thread#) b
where a.thread# = b.thread#;


set pages 9999
set lines 9999
SELECT * FROM (
  SELECT sequence#, archived, applied, THREAD#,
         TO_CHAR(completion_time, 'RRRR/MM/DD HH24:MI') AS completed
  FROM sys.v$archived_log
  ORDER BY sequence# DESC)
  WHERE ROWNUM <= 10
/
 
select inst_id, process, status, thread#, sequence#, block#, blocks from gv$managed_standby where process in ('RFS','LNS','MRP0');


--========================================================
--17.7) Acessar broker via dgmgrl
--========================================================


Acessar o servidor do banco primario
configurar as variaveis de ambiente da instancia
acessar o dgmgrl com o comando - dgmgrl
connect sys/;
sys
show configuration

DGMGRL> show configuration

***** ou - Bypass user/pass ******

dgmgrl /

--========================================================
--17.8) Para replicacao Dataguard via broker
--========================================================


 PARAR
edit database <DBNAME> set state='transport-off';
edit database <DBNAME> set state='apply-off';


 ATIVAR
edit database <DBNAME> set state='transport-on';
edit database <DBNAME> set state='apply-on';


--========================================================
--17.9) Ver info via blroker
--========================================================


show database <DBNAME>
show database verbose <DBNAME>


--========================================================
--17.10) Start apply manual (Rodar no standby)
--========================================================


ALTER DATABASE MOUNT STANDBY DATABASE;

 OU

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;




--=================================================================================
--17.11) Ver erros de inconsistenca de parametros - memoria - controlfile - dgmgrl
--=================================================================================


show database <DBNAME> 'InconsistentProperties';

edit database <DBNAME> set property 'StandbyFileManagement'='AUTO';



-->  Check LogXptStatus Property

 -- Query the LogXptStatus monitorable property for the sending member to get more details about the error.

Example:

DGMGRL> show database <DBNAME> 'LogXptStatus';


-->  Check RecvQEntries Property

-- For the standby databases, you can use the monitorable property 'RecvQEntries', 
-- which returns a table indicating all log files that were received by the standby database but have not yet been applied:

DGMGRL>  show database <DBNAME> 'RecvQEntries';


--> Check status detailed

DGMGRL>  show database <DBNAME> statusreport;

--> Check sequences send

show database <DBNAME> sendQentries;

--=================================================================================
--17.12) Alterar parallel do apply de redos - dgmgrl
--=================================================================================


 edit database <DBNAME> set property ApplyParallel=60;


--=================================================================================
--17.13) Ver o apply rate da replicacao
--=================================================================================


 select sofar from gv$recovery_progress where item = 'Average Apply Rate' order by start_time desc


 col name for a40 heading 'Parameter|Name';
 col value for a10 heading 'Valor Atual| Session';
 select name, value from 
 v$parameter
 where name in('db_writer_processes', 'parallel_execution_message_size', 'parallel_automatic_tuning');


 create pfile='/home/oracle/pfile_ipordpd_bkp.ora' from memory;
 alter system set parallel_execution_message_size=32680 scope=spfile;
 alter system set db_writer_processes=15 scope=spfile;


--=================================================================================
--17.14) BAIXAR E SUBIR O BANCO E VOLTAR PARA READ ONLY WITH APPLY
--=================================================================================


 	QUANDO O BANCO NAO USA BROKER E PRECISA SER FEITO UM STOP START E DEPOIS PRECISAR VOLTAR PARA READ ONLY WITH APPLY:


    srvctl status database -d dbdownp -v
    srvctl stop database -d dbdownp
    srvctl start database -d dbdownp -o "read only"
    srvctl status database -d dbdownp -v

 


 ******   OU   *********


you are starting db in normal mount, Let us say you are in auto recovery with session disconnect mode...

--> Then you will stop recovery then open in read only mode:

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
ALTER DATABASE OPEN READ ONLY;


--> Then place auto recovery on:

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;



 ******   OU   *********

 -- Pare a Replicacao Via Broker

dgmgrl /

edit database "DBERPSAP_PRIM" set state='transport-off';
edit database "DBERPSAP_STBY" set state='apply-off';

-- Pare o Banco  via Servico
srvctl stop database -d dberpsap_stby

-- Suba o Banco como "Read Only" via servico
srvctl start database -d dberpsap_stby -o "read only"


-- Inicie a replicacao

dgmgrl /

edit database "DBERPSAP_PRIM" set state='transport-on';
edit database "DBERPSAP_STBY" set state='apply-on';


--=================================================================================
--17.15) MUDAR O STATUS DOS DESTS
--=================================================================================


ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE scope = both;




--=====================================================================================
-- MULTITENANT ENVIROMENTS
--=====================================================================================

--=================================================================================
--17.16) OPEN PLUGGABLE DATABASE - READ ONLY MODE
--=================================================================================

ALTER PLUGGABLE DATABASE pdb_name OPEN READ ONLY;