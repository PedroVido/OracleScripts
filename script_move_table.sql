-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : MOVE_TABLE_102.sql                                                                    --
-- Description   : Move table Online and validations after move                                          --
-- Change        :                                                                                       --
-- Requirements  : Access to the GV$ views and SYSDBA privileges.                                        --
-- Call Syntax   : @MOVE_TABLE_102.sql                                                                   --
-- Last Modified : 25/04/2026                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
-- Version       : 1.2                                                                                   --
--                                                                                                       --
-- ########################################################################################################

--==========================================================
-- 0) Query para acompanhamento em outra sessao
--==========================================================

/*

EXEC dbms_application_info.set_module( module_name => 'DBA - Pedro Vido Acc - SQLPLUS', action_name => 'Atividade CHG0053684 - Acompanhamento ...');
select sid, serial#, inst_id, username, sql_id, action, event, blocking_session, blocking_instance from gv$session where osuser = 'pcvido';

*/


--==========================================================
-- 1) Configurando spool
--==========================================================
spool "C:\Users\pcvido\Documents\MOVETABLE_R102_CHG0053684.log"

--==========================================================
-- 2) Configurando Console
--==========================================================

-- Supress the text of commands are replicated to console/terminal
SET ECHO OFF  
-- Supress displays the number of records returned
SET FEEDBACK OFF  
-- Supress text of commands of select from dual to replciate to console/terminal         
SET HEADING OFF
-- Supress Send messages from stored procedures
SET SERVEROUTPUT OFF
-- Supress the text "elapsed time" replicated to console/terminal
SET TIMING OFF

--==========================================================
-- 3) Configurando Columns
--==========================================================

set colsep " | "
set lines 999;
set pages 999;
col host for a40
col schema for a25
col data for a18
col status for a10

--==========================================================
-- 4) Configurando DateTime
--==========================================================

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';


--==========================================================
-- 5) Configurando Module/Action (Para rastreabilidade)
--==========================================================


EXEC dbms_application_info.set_module( module_name => 'DBA - Pedro Vido Acc - SQLPLUS', action_name => 'Atividade CHG0053684 - Realizando validacoes Pre MOVE ...');


--==========================================================
-- 6) Infos do Ambiente Alvo
--==========================================================

SET HEADING ON
SELECT i.HOST_NAME host,
i.INSTANCE_NAME instance,
SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') schema,
to_char(sysdate,'DD/MM/YYYY hh24:mi:ss') EXECUCAO_SCRIPT,i.STATUS,
(select distinct sid from v$mystat) SID 
FROM V$INSTANCE i, v$database d;
SET HEADING OFF

prompt 
prompt

--==========================================================
-- 7) Inicio Script 
--==========================================================



prompt
prompt
select '-----------------------------------------' from dual;
select '  TBS ANTES  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt
prompt

