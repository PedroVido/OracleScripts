--==================================================
--27.D) Mostrar status de um replicação específica 
--==================================================


 Rodar o comando "Info all" e escolher a replicação a qual quer ver status do ultimo ckpt, local dos trails

 Depois rodar "info <GROUP>" para ver as informações
 Outro comando com mais informações : "Info <group>, detail"

 INFO <GROUP>
 SEND <GROUP> STATS, HOURLY
 send extract ECCARR  showtrans tabular

--==================================================================
--27.G) Mudar sequencia de gravação de trails
--==================================================================


Etrollover manda o processo fazer switch para um novo arquivo. Exemplo: se o extrator estava gravando 
no arquivo ta000000009, após o etrollover ele vai iniciar do ta000000010


ALTER EXTRACT <group name>, ETROLLOVER

--==================================================================
--27.H) infos de log sem entrar no ggsci
--==================================================================


echo "INFO *CSTPRD*" | ggsci | grep Lag

--==================================================================
--27.I) Ignorar erros no ogg
--==================================================================


DDLERROR 5678 IGNORE
DDLERROR 1430 IGNORE
DDLERROR 1435 IGNORE
DDLERROR 955 IGNORE

--==================================================================
--27.J) Kill ogg process
--==================================================================


KILL REPLICAT group_name
KILL EXTRACT group_name


--==================================================================
--27.K) Ver qual arquivo o processo está lendo e escrevendo
--==================================================================


send pbdcst2 status

--==================================================================
--27.M) Log com DBLOGIN - OGG
--==================================================================


 dblogin userid oggforbd@r102HNEW, password PWD#oggforbd

 dblogin USERIDALIAS oggforbdcma


--==================================================================
--27.N) Show Purge Rules installed
--==================================================================

SEND MANAGER GETPURGEOLDEXTRACTS


PURGEOLDEXTRACTS ./dirdat/RCFIGRUN/* , USECHECKPOINTS, MINKEEPDAYS 5, FREQUENCYMINUTES 10.               */



--==================================================================
--27.O) USERIDALIAS
--==================================================================

/*
The ADD CREDENTIALSTORE is a new command in Oracle GoldenGate 12c.
The credential store eliminates the need to specify user names and clear-text passwords in the Oracle GoldenGate parameter files. 
It is implemented as an autologin wallet within the Oracle Credential Store Framework (CSF).
We can use the USERIDALIAS in an extract or replicat parameter file to map a user specified alias to a userid-password pair which is stored in the credential store.
*/


-- Let us see an example. -- 

GGSCI (kens-orasql-001-dev.corporateict.domain) 3> ADD CREDENTIALSTORE

Credential store created in ./dircrd/.

[oracle@kens-orasql-001-dev goldengate]$ cd dircrd
[oracle@kens-orasql-001-dev dircrd]$ ls
cwallet.sso

/*
We see that the credential store has been created in the dircrd sub-directory located in the GoldenGate software installation home. 
If we need to create it in any other location like a shared file system, we have to specify that via the CREDENTIALSTORELOCATION parameter in the GLOBALS file.
We now want to add some users to the credential store.
In our earlier post we had explained how to use Oracle GoldenGate 12c with an Oracle 12c Multitenant database.
We had created a common user C##GGADMIN and now want to add that user to the credential store
*/


GGSCI (kens-orasql-001-dev.corporateict.domain) 1> ALTER CREDENTIALSTORE ADD USER c##ggadmin ALIAS gg_root
Password:

Credential store in ./dircrd/ altered.

-- We can now use the USERIDALIAS parameter in extract and replicat parameter files as well as with the DBLOGIN command as shown here.

GGSCI (kens-orasql-001-dev.corporateict.domain) 3> DBLOGIN USERIDALIAS gg_root
Successfully logged into database CDB$ROOT.


-- Suppose we want to connect to one of the PDBs in that container database called SALES and want to create an alias for this connection and store it in the credential store as well.

GGSCI (kens-orasql-001-dev.corporateict.domain) 4>  ALTER CREDENTIALSTORE ADD USER c##ggadmin@sales ALIAS gg_sales
Password:

Credential store in ./dircrd/ altered.

GGSCI (kens-orasql-001-dev.corporateict.domain) 5> DBLOGIN USERIDALIAS gg_sales
Successfully logged into database SALES.

GGSCI (kens-orasql-001-dev.corporateict.domain) 6> INFO CREDENTIALSTORE

Reading from ./dircrd/:

Domain: OracleGoldenGate

Alias: gg_root
Userid: c##ggadmin

Alias: gg_sales
Userid: c##ggadmin@sales