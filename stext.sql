-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : tstext.sql                                                                                 --
-- Description   : Displays sql_text from sql_id                                                         --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @stext <SQL_ID>                                                                           --
-- Last Modified : 15/08/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################


set lines 9999
set long 999999999
select sql_fulltext from gv$sql where sql_id='&1' and rownum=1;