col owner for a15
col tablespace_name for a20
col table_name for a40
col status for a10
select table_name, owner, tablespace_name,degree, status from dba_tables where tablespace_name = 'RAIADADOS'
and table_name in ('TB_TELEVENDA_STATUS_HISTORICO','DFE_HISTORICO_NFE','TB_PRODUTO_ESTOQUE_DIA_HIST_CG','TB_AUDITORIA_LOG','TB_PBM_ARQUIVOS_LOG','TB_SALDO_NUMERARIO_LOG',
'TB_PEDIDO_HISTORICO_STATUS','TB_CLIENTE_LGPD_HIST_COMPLETO','DFE_HISTORICO_RPS','DFE_HISTORICO_WS_DISTRIBUICAO','TB_STIX_RESGATE_PDV_LOG','TB_PEDIDO_COMPRA_HISTORICO','TB_ABACOS_LOG','TB_ITMKT_LOG','TB_CAT_ARQUIVO_LOG','TB_PBM_LOG','TB_NGC_HISTORICO',
'TB_CML_LOG','TB_CLIENTE_HISTORICO','DFE_HISTORICO_PROC_MIGRACAO','ACTIVE_SESSION_HIST_20240814_11226',       
'TB_CCRAIA_CLIENTE_HISTORICO','TB_PEDIDO_SYNC_LOG','TB_CHEQUE_HISTORICO','CUST01_HIST_BI','TB_STIX_RESGATE_LOG','TB_MAG_LOG','TB_IMPROPRIO_HIST_GUIA_ITEM','TB_CEP_LOG','TB_HIST_RECEITA_RETORNO_PESQ','DFE_HISTORICO_EVENTO_NFE','TB_SPED_ESCRITURACAO_LOG',         
'DFE_HISTORICO_CONSUMO_INDEVIDO','TB_TELEVENDA_HIST_ENDERECO','DATABASECHANGELOG','AUT_USUARIO_HISTORICO_ACESSO','TB_TP_LOG','TB_TELEVENDA_MSG_LOG','TB_SCHEDULER_LOG','TB_SAP_WORKFLOW_LOG','TB_PRODUTO_ESTOQ_DIA_HIST2','TB_MRD_HISTORICO_INDISPONIVEL',      
'TB_LOG_HISTORICO_FECHAMENTO','TB_LOCAL_ARQUIVO_LOG','TB_HISTORICO_NF','TB_HISTORICO_ITENS','TB_HISTORICO_CONTABIL_COMPL','TB_HISTORICO_CONTABIL','TB_FATURAMENTO_HISTORICO','TB_AUDIT_LOG','TB_ASSINATURA_HISTORICO','DFE_PASS_PORTARIA_HIST_NFE',         
'DFE_HISTORICO_RELATORIO_PROCES','DFE_HISTORICO_RELATORIO','DFE_HISTORICO_NFS','DFE_HISTORICO_MIGRACAO','DFE_HISTORICO_EVENTO_CTE','DFE_HISTORICO_CCE_NFE','DFE_HISTORICO_ARQUIVO_RETORNO','ACTIVE_SESSION_HIST_20241211_9059','TB_TP_OPER_FISCAL_HIST_GRUPO');
prompt
prompt


set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '  INDEXES ANTES  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt
prompt

set lines 9999 pages 9999
col owner for a25
col index_name for a40
col index_type for a10
col table_owner for a40
col tablespace_name for a15
col status for a10
select owner, index_name, index_type, table_owner, table_name, tablespace_name,degree, status from dba_indexes where tablespace_name = 'RAIADADOS'
and table_name in ('TB_TELEVENDA_STATUS_HISTORICO','DFE_HISTORICO_NFE','TB_PRODUTO_ESTOQUE_DIA_HIST_CG','TB_AUDITORIA_LOG','TB_PBM_ARQUIVOS_LOG','TB_SALDO_NUMERARIO_LOG',
'TB_PEDIDO_HISTORICO_STATUS','TB_CLIENTE_LGPD_HIST_COMPLETO','DFE_HISTORICO_RPS','DFE_HISTORICO_WS_DISTRIBUICAO','TB_STIX_RESGATE_PDV_LOG','TB_PEDIDO_COMPRA_HISTORICO','TB_ABACOS_LOG','TB_ITMKT_LOG','TB_CAT_ARQUIVO_LOG','TB_PBM_LOG','TB_NGC_HISTORICO',
'TB_CML_LOG','TB_CLIENTE_HISTORICO','DFE_HISTORICO_PROC_MIGRACAO','ACTIVE_SESSION_HIST_20240814_11226',       
'TB_CCRAIA_CLIENTE_HISTORICO','TB_PEDIDO_SYNC_LOG','TB_CHEQUE_HISTORICO','CUST01_HIST_BI','TB_STIX_RESGATE_LOG','TB_MAG_LOG','TB_IMPROPRIO_HIST_GUIA_ITEM','TB_CEP_LOG','TB_HIST_RECEITA_RETORNO_PESQ','DFE_HISTORICO_EVENTO_NFE','TB_SPED_ESCRITURACAO_LOG',         
'DFE_HISTORICO_CONSUMO_INDEVIDO','TB_TELEVENDA_HIST_ENDERECO','DATABASECHANGELOG','AUT_USUARIO_HISTORICO_ACESSO','TB_TP_LOG','TB_TELEVENDA_MSG_LOG','TB_SCHEDULER_LOG','TB_SAP_WORKFLOW_LOG','TB_PRODUTO_ESTOQ_DIA_HIST2','TB_MRD_HISTORICO_INDISPONIVEL',      
'TB_LOG_HISTORICO_FECHAMENTO','TB_LOCAL_ARQUIVO_LOG','TB_HISTORICO_NF','TB_HISTORICO_ITENS','TB_HISTORICO_CONTABIL_COMPL','TB_HISTORICO_CONTABIL','TB_FATURAMENTO_HISTORICO','TB_AUDIT_LOG','TB_ASSINATURA_HISTORICO','DFE_PASS_PORTARIA_HIST_NFE',         
'DFE_HISTORICO_RELATORIO_PROCES','DFE_HISTORICO_RELATORIO','DFE_HISTORICO_NFS','DFE_HISTORICO_MIGRACAO','DFE_HISTORICO_EVENTO_CTE','DFE_HISTORICO_CCE_NFE','DFE_HISTORICO_ARQUIVO_RETORNO','ACTIVE_SESSION_HIST_20241211_9059','TB_TP_OPER_FISCAL_HIST_GRUPO');
prompt
prompt


