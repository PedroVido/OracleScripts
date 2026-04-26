-- HELP ADRCI - PACKAGES FOR ORACLE SUPPORT


-- Encontrar o erro a qual quer gerar o pacote de evidencias


alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
set lines 9999 pages 9999
col originating_timestamp format a35
col message_text format a100
select distinct
   to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY HH24:MI') as DATA_ALERTA,
   message_text
from x$dbgalertext
where originating_timestamp > (sysdate-1)
and message_text like '%ORA%'
order by DATA_ALERTA asc;


-- Erro encontrado 

29-03-2026 07:03 Errors in file /u01/app/oracle/diag/rdbms/dbdownp_oci/dbdownp/trace/dbdownp_ora_1009745.trc  (incide
                 nt=315887):
                 ORA-00603: ORACLE server session terminated by fatal error
                 ORA-24557: error 600 encountered while handling error 600; exiting server process
                 ORA-00600: internal error code, arguments: [kghfrh:ds], [0x7FB21696EC98], [], [], [], [], [], [], []
                 , [], [], []
                 ORA-00600: internal error code, arguments: [kghfrh:ds], [0x7FB21696EC98], [], [], [], [], [], [], []
                 , [], [], []
                 ORA-00600: internal error code, arguments: [25027], [0], [1], [42], [0], [1439], [339244], [], [], [
                 ], [], []

---> Incidente do erro - 315887

-- ADRCI 

--=============================================================================
-- 1) Logar no ADRCI (Com user oracle e variaveis de ambientes configuradas)
--=============================================================================

adrci 

--=============================================================================
-- 2) Ver oracle base e oracle home
--=============================================================================

[oracle@lncdownstreamprd01-Linux-dbdownp]/home/oracle> adrci

ADRCI: Release 19.0.0.0.0 - Production on Mon Mar 30 19:16:10 2026

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

ADR base = "/u01/app/oracle"
adrci> show base
ADR base is "/u01/app/oracle"
adrci> show home
ADR Homes:
diag/diagtool/user_oracle/adrci_3305663570_110
diag/rdbms/dbdownp_oci/dbdownp
diag/kfod/lncdownstreamprd01/kfod
diag/asmcmd/user_oracle/lncdownstreamprd01
diag/tnslsnr/lncdownstreamprd01/listener
diag/tnslsnr/lncdownstreamprd01/msaf
diag/clients/user_oracle/host_3305663570_110
diag/clients/user_oracle/RMAN_3305663570_110
diag/clients/user_oracle/host_3305663570_82
diag/clients/user_root/host_3305663570_110
adrci>

--=============================================================================
-- 3) Setar a home desejada 
--=============================================================================

adrci> set home diag/rdbms/dbdownp_oci/dbdownp

--=============================================================================
-- 4) ver alert
--=============================================================================

adrci> show alert -tail 100

--=============================================================================
-- 5) Ver incidentes 
--=============================================================================

adrci> show incident

--=============================================================================
-- 6) Criar um pacote para os arquivos do incidente desejado
--=============================================================================


adrci> IPS CREATE PACKAGE INCIDENT 315887
Created package 803 based on incident id 315887, correlation level typical

-- OU 

adrci> ips pack incident 315887 in /tmp

-- OU criar um pacote vazio 

adrci> IPS CREATE PACKAGE

-- add the necessary incident files. ( package_number will be displayed in the above command)

adrci> IPS ADD INCIDENT incident_number PACKAGE 2

adrci> IPS ADD FILE /u01/app/oracle/alert_db.log PACKAGE 2

-- Now generate the package file.

adrci>IPS GENERATE PACKAGE 2 IN /home/dbaclass/housekeeping

--=============================================================================
-- 7) ver pacote gerado para o incidente 
--=============================================================================
-- Mostra todos
ips show package

-- Mosta o especifico
ips show package 803
ips show package 803 detail


--=============================================================================
-- 8) Gerar o pacote zipado para enviar para o MOS 
--=============================================================================

adrci> IPS GENERATE PACKAGE 803 IN /tmp
Generated package 803 in file /tmp/ORA603_20260330184255_COM_1.zip, mode complete

--=============================================================================
-- 9) Unpack a ips file
--=============================================================================

adrci> ips unpack file ORA_98928.zip into /tmp/housekeeping

--=============================================================================
-- 10) Pack all incident files within a particular time frame
--=============================================================================

--Generates the package with the incidents occurred between the times '2019-05-01 12:00:00.00' and '2019-05-02 23:00:00.00'

ips pack time '2019-05-01 12:00:00.00' to '2019-05-02 23:00:00.00'


--=============================================================================
-- 11) Purge alerts and trace files
--=============================================================================

-- This will purge data older than 600 minutes.

adrci> purge -age 600 -type ALERT
adrci> purge -age 600 -type TRACE
adrci> purge -age 600 -type incident
adrci> purge -age 10080 -type cdump

-- Set control policy for auto purge of files

There are two types of policies,

LONGP_POLICY is used to purge below data . Default value is 365 days.

• ALERT
• INCIDENT
• SWEEP
• STAGE
• HM

SHORTP_POLICY  is used to purge for below data Default value is 30 days.

• TRACE
• CDUMP
• UTSCDMP
• IPS

-- Get existing control policy

adrci> show control


-- Change default value of control policy details.

-- Set in hours.

adrci> set control (SHORTP_POLICY = 240)
adrci> set control (LONGP_POLICY = 600)
