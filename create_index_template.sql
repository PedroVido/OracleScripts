-- validar quantidade de registros da tabela
select count(*) from USR_MS_ADDRESS.TB_CADASTRO_ENDERECO;

-- ===========================================================================================================
--
--  BLOCO DE AMBIENTE 
--
-- ===========================================================================================================

set colsep " | "
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
--ALTER SESSION SET NLS_LANGUAGE='BRAZILIAN PORTUGUESE';
set lines 999;
set pages 999;
col host for a40
col schema for a25
col data for a18
col status for a10
set timing on
set heading on
set feedback on
set echo on
set serveroutput on
alter session set current_schema=USR_MS_ADDRESS;
SELECT i.HOST_NAME host,
i.INSTANCE_NAME instance,
SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') schema,to_char(sysdate,'DD/MM/YYYY hh24:mi:ss') EXECUCAO_SCRIPT,i.STATUS,(select distinct sid from v$mystat) SID 
FROM V$INSTANCE i, v$database d;

-- ===========================================================================================================
--
--  BLOCO DE VALIDACAO PRE CREATE DOS INDEXES 
--
-- ===========================================================================================================

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
col OWNER for a20;
col INDEX_NAME for a25;
col TABLE_OWNER for a20;
col TABLE_NAME for a25;
SELECT OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, logging,degree, LAST_ANALYZED FROM DBA_INDEXES WHERE TABLE_NAME in ('TB_CADASTRO_ENDERECO') AND TABLE_OWNER ='USR_MS_ADDRESS' order by INDEX_NAME;

col index_owner for a25;
col column_name for a100;
select index_owner, index_name, table_name, column_name from dba_ind_columns where table_name = 'TB_CADASTRO_ENDERECO' and index_owner = 'USR_MS_ADDRESS' order by index_name;


-- ===========================================================================================================
--
--  BLOCO DO CREATE
--
-- ===========================================================================================================

create index USR_MS_ADDRESS.IDX_TB_CADAS_ENDE_01 on USR_MS_ADDRESS.TB_CADASTRO_ENDERECO('CD_REGIONAL','ID_SECAO','ID_AREA','CD_SETOR') parallel 4 nologging;
create index USR_MS_ADDRESS.IDX_TB_CADAS_ENDE_02 on USR_MS_ADDRESS.TB_CADASTRO_ENDERECO('CD_REGIONAL','FL_ADDRESS_LEGACY') parallel 4 nologging;


ALTER INDEX USR_MS_ADDRESS.IDX_TB_CADAS_ENDE_01 NOPARALLEL;
ALTER INDEX USR_MS_ADDRESS.IDX_TB_CADAS_ENDE_01 LOGGING;

ALTER INDEX USR_MS_ADDRESS.IDX_TB_CADAS_ENDE_02 NOPARALLEL;
ALTER INDEX USR_MS_ADDRESS.IDX_TB_CADAS_ENDE_02 LOGGING;


------
set timing on;
ALTER SESSION SET DDL_LOCK_TIMEOUT = 900;
create index USR_MS_UFINANCIAL.IDX_TB_BF_CLIENTE_CARTAO_01 on USR_MS_UFINANCIAL.TB_BF_CLIENTE_CARTAO('CD_CARTAO') tablespace TSI_UFINANCIAL parallel 4 nologging;
ALTER INDEX USR_MS_UFINANCIAL.IDX_TB_BF_CLIENTE_CARTAO_01 NOPARALLEL;
ALTER INDEX USR_MS_UFINANCIAL.IDX_TB_BF_CLIENTE_CARTAO_01 LOGGING;
set timing off;

-- ===========================================================================================================
--
--  BLOCO DE VALIDACAO POS CREATE DOS INDEXES 
--
-- ===========================================================================================================

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
col OWNER for a20;
col INDEX_NAME for a25;
col TABLE_OWNER for a20;
col TABLE_NAME for a25;
SELECT OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, logging,degree, LAST_ANALYZED 
FROM DBA_INDEXES WHERE TABLE_NAME in ('TB_CADASTRO_ENDERECO') AND TABLE_OWNER = 'USR_MS_ADDRESS';

col index_owner for a25;
col column_name for a100;
select index_owner, index_name, table_name, column_name from dba_ind_columns where table_name = 'TB_CADASTRO_ENDERECO' and index_owner = 'USR_MS_ADDRESS' order by index_name;
