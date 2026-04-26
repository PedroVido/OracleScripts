-- ########################################################################################################
--                                                                                                       --
-- File Name     : mysql_toolkit.sql                                                                     --
-- Description   : Commands to use on MySQL databases                                                    --
-- Comments      : Version - V1                                                                          --
-- Requirements  : Access to the V$ and DBA views.                                                       --
-- Call Syntax   : N/A                                                                                   --
-- Last Modified : 21/03/2025                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


-- WAYS TO CONNECT --

0- COnnects to the local MySQL server user and password whitout prompt for it (**Not RECOMMENDED**)

mysql -h localhost -udba -p*Testepwdba2020

1- Connects to the local MySQL server via socket /tmp/mysql.sock as the specified user and prompts for a password.

mysql -u username -p
mysql –u root –p

2- Connects to the MySQL server on the specified host at port 3306 and prompts for a password.

mysql -u username -p -h hostname

3- Connects to the MySQL server on the specified host and port and prompts for a password.

mysql -u username -p -h hostname -P portnumber

4- Connects to the specified database on the specified host and port as the specified user and prompts for a password.

mysql -u username -p -h hostname -P portnumber -D databasename
-- can also omit -D
mysql -u username -p -h hostname -P portnumber databasename


-- VARIABLES --

1- Examples to how see the values of some varibles or one of them

SHOW STATUS LIKE 'max_used_connections';
SHOW VARIABLES LIKE "max_connections";
SHOW VARIABLES LIKE "%max%";
SHOW GLOBAL VARIABLES LIKE "max_connections";
SHOW SESSION VARIABLES LIKE "max_connections";


2- Alter variable's value without reboot (until the reboot) '

  -> Log as root:
     mysql –u root –p
  -> Command : 
     SET GLOBAL max_connections = 512;


3- Alter variable's value permanently '

   -> Edit conf file:
      vi /etc/my.cnf
   -> Find parameter you want to modify: 
      max_connections = 512


-- STATUS DATABASE --

1- Ver infos do banco :
 
status

Example :      
          mysql> status
          --------------
          mysql  Ver 8.0.33 for Linux on x86_64 (MySQL Community Server - GPL)

          Connection id:          71741
          Current database:
          Current user:           dba@localhost
          SSL:                    Not in use
          Current pager:          stdout
          Using outfile:          ''
          Using delimiter:        ;
          Server version:         8.0.33 MySQL Community Server - GPL
          Protocol version:       10
          Connection:             Localhost via UNIX socket
          Server characterset:    utf8mb4
          Db     characterset:    utf8mb4
          Client characterset:    utf8mb4
          Conn.  characterset:    utf8mb4
          UNIX socket:            /var/lib/mysql/mysql.sock
          Binary data as:         Hexadecimal
          Uptime:                 2 hours 50 min 13 sec

          Threads: 101  Questions: 157325507  Slow queries: 34251  Opens: 8914  Flush tables: 3  Open tables: 4000  Queries per second avg: 15404.436
          --------------



-- RUN COMMANDS --

1- Run a single command - mysql -e# --> Use -e to execute a single statement.

mysql -u username -p -h hostname -P portnumber databasename -e "SELECT 1"


2- Alternatively, you can pipe the statements from a file.

mysql -u username -p -h hostname -P portnumber databasename < filename.sql



-- LIST DATABASES --

1- List all databases 

mysql> SHOW DATABASES;

-- Support LIKE
mysql> SHOW DATABASES LIKE '%schema';


-- SWITCH TO ANOTHER DATABASE --

mysql> USE mysql

        Database changed


-- TABLES --

1- List all tables under a database

-- Support LIKE
mysql> SHOW TABLES LIKE 'teste%';


2- Describe table schema

mysql> DESCRIBE teste;

-- DESC also works
mysql> DESC teste;



-- GRANTS --

1- List user and grants -> SHOW GRANTS [FOR user_or_role [USING role [, role] ...]]

-- Show grants for the current user
mysql> SHOW GRANTS;

-- Show grants for a particular user
mysql> SHOW GRANTS FOR root@localhost;

-- List all users and grants
mysql> SELECT User, Host, Grant_priv, Super_priv FROM mysql.user;



-- CONNECTIONS --

1- Show connections

-- Without the FULL keyword, SHOW PROCESSLIST displays only the first 100 characters of each statement in the Info field.
mysql> SHOW PROCESSLIST;
mysql> SHOW FULL PROCESSLIST;

-- If you want to apply filtering, then query the underlying INFORMATION_SCHEMA.PROCESSLIST table.
mysql> SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST WHERE USER = 'root';


2- Kill - KILL [CONNECTION | QUERY] processlist_id

-- connection - It terminates the connection associated with the given processlist_id, after terminating any statement the connection is executing
mysql> KILL 321;

-- query - terminates the statement the connection is currently executing, but leaves the connection itself intact. This can be useful if you have a specific query that is causing issues or is taking too long to execute, and you want to terminate only that query without affecting other queries or processes running on the same connection.

mysql> KILL QUERY 321;


-- TIPS --

1- Displaying query results vertically

-- Some query results are much more readable when displayed vertically using \G.
mysql> SHOW GRANTS\G;
