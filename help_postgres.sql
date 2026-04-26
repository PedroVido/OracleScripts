/* ADM POSTGREE*/

--1) ACESSO ==================================================================
--
--
--===================================
--1.1) Conectar no ambiente
--===================================
--
-- iniciar postgres
--
--sudo service postgresql start
--
-- mudar para user do postgres
--
--sudo -i -u postgres
--
-- conectar no postgres
--
--psql
--
-- listar bancos disposniveis
--
--\l
--
-- conecantando no banco 
--
--\c <databasename>
--
-- testar conexao | ver a versao
--
--SELECT version();
--
--===================================
--2) ALERT 
--===================================
--
--/var/log/postgresql# tail -f postgresql-10-main.log
--
--
--===================================
--3) LOCK 
--===================================
--
--
--SELECT blocked_locks.pid AS blocked_pid,
--       blocked_activity.query AS blocked_query,
--       blocking_locks.pid AS blocking_pid,
--       blocking_activity.query AS blocking_query
--FROM pg_locks blocked_locks
--JOIN pg_stat_activity blocked_activity
--  ON blocked_locks.pid = blocked_activity.pid
--JOIN pg_locks blocking_locks
--  ON blocked_locks.locktype = blocking_locks.locktype
-- AND blocked_locks.database IS NOT DISTINCT FROM blocking_locks.database
-- AND blocked_locks.relation IS NOT DISTINCT FROM blocking_locks.relation
-- AND blocked_locks.page IS NOT DISTINCT FROM blocking_locks.page
-- AND blocked_locks.tuple IS NOT DISTINCT FROM blocking_locks.tuple
-- AND blocked_locks.transactionid IS NOT DISTINCT FROM blocking_locks.transactionid
-- AND blocked_locks.classid IS NOT DISTINCT FROM blocking_locks.classid
-- AND blocked_locks.objid IS NOT DISTINCT FROM blocking_locks.objid
-- AND blocked_locks.objsubid IS NOT DISTINCT FROM blocking_locks.objsubid
--JOIN pg_stat_activity blocking_activity
--  ON blocking_locks.pid = blocking_activity.pid
--WHERE NOT blocked_locks.granted;
--
--
--

--===================================
-- CRIANDO USER 
--===================================

Step 2: Creating a New User
To create a new user, use the following SQL command within the PostgreSQL terminal:

CREATE USER your_new_username WITH ENCRYPTED PASSWORD 'your_password';

Note: this makes the password encrypted with MD5 (minimum recommended).

Replace your_new_username and your_password with the desired username and password for the new user.

If you want to grant superuser privileges to the newly created user (should only be granted as needed), alter the user with the following command:

ALTER USER your_new_username WITH SUPERUSER;

Step 3: Granting Permissions
Grant necessary permissions to the user by using the GRANT statement. For example, to grant all privileges on a specific database:

GRANT ALL PRIVILEGES ON DATABASE your_database_name TO your_new_username;

Adjust the privileges and database name according to your requirements.



Step 4: Verifying User Creation
To verify that the user has been created successfully, you can use the following SQL command:

SELECT * FROM pg_user WHERE usename = 'your_new_username';

This command will display the details of the newly created user.

--===================================
-- CRIANDO ROLE 
--===================================

Making use of user-defined roles to simplify management
Additional flexibility in PostgreSQL user management is provided by user-defined roles. A more individualized and modular approach to access control is made possible by the ability for administrators to create roles that are specific to projects or business units.

CREATE ROLE marketing_team; 

 GRANT SELECT ON ALL TABLES IN SCHEMA public TO marketing_team;

 CREATE ROLE sales_team; 

 GRANT sales_team TO sales_example_user;