set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '   CONSUMO TBS ANTES  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;

prompt 
prompt 

COL TABLESPACE   FOR A35          HEADING 'Tablespace'
COL TBS_SIZE     FOR 999,999,990  HEADING 'Tamanho|atual'       JUSTIFY RIGHT
COL TBS_EM_USO   FOR 999,999,990  HEADING 'Em uso'              JUSTIFY RIGHT
COL TBS_MAXSIZE  FOR 999,999,990  HEADING 'Tamanho|maximo'      JUSTIFY RIGHT
COL FREE_SPACE   FOR 999,999,990  HEADING 'Espaco|livre atual'  JUSTIFY RIGHT
COL SPACE        FOR 999,999,990  HEADING 'Espaco|livre total'  JUSTIFY RIGHT
COL PERC         FOR 990          HEADING '%|Ocupacao'          JUSTIFY RIGHT
--set wrap off
set lines 145
set pages 999
set verify off

break on report on tablespace_name skip 1
compute sum label "Total: " of tbs_em_uso tbs_size tbs_maxsize free_space space on report

select /*+ RULE */ d.tablespace,
       trunc((d.tbs_size-nvl(s.free_space, 0))/1024/1024) tbs_em_uso,
       trunc(d.tbs_size/1024/1024) tbs_size,
       trunc(d.tbs_maxsize/1024/1024) tbs_maxsize,
       trunc(nvl(s.free_space, 0)/1024/1024) free_space,
       trunc((d.tbs_maxsize - d.tbs_size + nvl(s.free_space, 0))/1024/1024) space,
       trunc((d.tbs_size-nvl(s.free_space, 0))*100/d.tbs_maxsize) perc
from
  ( select /*+ RULE */ SUM(bytes) tbs_size,
           SUM(decode(sign(maxbytes - bytes), -1, bytes, maxbytes)) tbs_maxsize,
           tablespace_name tablespace
    from ( select /*+ RULE */ nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_data_files
           union all
           select /*+ RULE */ nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_temp_files
         )
    group by tablespace_name
  ) d,
  ( select /*+ RULE */ SUM(bytes) free_space,
           tablespace_name tablespace
    from dba_free_space
    group by tablespace_name
  ) s
where d.tablespace = s.tablespace(+)
and d.tablespace = 'RAIADADOS'
order by 7 desc;


set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '  MOVE TBS  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;


--==========================================================
-- 8) Configurando Module/Action (Para rastreabilidade)
--==========================================================


