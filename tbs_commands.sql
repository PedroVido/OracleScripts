--===========================================================================================================
-- Tablespaces Oracle 
--===========================================================================================================


-- Add datafile ou Tempfile
alter tablespace <TEMPORARIA_NAME> add tempfile '/diretorio/arquivo.ora' size 1000M;
alter tablespace <TABLESPACE_NAME> add datafile '/diretorio/arquivo.ora' size 2000M;

  -- ASM
  alter tablespace <TEMPORARIA_NAME> add tempfile '+DG_' size 1000M autoextend on next 512m maxsize unlimited;
  alter tablespace <TABLESPACE_NAME> add datafile '+DG_' size 2000M autoextend on next 512m maxsize unlimited;
  ALTER TABLESPACE <TABLESPACE_NAME> ADD DATAFILE '+DG_' SIZE 1024M AUTOEXTEND ON NEXT 1024M MAXSIZE UNLIMITED;


-- Alter Datafile
ALTER DATABASE DATAFILE '/diretorio/arquivo.ora' RESIZE 50M;
ALTER DATABASE DATAFILE '/diretorio/arquivo.ora' autoextend on;
ALTER DATABASE DATAFILE '/diretorio/arquivo.ora' autoextend on next 512m maxsize unlimited;
ALTER DATABASE DATAFILE '/diretorio/arquivo.ora' autoextend off;
ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/cm/dados01.dbf' resize 1024m;

-- Drop 

ALTER TABLESPACE <TEMPORARIA_NAME> DROP DATAFILE '/diretorio/arquivo.ora';
ALTER TABLESPACE <TABLESPACE_NAME> DROP DATAFILE '/diretorio/arquivo.ora';
ALTER TABLESPACE <TABLESPACE_NAME> DROP DATAFILE '+DG_';



--==============================
-- BIGFILE
--==============================

-- Resize Tbs
 ALTER TABLESPACE ODISASPROD_ODI_USER RESIZE 20G;





--==============================
-- RDS Amazon
--==============================

-- Resize TEMP Commands - TEMPFILE Size

  -- On RDS
  EXEC rdsadmin.rdsadmin_util.resize_temp_tablespace('TEMP','4G');
  EXEC rdsadmin.rdsadmin_util.resize_temp_tablespace('TEMP','300G');
  EXEC rdsadmin.rdsadmin_util.resize_temp_tablespace('TEMP','4096000000');
  
  -- The following example resizes a temporary tablespace based on the temp file with the file identifier 1 to the size of 2 MB.
  EXEC rdsadmin.rdsadmin_util.resize_tempfile(1,'2M');

-- Resize TEMP Commands - MAXSIZE

  -- The following example turns off autoextension for temp file 1. It also sets the maximum autoextension size of temp file 2 to 10 GB, with an increment of 100 MB.
  EXEC rdsadmin.rdsadmin_util.autoextend_tempfile(1,'OFF');
  EXEC rdsadmin.rdsadmin_util.autoextend_tempfile(2,'ON','100M','10G');





-- Resize DATA Commands - MAXSIZE 

-- The following example turns off autoextension for data file 1. It also sets the maximum autoextension size of temp file 2 to 10 GB, with an increment of 100 MB.
EXEC rdsadmin.rdsadmin_util.autoextend_datafile(<file_id>, '<ON|OFF>', '<increment>', '<max_size>');
EXEC rdsadmin.rdsadmin_util.autoextend_datafile(2,'ON','100M','10G');
EXEC rdsadmin.rdsadmin_util.autoextend_datafile(4,'OFF');
EXEC rdsadmin.rdsadmin_util.autoextend_datafile(9,'ON','1024M','180G');
EXEC rdsadmin.rdsadmin_util.autoextend_datafile(9,'ON','512M','UNLIMITED');

-- Resize DATA Commands - DATAFILE size 

-- Resize bigfile tablespace only the maxsize 
-- The following example resizes data file 9 to 180 GB.

EXEC rdsadmin.rdsadmin_util.resize_datafile(9,'184320M');
EXEC rdsadmin.rdsadmin_util.resize_datafile(2,'20480M');
EXEC rdsadmin.rdsadmin_util.resize_datafile(2,'20480M');
EXEC rdsadmin.rdsadmin_util.resize_datafile(8,'30720M');


EXEC rdsadmin.rdsadmin_util.autoextend_datafile(9,'ON','1024M','2T');
EXEC rdsadmin.rdsadmin_util.autoextend_datafile(2,'ON','1024M','UNLIMITED');