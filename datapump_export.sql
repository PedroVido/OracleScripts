-- Datapump 

--======================================================================
-- COMANDOS EXPORT
--======================================================================

-- Usando nohup
nohup expdp \"/ as sysdba\" dumpfile=SKYIT_146495.dmp directory=EXPORTDATA LOGFILE=SKYIT_146495.log network_link=BIDWPRD_1 tables=DW.FT_RCRGA_BSE_ATVA metrics=yes &

-- Estimando estatisticas de exportacao
expdp \"/ as sysdba\"  directory=TEMP_DIR  ESTIMATE_ONLY=YES tables=DW.FT_RCRGA_BSE_ATVA logfile=SKYIT_146495.log


--======================================================================
--EXEMPLO DE PARAMETRO DE EXPORTAÇÃO
--======================================================================

-- COM EXCLUDE TABLES
DIRECTORY=DPUMP02
DUMPFILE=apdata_SYSRH_20221130_1720_%U.dmp
LOGFILE=apdata_SYSRH_20221130_1720_expdp.LOG
SCHEMAS=SYSRH
EXCLUDE=TABLE:"IN('MENSAGENS','MENSAGENSPARA')"
FILESIZE=100G
FLASHBACK_TIME=SYSTIMESTAMP
PARALLEL=24
CLUSTER=N

-- TABLES
DIRECTORY=DIR_EXP
DUMPFILE=dbdownp_SYSTEM_LOGMNR_LOG_20260320_%U.dmp
LOGFILE=dbdownp_SYSTEM_LOGMNR_LOG_20260320_expdp.LOG
TABLES=SYSTEM.LOGMNR_LOG$
FILESIZE=1G
FLASHBACK_TIME=SYSTIMESTAMP
PARALLEL=2
CLUSTER=N

-- SCHEMA
DIRECTORY=DPUMP02
DUMPFILE=apdata_SYSRH_20221130_1720_%U.dmp
LOGFILE=apdata_SYSRH_20221130_1720_expdp.LOG
SCHEMAS=SYSRH
FILESIZE=100G
FLASHBACK_TIME=SYSTIMESTAMP
PARALLEL=24
CLUSTER=N

--======================================================================
--EXEMPLOS DE CRIACAO DE DIRETORIO
--======================================================================

set lines 9999 pages 9999
col owner for a10;
col diretory_name for a10;
col directory_path for a70;
select * from dba_directories;


CREATE DIRECTORY <DIRECTORY_NAME> AS <'DIRECTORY_PATH'>;


GRANT READ,WRITE ON DIRECTORY <DIRECTORY_NAME> TO PUBLIC;
GRANT READ,WRITE ON DIRECTORY <DIRECTORY_NAME> TO <USER>;



--======================================================================
-- MONITORAMENTO
--======================================================================

-- 1 - Monitorando Datapumps via SO 

ps aux | grep dw
ps aux | grep ora_dm

Processos DW (ora_dw): Dois processos (ora_dw00_orcl e ora_dw01_orcl) estão ativos. 
Isso confirma que o parâmetro PARALLEL=2 foi aplicado corretamente. Cada processo DW é responsável por escrever em um arquivo dump específico, dividindo o trabalho de exportação e acelerando a conclusão do job.

Processo DM (ora_dm): Há apenas um processo ativo (ora_dm00_orcl), que atua como a tabela mestre dessa operação. Ele coordena as atividades dos processos DW, garantindo que todas as partes da exportação sejam realizadas com precisão e organizadas corretamente.

Agora como usuário SYS dentro do PDB  pode ser consultado a view DBA_DATAPUMP_JOBS é possível monitorar o DATA PUMP em tempo real.


--> 2 - Monitando dentro do banco - Tabela MASTER do export 

Com as informações que temos podemos acessar a tabela master. Sim toda vez que se inicia uma exportação o systema cria uma TABELA MASTER na qual é usada como ponte para transportar as informações e para que possamos acessar esta tabela master aplicamos o comando:

SQL
desc OWER_NAME.JOB_NAME



--> 3 - Monitorando de dentro do banco - DBA_DATAPUMP_JOBS

SELECT OPNAME, SID, SERIAL#, CONTEXT, SOFAR, TOTALWORK, ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM V$SESSION_LONGOPS WHERE OPNAME in
( select d.job_name from v$session s, v$process p, dba_datapump_sessions d
where p.addr=s.paddr and s.saddr=d.saddr )
AND OPNAME NOT LIKE '%aggregate%' AND 
TOTALWORK != 0 AND SOFAR <> TOTALWORK;


column owner_name format a20;
column job_name format a40;
column operation format a10;
column job_mode format a10;
column state format a15;
column attached_sessions format a10;
SELECT owner_name, job_name, operation, job_mode, state, attached_sessions
FROM dba_datapump_jobs
order by job_name desc;


--> 4 - Dropar jobs que estao orfaos Datapump 

select * from dba_datapump_jobs;


SELECT
'DROP ' ||o.object_type||' '||o.owner||'.'||object_name||' PURGE;' CMD, state
FROM
dba_objects o
, dba_datapump_jobs j
WHERE
o.owner=j.owner_name AND
o.object_name=j.job_name AND
j.job_name NOT LIKE 'BIN$%'
ORDER BY CMD;

--======================================================================
-- Expdp of  Table Returns ORA-39166 or ORA-31655 in Oracle Database
--======================================================================

Objects (tables, views, schemas, etc) which fall under either of below conditions are not exported with expdp because they are regarded as system maintained objects.

Object is listed in ku_noexp_view.
This view is a union of ku_noexp_tab and noexp$ tables.
Objects that are listed in this view are not exported.

Object is ORACLE_MAINTAINED='Y' in ALL_OBJECTS (and DBA_OBJECTS).
 

If you wish to export such non-exportable table, create a copy of that table in a user schema, and export that copied table.

eg.
create table <copied_table_name> as select * from <table_you_wish_to_export>;