EXEC dbms_application_info.set_module( module_name => 'DBA - Pedro Vido Acc - SQLPLUS', action_name => 'Atividade CHG0053684 - MOVE table em andamento ...');


-- Config Adicional 

SET ECHO ON
SET TIMING ON

--select sysdate from dual;

-- 0G a 1G --		 
ALTER TABLE A_RAIABD.TB_PBM_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                                     
ALTER TABLE A_RAIABD.TB_NGC_HISTORICO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                               
ALTER TABLE A_RAIABD.TB_CML_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                                     
ALTER TABLE A_RAIABD.TB_CLIENTE_HISTORICO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                           
ALTER TABLE MSAF_DFE.DFE_HISTORICO_PROC_MIGRACAO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                    
ALTER TABLE A_RAIABD.TB_CCRAIA_CLIENTE_HISTORICO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                    
ALTER TABLE USR_MS_PEDSYNC.TB_PEDIDO_SYNC_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                             
ALTER TABLE A_RAIABD.TB_CHEQUE_HISTORICO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                            
ALTER TABLE A_RAIABD.CUST01_HIST_BI MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                                 
ALTER TABLE A_RAIABD.TB_STIX_RESGATE_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                            
ALTER TABLE A_RAIABD.TB_MAG_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                                     
ALTER TABLE A_RAIABD.TB_IMPROPRIO_HIST_GUIA_ITEM MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                    
ALTER TABLE A_RAIABD.TB_CEP_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                                     
ALTER TABLE A_RAIABD.TB_HIST_RECEITA_RETORNO_PESQ MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                   
ALTER TABLE MSAF_DFE.DFE_HISTORICO_EVENTO_NFE MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                       
ALTER TABLE A_RAIABD.TB_SPED_ESCRITURACAO_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                       
ALTER TABLE MSAF_DFE.DFE_HISTORICO_CONSUMO_INDEVIDO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                 
ALTER TABLE A_RAIABD.TB_TELEVENDA_HIST_ENDERECO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                     
ALTER TABLE MSAF_DFE.DATABASECHANGELOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                              
ALTER TABLE MSAF_DFE.AUT_USUARIO_HISTORICO_ACESSO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                   
ALTER TABLE A_RAIABD.TB_TP_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                                      
ALTER TABLE A_RAIABD.TB_TELEVENDA_MSG_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                           
ALTER TABLE A_RAIABD.TB_SCHEDULER_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                               
ALTER TABLE A_RAIABD.TB_SAP_WORKFLOW_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                            
ALTER TABLE A_RAIABD.TB_PRODUTO_ESTOQ_DIA_HIST2 MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                     
ALTER TABLE A_RAIABD.TB_MRD_HISTORICO_INDISPONIVEL MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                  
ALTER TABLE A_RAIABD.TB_LOG_HISTORICO_FECHAMENTO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                    
ALTER TABLE A_RAIABD.TB_LOCAL_ARQUIVO_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                           
ALTER TABLE A_RAIABD.TB_HISTORICO_NF MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                           
ALTER TABLE A_RAIABD.TB_HISTORICO_ITENS MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                             
ALTER TABLE A_RAIABD.TB_HISTORICO_CONTABIL_COMPL MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                    
ALTER TABLE A_RAIABD.TB_HISTORICO_CONTABIL MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                          
ALTER TABLE A_RAIABD.TB_FATURAMENTO_HISTORICO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                
ALTER TABLE A_RAIABD.TB_AUDIT_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                                   
ALTER TABLE USR_MS_ASSINA.TB_ASSINATURA_HISTORICO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                 
ALTER TABLE MSAF_DFE.DFE_PASS_PORTARIA_HIST_NFE MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                     
ALTER TABLE MSAF_DFE.DFE_HISTORICO_RELATORIO_PROCES MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                 
ALTER TABLE MSAF_DFE.DFE_HISTORICO_RELATORIO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                        
ALTER TABLE MSAF_DFE.DFE_HISTORICO_NFS MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                              
ALTER TABLE MSAF_DFE.DFE_HISTORICO_MIGRACAO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                         
ALTER TABLE MSAF_DFE.DFE_HISTORICO_EVENTO_CTE MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                       
ALTER TABLE MSAF_DFE.DFE_HISTORICO_CCE_NFE MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                          
ALTER TABLE MSAF_DFE.DFE_HISTORICO_ARQUIVO_RETORNO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                  
ALTER TABLE SYSTEM.ACTIVE_SESSION_HIST_20241211_9059 MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;              
ALTER TABLE A_RAIABD.TB_TP_OPER_FISCAL_HIST_GRUPO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;                                   
ALTER TABLE SYSTEM.ACTIVE_SESSION_HIST_20240814_11226 MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;             

