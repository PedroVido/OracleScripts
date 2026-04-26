-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : ddlts.sql                                                                             --
-- Description   : Prints the DDL create for the given tablespace.                                       --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBMS_METADATA.                                                          --
-- Usage:         SQL> @ddlts [ % | <% tablespace_name %> ]                                              --
--                SQL> @ddlts %      -> print all tablespaces                                            --
--                SQL> @ddlts sys%   -> print all tablespaces sys%                                       --
--                SQL> @ddlts users  -> print the tablespace users                                       --
--                                                                                                       --
-- Last Modified : 30/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


--@saveset
SET LONG 99999;

BEGIN
   DBMS_METADATA.SET_TRANSFORM_PARAM (DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
   DBMS_METADATA.SET_TRANSFORM_PARAM (DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', TRUE);
END;
/

SET FEEDBACK OFF HEADING OFF

SELECT
      DBMS_METADATA.GET_DDL('TABLESPACE', tablespace_name) DDL
FROM DBA_TABLESPACES
WHERE UPPER(tablespace_name) LIKE UPPER(CASE WHEN INSTR('&1','.') > 0 THEN SUBSTR('&1',INSTR('&1','.')+1) ELSE '&1' END)
;


SET FEEDBACK ON HEADING ON

PROMPT ;
