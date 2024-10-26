-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : stext2.sql                                                                                --
-- Description   : Displays sql_text from sql_id base on hist                                            --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @stext2 <SQL_ID>                                                                          --
-- Last Modified : 15/08/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


set lines 9999
set long 999999999
select dbms_lob.substr(sql_text,4000,1)  as sql_text from dba_hist_sqltext where sql_id='&1' and rownum=1;