ALTER SESSION ENABLE PARALLEL DML;

-- 2G a 10G --
ALTER TABLE MSAF_DFE.DFE_HISTORICO_WS_DISTRIBUICAO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 4;                  
ALTER TABLE A_RAIABD.TB_STIX_RESGATE_PDV_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 4;                        
ALTER TABLE A_RAIABD.TB_PEDIDO_COMPRA_HISTORICO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 4;                     
ALTER TABLE A_RAIABD.TB_ABACOS_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 4;                                  
ALTER TABLE A_RAIABD.TB_ITMKT_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 4;                                   
ALTER TABLE A_RAIABD.TB_CAT_ARQUIVO_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES;

-- 10G a 40G --
ALTER TABLE A_RAIABD.TB_AUDITORIA_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 10;                               
ALTER TABLE A_RAIABD.TB_PBM_ARQUIVOS_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 10;                            
ALTER TABLE A_RAIABD.TB_SALDO_NUMERARIO_LOG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 10;                       
ALTER TABLE USR_MS_PEDSYNC.TB_PEDIDO_HISTORICO_STATUS MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 10;                     
ALTER TABLE A_RAIABD.TB_CLIENTE_LGPD_HIST_COMPLETO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 10;                  
ALTER TABLE MSAF_DFE.DFE_HISTORICO_RPS MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 10;                              

-- 197.55G --                          
ALTER TABLE A_RAIABD.TB_PRODUTO_ESTOQUE_DIA_HIST_CG MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 20;                

-- 230.53G --              
ALTER TABLE MSAF_DFE.DFE_HISTORICO_NFE  MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 25;  

-- 427.07G --
ALTER TABLE A_RAIABD.TB_TELEVENDA_STATUS_HISTORICO MOVE TABLESPACE RD_DADOS ONLINE UPDATE INDEXES PARALLEL 30; 


-- INDEX 

alter index A_RAIABD.SYS_IL0000205834C00007$$ rebuild tablespace RD_INDEX online;         
alter index A_RAIABD.SYS_IL0000205834C00006$$ rebuild tablespace RD_INDEX online;         
alter index A_RAIABD.SYS_IL0000309951C00003$$ rebuild tablespace RD_INDEX online;         
alter index A_RAIABD.SYS_IL0000460660C00007$$ rebuild tablespace RD_INDEX online;         
alter index MSAF_DFE.PK_DFE_PASS_PORTARIA_HIST_NFE rebuild tablespace RD_INDEX online;   
alter index MSAF_DFE.PK_DFE_HISTORICO_EVENTO_CTE rebuild tablespace RD_INDEX online;      
alter index MSAF_DFE.PK_DFE_HISTORICO_PROC_MIGRACAO rebuild tablespace RD_INDEX online;   
alter index MSAF_DFE.PK_DFE_HISTORICO_MIGRACAO rebuild tablespace RD_INDEX online;        
alter index MSAF_DFE.PK_DFE_HISTORICO_RELATORIO_PRO rebuild tablespace RD_INDEX online;   
alter index MSAF_DFE.PK_DFE_HIST_CONSUMO_INDEVIDO rebuild tablespace RD_INDEX online;     
alter index MSAF_DFE.IDX_DFE_HISTORICO_EV_NFE_ID rebuild tablespace RD_INDEX online;      
alter index A_RAIABD.SYS_IL0001723937C00020$$ rebuild tablespace RD_INDEX online;       
alter index A_RAIABD.SYS_IL0001378777C00020$$ rebuild tablespace RD_INDEX online;     
alter index MSAF_DFE.IDX_DFE_HIST_PROC_MIGRACAO_ID rebuild tablespace RD_INDEX online;   
alter index A_RAIABD.TB_LOG_HISTORICO_FECHAMENTO_PK rebuild tablespace RD_INDEX online;  
alter index MSAF_DFE.IDX_DFE_HIST_EVENTO_CTE_ID rebuild tablespace RD_INDEX online;       
alter index MSAF_DFE.IDX_DFE_HIST_EV_CTE_LOB_ID rebuild tablespace RD_INDEX online; 


