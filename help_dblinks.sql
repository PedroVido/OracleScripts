SYS@dberpitp_pdb1> desc dba_db_links;
Name           Null?    Type
-------------- -------- --------------
OWNER          NOT NULL VARCHAR2(128)
DB_LINK        NOT NULL VARCHAR2(128)
USERNAME                VARCHAR2(128)
HOST                    VARCHAR2(2000)
CREATED        NOT NULL DATE
HIDDEN                  VARCHAR2(3)
SHARD_INTERNAL          VARCHAR2(3)
VALID                   VARCHAR2(3)
INTRA_CDB               VARCHAR2(3)
SYS@dberpitp_pdb1>


set lines 9999 pages 9999
col owner for a20
col db_link for a40
col username for a20
col host for a100 word_wrap trunc
col valid for a10
col intra_cdb for a20
select owner, db_link, username, host, valid, intra_cdb from DBA_DB_LINKS;