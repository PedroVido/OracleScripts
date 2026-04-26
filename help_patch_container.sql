--==============================================
-- Patch container database 
--==============================================

-- You will patch CDB19 to 19.28 and use an existing Oracle home.

-- 1) Set the environment to the CDB19 database and connect.

. cdb19

-- Start the database.

sql / as sysdba
startup

-- 2) Create a new PDB.

create pluggable database indigo admin user admin identified by oracle;

--Check the current version.

select version_full from v$instance;

-- 3) Shut down the database, so you can patch it to 19.28.

shutdown immediate

-- You must shut down a single instance database to patch it. In contrast, if it was an Oracle RAC Database, you could patch it using the RAC Rolling method without downtime.

-- Exit SQLcl.

exit

--Move the SPFile and password file to the new Oracle home.

export NEW_ORACLE_HOME=/u01/app/oracle/product/19_28
export OLD_ORACLE_HOME=/u01/app/oracle/product/19
mv $OLD_ORACLE_HOME/dbs/spfileCDB19.ora $NEW_ORACLE_HOME/dbs
mv $OLD_ORACLE_HOME/dbs/orapwCDB19 $NEW_ORACLE_HOME/dbs

/*
In this lab, there is no PFile, so we don't need to move that one.
Also, there are no network files, like tnsnames.ora and sqlnet.ora in $ORACLE_HOME/network/admin so we don't move those either.
There might be many other files in the Oracle home. Check the blog post Files to Move During Oracle Database Out-Of-Place Patching for details.
You need to set the environment to the new Oracle home. Update the profile script and reset the environment.
*/


Copysed -i 's|^ORACLE_HOME=.*|ORACLE_HOME=/u01/app/oracle/product/19_28|' /usr/local/bin/cdb19
. cdb19
env | grep ORA


-- Update /etc/oratab to reflect the new Oracle home.

Copysed 's|^CDB19:.*|CDB19:/u01/app/oracle/product/19_28:Y|' /etc/oratab > /tmp/oratab
cat /tmp/oratab > /etc/oratab
grep "CDB19" /etc/oratab


-- Connect to the database.

sql / as sysdba


--4) Start the database instance and check PDBs.

startup
show pdbs

-- Notice how the INDIGO PDB doesn't start because you didn't save the state.


SQL> startup
ORACLE instance started.

Total System Global Area 4294966064 bytes
Fixed Size                  9186096 bytes
Variable Size             838860800 bytes
Database Buffers         3439329280 bytes
Redo Buffers                7589888 bytes
Database mounted.
Database opened.
SQL> show pdbs

    CON_ID CON_NAME      OPEN MODE  RESTRICTED
---------- ------------- ---------- ----------
         2 PDB$SEED      READ ONLY  NO
         3 INDIGO        MOUNTED
         4 ORANGE        READ WRITE NO


-- Exit SQLcl.

exit


-- 5) Run Datapatch to apply the SQL changes to the database. It takes a few minutes to apply the patches. Wait for Datapatch to complete.

$ORACLE_HOME/OPatch/datapatch

/*
Datapatch patches only the open PDBs. It prints a warning for the INDIGO PDB.
Warning: PDB INDIGO is in mode MOUNTED and will be skipped.
Scroll through the output and see how Datapatch applies changes to all containers, including CDB$ROOT and PDB$SEED.
*/

-- Connect to the database.

sql / as sysdba

-- Open the INDIGO PDB.

alter pluggable database indigo open;

--The PDB opens with errors.

--Examine the error happening while opening the INDIGO PDB.

select cause, type, message
from   pdb_plug_in_violations
where  name='INDIGO' and status!='RESOLVED';

/*
The PDB won't open because it hasn't been properly patched.
The dictionary version of the CDB$ROOT and the PDB are now different and must be aligned.
Datapatch skipped the PDB because it was not open.
Although the PDB is open, it is in restricted mode. Only users with restricted session privilege can connect.
*/

show pdbs

/*
Notice YES in the RESTRICTED column of INDIGO.
Datapatch can patch a PDB as long as it is open READ WRITE. Even if a PDB is open in RESTRICTED mode, you can still patch it with Datapatch.
*/

 -- 6) You can override this behavior and force the database to open unpatched PDBs.

alter system set "_pdb_datapatch_violation_restricted"=false;
alter pluggable database indigo close;
alter pluggable database indigo open;

/*
Notice that INDIGO now opens without errors.
Use this underscore parameter with caution! Although the PDB opens unrestricted, it is still unpatched.
Although you can use the parameter to forcefully open the PDB and allow users to connect, you must still complete the patching process.
*/

-- Check the status of the PDB.

show pdbs


-- Notice NO in the RESTRICTED column of INDIGO.

-- Exit SQLcl.

exit

-- Patch the INDIGO PDB.

$ORACLE_HOME/OPatch/datapatch -pdbs INDIGO

/*
The command line parameter -pdbs ensure that Datapatch just works on the INDIGO PDB.
You could also run Datapatch without the parameter. It would then examine the database and determine only INDIGO needed patching. However, this might take slightly longer.
*/