SET ECHO OFF
SET TIMING OFF


--==========================================================
-- 9) Configurando Module/Action (Para rastreabilidade)
--==========================================================


EXEC dbms_application_info.set_module( module_name => 'DBA - Pedro Vido Acc - SQLPLUS', action_name => 'Atividade CHG0081181 - Realizando validacoes Pos MOVE ...');



prompt 
prompt
set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '  TBS DEPOIS  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt
prompt

col owner for a15
col tablespace_name for a20
col table_name for a40
col status for a10
select table_name, owner, tablespace_name, degree, status from dba_tables where tablespace_name = 'RD_DADOS'
and table_name in ('TB_TELEVENDA_STATUS_HISTORICO','DFE_HISTORICO_NFE','TB_PRODUTO_ESTOQUE_DIA_HIST_CG','TB_AUDITORIA_LOG','TB_PBM_ARQUIVOS_LOG','TB_SALDO_NUMERARIO_LOG',
'TB_PEDIDO_HISTORICO_STATUS','TB_CLIENTE_LGPD_HIST_COMPLETO','DFE_HISTORICO_RPS','DFE_HISTORICO_WS_DISTRIBUICAO','TB_STIX_RESGATE_PDV_LOG','TB_PEDIDO_COMPRA_HISTORICO','TB_ABACOS_LOG','TB_ITMKT_LOG','TB_CAT_ARQUIVO_LOG','TB_PBM_LOG','TB_NGC_HISTORICO',
'TB_CML_LOG','TB_CLIENTE_HISTORICO','DFE_HISTORICO_PROC_MIGRACAO','ACTIVE_SESSION_HIST_20240814_11226',       
'TB_CCRAIA_CLIENTE_HISTORICO','TB_PEDIDO_SYNC_LOG','TB_CHEQUE_HISTORICO','CUST01_HIST_BI','TB_STIX_RESGATE_LOG','TB_MAG_LOG','TB_IMPROPRIO_HIST_GUIA_ITEM','TB_CEP_LOG','TB_HIST_RECEITA_RETORNO_PESQ','DFE_HISTORICO_EVENTO_NFE','TB_SPED_ESCRITURACAO_LOG',         
'DFE_HISTORICO_CONSUMO_INDEVIDO','TB_TELEVENDA_HIST_ENDERECO','DATABASECHANGELOG','AUT_USUARIO_HISTORICO_ACESSO','TB_TP_LOG','TB_TELEVENDA_MSG_LOG','TB_SCHEDULER_LOG','TB_SAP_WORKFLOW_LOG','TB_PRODUTO_ESTOQ_DIA_HIST2','TB_MRD_HISTORICO_INDISPONIVEL',      
'TB_LOG_HISTORICO_FECHAMENTO','TB_LOCAL_ARQUIVO_LOG','TB_HISTORICO_NF','TB_HISTORICO_ITENS','TB_HISTORICO_CONTABIL_COMPL','TB_HISTORICO_CONTABIL','TB_FATURAMENTO_HISTORICO','TB_AUDIT_LOG','TB_ASSINATURA_HISTORICO','DFE_PASS_PORTARIA_HIST_NFE',         
'DFE_HISTORICO_RELATORIO_PROCES','DFE_HISTORICO_RELATORIO','DFE_HISTORICO_NFS','DFE_HISTORICO_MIGRACAO','DFE_HISTORICO_EVENTO_CTE','DFE_HISTORICO_CCE_NFE','DFE_HISTORICO_ARQUIVO_RETORNO','ACTIVE_SESSION_HIST_20241211_9059','TB_TP_OPER_FISCAL_HIST_GRUPO');
prompt
prompt


