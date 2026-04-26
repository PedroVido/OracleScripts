-- Define o prompt para mostrar o nome do usuário e o identificador de conexão
set sqlprompt "@|blue _USER|@@@|red _CONNECT_IDENTIFIER|@@|blue > |@";

-- Ajuste de sessão
SET ECHO OFF;
SET FEEDBACK OFF;
SET LONG 20000
SET LONGCHUNKSIZE 20000
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';




-- Definição de módulo para monitoramento de atividades
EXEC dbms_application_info.set_module( module_name => 'DBA - Pedro Vido Acc - TRABALHANDO - SQLPLUS', action_name => 'Atividade XXXX');


-- Mensagem de boas-vindas personalizada
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT | DBA      : Pedro Vido - SME Accenture                                                     |
PROMPT | Blog     : https://pedrovidodba@blogspot.com.br/                                          |
PROMPT | Ambiente : Prod                                                                           |
PROMPT | Versao   : 1.1 - Adicionado informacao sobre container databases                          |
PROMPT +-------------------------------------------------------------------------------------------+
PROMPT


-- select de indentificacao da minha sessao
set sqlformat
set lines 9999 
set pages 9999
COL Identificador FOR a15  HEADING 'Sid|Serial' JUSTIFY LEFT WORD_WRAP TRUNC
COL Action FOR a40  HEADING 'Desc|Atividade' JUSTIFY LEFT WORD_WRAP TRUNC
COL username FOR a20  HEADING 'DB|User' JUSTIFY LEFT WORD_WRAP TRUNC
COL osuser FOR a20  HEADING 'SO|User' JUSTIFY LEFT WORD_WRAP TRUNC
COL module FOR a40  HEADING 'Module|Identificacao' JUSTIFY LEFT WORD_WRAP TRUNC
COL machine FOR a20  HEADING 'DBA|Machine' JUSTIFY LEFT WORD_WRAP TRUNC
COL service_name FOR a30  HEADING 'Servico' JUSTIFY LEFT WORD_WRAP TRUNC
COL schemaname FOR a20  HEADING 'DB|Schema' JUSTIFY LEFT WORD_WRAP TRUNC


select sid||','||serial#||',@'||inst_id as Identificador,
       schemaname ,
       username, 
       osuser,
       machine, 
       service_name,
       module,
       Action
from gv$session 
WHERE sid in (SELECT sid FROM v$mystat WHERE ROWNUM=1)
and osuser ='pcvido';

PROMPT
PROMPT
PROMPT
PROMPT

-- select de identificacao do banco
COL STARTUP_TIME FOR a20
COL DTHORA FOR a20
SELECT INSTANCE_NAME, STATUS, HOST_NAME, DATABASE_ROLE, OPEN_MODE, TO_CHAR(STARTUP_TIME,'DD/MM/YYYY HH24:MI:SS') AS STARTUP_TIME,
TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')  AS DTHORA
FROM V$INSTANCE, V$DATABASE;
alter session set optimizer_mode=rule;
PROMPT
PROMPT
--SET TIMING ON;

show con_name;
PROMPT
PROMPT

--show pdbs;

COLUMN pdb_name        FORMAT a30  HEADING NAME
COLUMN pdb_restricted  FORMAT a10   HEADING RESTRICTED

SELECT
     p.con_id,
     p.name pdb_name,
     p.open_mode,
     p.restricted pdb_restricted,
     TO_CHAR(p.open_time, 'dd/mm/yyyy hh24:mi') open_time,
     p.total_size/1024/1024 size_mb,
     p.dbid,
     p.create_scn
FROM v$pdbs p, v$containers c
WHERE c.con_id = p.con_id 
ORDER BY p.con_id;

PROMPT
PROMPT

SET FEEDBACK ON;
