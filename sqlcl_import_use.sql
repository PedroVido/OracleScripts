--===================================================
-- HOW TO IMPORT CONNECTION ON SQLCL
--===================================================

-- 1) Export connection from SQldevloper (with passkey)

-- 2) Create passkey on sqlcl with the same passkey the Export

 secret set passwd ss120281
 
SQL>  secret set passwd ss120281
Secret passwd stored
SQL>

-- 3) import the .json whit the passkey 

connmgr import -key passwd 20250506_OraCon.json

SQL> connmgr import -key passwd 20250506_OraCon.json
Importing connection rds-dbup-prod.ctlzibk0yfxw.us-east-1.rds.amazonaws.com_DBUPPROD: Success
...
...
Importing connection rmanp1.raiadrogasil.com.br_rman: Success
372 connection(s) processed
SQL>

---============================================
                -- OU --
---============================================

sql /nolog

secret set passwd 123456789

SQL> secret set passwd 123456789;
Secret passwd stored
SQL>

cm import -KEY passwd -d REPLACE C:\Users\pcvido\Documents\connections_list_250426__123456789.json
#cm import -KEY passwd -d REPLACE C:\Users\pcvido\Documents\Teste.json

SQL> cm import -KEY passwd -d REPLACE C:\Users\pcvido\Documents\connections_list_010725__123456789.json
Importing connection rds-dbup-prod.ctlzibk0yfxw.us-east-1.rds.amazonaws.com_DBUPPROD: Success
...
...
Importing connection rmanp1.raiadrogasil.com.br_rman: Success
376 connection(s) processed



---- IMPORTED -----

--========================================



-- 4) Listar conexoes importadas

connmgr list

-- 5) Deletando conexoes 

-- Caso precise deletar as conexoes :

C:\Users\pcvido\AppData\Roaming\DBTools\connections

-- Deletar conexao especifica :

CONNMGR DELETE <connection_name>

-- 6) Conectando nas conecoes importadas

sql /nolog 

connect -name <connection> @format_prod_pv

-- OU

sql -name <connection> @format_prod_pv


-- 57) Achar conexao dentre as importadas

echo cm list -flat | sql -nolog | findstr /i rdp
echo cm list -flat | sql -nolog | findstr /i APDATA

echo cm list -flat | sql -nolog | findstr /i <string>