set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '  INDEXES DEPOIS  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;
prompt
prompt

set lines 9999 pages 9999
col owner for a25
col index_name for a40
col index_type for a10
col table_owner for a40
col tablespace_name for a15
col status for a10
select owner, index_name, index_type, table_owner, table_name, tablespace_name,degree, status from dba_indexes where tablespace_name = 'RD_INDEX'
and table_name in ('TB_TELEVENDA_STATUS_HISTORICO','DFE_HISTORICO_NFE','TB_PRODUTO_ESTOQUE_DIA_HIST_CG','TB_AUDITORIA_LOG','TB_PBM_ARQUIVOS_LOG','TB_SALDO_NUMERARIO_LOG',
'TB_PEDIDO_HISTORICO_STATUS','TB_CLIENTE_LGPD_HIST_COMPLETO','DFE_HISTORICO_RPS','DFE_HISTORICO_WS_DISTRIBUICAO','TB_STIX_RESGATE_PDV_LOG','TB_PEDIDO_COMPRA_HISTORICO','TB_ABACOS_LOG','TB_ITMKT_LOG','TB_CAT_ARQUIVO_LOG','TB_PBM_LOG','TB_NGC_HISTORICO',
'TB_CML_LOG','TB_CLIENTE_HISTORICO','DFE_HISTORICO_PROC_MIGRACAO','ACTIVE_SESSION_HIST_20240814_11226',       
'TB_CCRAIA_CLIENTE_HISTORICO','TB_PEDIDO_SYNC_LOG','TB_CHEQUE_HISTORICO','CUST01_HIST_BI','TB_STIX_RESGATE_LOG','TB_MAG_LOG','TB_IMPROPRIO_HIST_GUIA_ITEM','TB_CEP_LOG','TB_HIST_RECEITA_RETORNO_PESQ','DFE_HISTORICO_EVENTO_NFE','TB_SPED_ESCRITURACAO_LOG',         
'DFE_HISTORICO_CONSUMO_INDEVIDO','TB_TELEVENDA_HIST_ENDERECO','DATABASECHANGELOG','AUT_USUARIO_HISTORICO_ACESSO','TB_TP_LOG','TB_TELEVENDA_MSG_LOG','TB_SCHEDULER_LOG','TB_SAP_WORKFLOW_LOG','TB_PRODUTO_ESTOQ_DIA_HIST2','TB_MRD_HISTORICO_INDISPONIVEL',      
'TB_LOG_HISTORICO_FECHAMENTO','TB_LOCAL_ARQUIVO_LOG','TB_HISTORICO_NF','TB_HISTORICO_ITENS','TB_HISTORICO_CONTABIL_COMPL','TB_HISTORICO_CONTABIL','TB_FATURAMENTO_HISTORICO','TB_AUDIT_LOG','TB_ASSINATURA_HISTORICO','DFE_PASS_PORTARIA_HIST_NFE',         
'DFE_HISTORICO_RELATORIO_PROCES','DFE_HISTORICO_RELATORIO','DFE_HISTORICO_NFS','DFE_HISTORICO_MIGRACAO','DFE_HISTORICO_EVENTO_CTE','DFE_HISTORICO_CCE_NFE','DFE_HISTORICO_ARQUIVO_RETORNO','ACTIVE_SESSION_HIST_20241211_9059','TB_TP_OPER_FISCAL_HIST_GRUPO');
prompt
prompt


set heading OFF;

prompt
prompt
select '-----------------------------------------' from dual;
select '   CONSUMO TBS DEPOIS  ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;

