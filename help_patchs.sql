--=================================
-- Patchs
--=================================



-- 1) To check Datapatch activity you should not use the dictionary tables. Instead use the view DBA_REGISTRY_SQLPATCH. Examine the patching history of this database.
col action_time format a40
select   patch_id, action, status, action_time, description
from     dba_registry_sqlpatch
order by action_time;

-- 2) Find the log file used to apply the 19.28 Release Update.

select logfile
from   dba_registry_sqlpatch
where  description like 'Database Release Update : 19.28%'
       and action='APPLY';


-- 3) Datapatch also stores log files in the file system.

cd $ORACLE_BASE/cfgtoollogs/sqlpatch

head -n20 37960098/27635722/37960098_apply_FTEX_*.log

-- 4) OPatch keeps track of all the patches that you apply over time to an Oracle home. It stores a lot of patching metadata as well as the actual patches.

cd $ORACLE_HOME/OPatch
./opatch util ListOrderedInactivePatches

-- 5) You can remove information about the inactive patches. This reduces the patching metadata which makes OPatch run faster. It also deletes patches from the .patch_storage directory 
--    inside the Oracle home and reduces the space used. Check the size of the .patch_storage folder.

du -sh $ORACLE_HOME/.patch_storage

-- Limpar - Delete the inactive patches

./opatch util deleteinactivepatches

-- 6) Everytime you patch your datababase, Datapatch stores the rollback scripts inside the database. 
--    This ensures, that Datapatch always have the option of rolling back patches - even when you use out-of-place patching and the rollback scripts are no longer in the Oracle home. 
--    Datapatch stores the rollback scripts in the SYSTEM tablespace and over time it might take up a significant amount of space.

select * from (
   select description, round(dbms_lob.getlength(PATCH_DIRECTORY)/1024/1024, 2) as size_mb
   from DBA_REGISTRY_SQLPATCH
   where action='APPLY' and description not like 'Database Release Update%'
   union
   select 'Release Update ' || RU_version as description, round(dbms_lob.getlength(PATCH_DIRECTORY)/1024/1024) as size_mb
   from DBA_REGISTRY_SQLPATCH_RU_INFO)
order by description;

-- Limpar - Purge the old rollback scripts.

$ORACLE_HOME/OPatch/datapatch -purge_old_metadata

-- Aplicar - Datapatch

/u01/app/oracle/product/19.0.0/DB1928/OPatch/./datapatch -verbose

-- 7) QUery the patchs applied 

-- Database


SET PAGES 55
SET LINESIZE 601
COLUMN ACTION_TIME FORMAT A21
COLUMN ACTION FORMAT A11
COLUMN STATUS FORMAT A11
COLUMN DESCRIPTION FORMAT A55
COLUMN VERSION FORMAT A11
COLUMN BUNDLE_SERIES FORMAT A11
  
SELECT TO_CHAR(ACTION_TIME, 'DD-MON-YYYY HH24:MI:SS') AS ACTION_TIME, PATCH_TYPE,
ACTION,STATUS,DESCRIPTION, SOURCE_VERSION,TARGET_VERSION, PATCH_ID FROM SYS.DBA_REGISTRY_SQLPATCH ORDER BY ACTION_TIME DESC;

-- COntainer - PDB
SET PAGES 55
SET LINESIZE 601
COLUMN ACTION_TIME FORMAT A21
COLUMN ACTION FORMAT A11
COLUMN STATUS FORMAT A11
COLUMN DESCRIPTION FORMAT A55
COLUMN VERSION FORMAT A11
COLUMN BUNDLE_SERIES FORMAT A11
 
SELECT CON_ID,TO_CHAR(ACTION_TIME, 'DD-MON-YYYY HH24:MI:SS') AS ACTION_TIME, PATCH_TYPE,
ACTION,STATUS,DESCRIPTION, SOURCE_VERSION,TARGET_VERSION, PATCH_ID FROM SYS.CDB_REGISTRY_SQLPATCH ORDER BY CON_ID,ACTION_TIME DESC;

-- COntainer CDB 

show con_name
  
CON_NAME
------------------------------
CDB$ROOT
 SET PAGES 55
SET LINESIZE 601
COLUMN ACTION_TIME FORMAT A21
COLUMN ACTION FORMAT A11
COLUMN STATUS FORMAT A11
COLUMN DESCRIPTION FORMAT A55
COLUMN VERSION FORMAT A11
COLUMN BUNDLE_SERIES FORMAT A11
  
SELECT TO_CHAR(ACTION_TIME, 'DD-MON-YYYY HH24:MI:SS') AS ACTION_TIME, PATCH_TYPE,
ACTION,STATUS,DESCRIPTION, SOURCE_VERSION,TARGET_VERSION, PATCH_ID FROM SYS.DBA_REGISTRY_SQLPATCH ORDER BY ACTION_TIME DESC;





