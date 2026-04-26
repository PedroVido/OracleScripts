
--=====================================
-- ERRO 
--=====================================

[oracle@lxorcsjp1 ~]$ emctl status agent
EM Configuration issue. /u01/app/oracle/product/11.2.0/db/lxorcsjp1_dbsjppd not found.

--=====================================
-- Setar variavel
--=====================================

SQL> SELECT name, DB_UNIQUE_NAME FROM v$database;

NAME      DB_UNIQUE_NAME
--------- ------------------------------
DBSJPPD   dbsjppd

SQL>

export ORACLE_UNQNAME=dbsjppd

--=====================================
-- Setar home do agent EM
--=====================================

export AGENT_HOME=/u01/app/oracle/product/agent/13.5.0.0.0/agent_13.5.0.0.0/bin

$AGENT_HOME/emctl status agent
$AGENT_HOME/emctl getversion

[oracle@lxorcsjp1 bin]$ $AGENT_HOME/emctl status agent
Oracle Enterprise Manager Cloud Control 13c Release 5
Copyright (c) 1996, 2021 Oracle Corporation.  All rights reserved.
---------------------------------------------------------------
Agent is Not Running


--=====================================
-- Disable autostart EM Control
--=====================================

Disable Automatic Startup of OEM (OMS and Agent)


vi /etc/oragchomelist

 Comment "#" out the home directory entries.

 

Example:

[oracle@hostname ~]$ vi /etc/oragchomelist

#/opt/oracle/middleware_13.2
#/opt/oracle/agent_13.2/agent_13.2.0.0.0:/opt/oracle/agent_13.2/agent_inst
#/opt/oracle/product/agent13c/agent_13.2.0.0.0:/opt/oracle/product/agent13c/agent_inst

Save and exit