prompt 
prompt 

COL TABLESPACE   FOR A35          HEADING 'Tablespace'
COL TBS_SIZE     FOR 999,999,990  HEADING 'Tamanho|atual'       JUSTIFY RIGHT
COL TBS_EM_USO   FOR 999,999,990  HEADING 'Em uso'              JUSTIFY RIGHT
COL TBS_MAXSIZE  FOR 999,999,990  HEADING 'Tamanho|maximo'      JUSTIFY RIGHT
COL FREE_SPACE   FOR 999,999,990  HEADING 'Espaco|livre atual'  JUSTIFY RIGHT
COL SPACE        FOR 999,999,990  HEADING 'Espaco|livre total'  JUSTIFY RIGHT
COL PERC         FOR 990          HEADING '%|Ocupacao'          JUSTIFY RIGHT
--set wrap off
set lines 145
set pages 999
set verify off

break on report on tablespace_name skip 1
compute sum label "Total: " of tbs_em_uso tbs_size tbs_maxsize free_space space on report

select /*+ RULE */ d.tablespace,
       trunc((d.tbs_size-nvl(s.free_space, 0))/1024/1024) tbs_em_uso,
       trunc(d.tbs_size/1024/1024) tbs_size,
       trunc(d.tbs_maxsize/1024/1024) tbs_maxsize,
       trunc(nvl(s.free_space, 0)/1024/1024) free_space,
       trunc((d.tbs_maxsize - d.tbs_size + nvl(s.free_space, 0))/1024/1024) space,
       trunc((d.tbs_size-nvl(s.free_space, 0))*100/d.tbs_maxsize) perc
from
  ( select /*+ RULE */ SUM(bytes) tbs_size,
           SUM(decode(sign(maxbytes - bytes), -1, bytes, maxbytes)) tbs_maxsize,
           tablespace_name tablespace
    from ( select /*+ RULE */ nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_data_files
           union all
           select /*+ RULE */ nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_temp_files
         )
    group by tablespace_name
  ) d,
  ( select /*+ RULE */ SUM(bytes) free_space,
           tablespace_name tablespace
    from dba_free_space
    group by tablespace_name
  ) s
where d.tablespace = s.tablespace(+)
and d.tablespace = 'RAIADADOS'
order by 7 desc;


set heading OFF;
prompt
prompt
select '-----------------------------------------' from dual;
select '   Horario de termino da execucao ' from dual;
select '-----------------------------------------' from dual;
prompt
set heading ON;

select sysdate from dual;

prompt
prompt


spool off;




--------------------------- FIM SCRIPT -----------------------------



--===========================================
-- Outros comandos -- Index
--===========================================

(Executar o resultado do select abaixo)

SELECT 
'ALTER INDEX ' || owner || '.' || index_name ||
' REBUILD TABLESPACE RD_DADOS PARALLEL 25;' AS script
FROM dba_indexes
WHERE (table_owner, table_name) IN (
('A_RAIABD','TB_TELEVENDA_STATUS_HISTORICO'),
('MSAF_DFE','DFE_HISTORICO_NFE'),
('A_RAIABD','TB_PRODUTO_ESTOQUE_DIA_HIST_CG'),
('A_RAIABD','TB_AUDITORIA_LOG'),
('A_RAIABD','TB_PBM_ARQUIVOS_LOG')
);

(Executar o resultado do select abaixo)

SELECT 
'ALTER INDEX ' || owner || '.' || index_name || ' NOPARALLEL;' AS script
FROM dba_indexes
WHERE (table_owner, table_name) IN (
('A_RAIABD','TB_TELEVENDA_STATUS_HISTORICO'),
('MSAF_DFE','DFE_HISTORICO_NFE'),
('A_RAIABD','TB_PRODUTO_ESTOQUE_DIA_HIST_CG'),
('A_RAIABD','TB_AUDITORIA_LOG'),
('A_RAIABD','TB_PBM_ARQUIVOS_LOG')
);