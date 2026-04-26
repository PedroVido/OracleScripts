-----------------------------------------------------------------------------------------------------------
--
-- Header:    	ddlusr.sql	10-jun-2013.12:50   $   FSX Scripts - Flavio Soares X Scripts
--
-- Filename:  	ddlusr.sql	
--
-- Version:   	v1.0
-- 
-- Purpose:   	Prints the DDL create for the given username.
-- 
-- Modified:  	
--  
-- Notes:     	
--
-- Usage:     	SQL> @ddlusr [ % | <% tablespace_name %> ]
--
--            	SQL> @ddlusr %            	-> print all username
--            	SQL> @ddlusr sys%  	        -> print all username sys%
--            	SQL> @ddlusr dbnsmp     	-> print the username dbnsmp
--
-- Others:    	
--
-- Author:    	Flavio Soares 
-- Copyright: 	(c) Flavio Soares - http://flaviosoares.com - All rights reserved.
--
-----------------------------------------------------------------------------------------------------------

--@saveset

SET LONG 999999 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
COLUMN DDL FORMAT A1000

BEGIN
   DBMS_METADATA.SET_TRANSFORM_PARAM (DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
   DBMS_METADATA.SET_TRANSFORM_PARAM (DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', TRUE);
END;
/
 
variable v_username VARCHAR2(30);

--exec:v_username := upper('&1');

select dbms_metadata.get_ddl('USER', u.username) AS ddl
from   dba_users u
where  u.username = upper('&1')
union all
select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA', tq.username) AS ddl
from   dba_ts_quotas tq
where  tq.username = upper('&&1')
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('ROLE_GRANT', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee = upper('&&1')
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', sp.grantee) AS ddl
from   dba_sys_privs sp
where  sp.grantee = upper('&&1')
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('OBJECT_GRANT', tp.grantee) AS ddl
from   dba_tab_privs tp
where  tp.grantee = upper('&&1')
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('DEFAULT_ROLE', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee = upper('&&1')
and    rp.default_role = 'YES'
and    rownum = 1
union all
select to_clob('/* Start profile creation script in case they are missing') AS ddl
from   dba_users u
where  u.username = upper('&&1')
and    u.profile <> 'DEFAULT'
and    rownum = 1
union all
select dbms_metadata.get_ddl('PROFILE', u.profile) AS ddl
from   dba_users u
where  u.username = upper('&&1')
and    u.profile <> 'DEFAULT'
union all
select to_clob('End profile creation script */') AS ddl
from   dba_users u
where  u.username = upper('&&1')
and    u.profile <> 'DEFAULT'
and    rownum = 1
/


--@loadset
