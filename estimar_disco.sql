-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : estimar_disco.sql                                                                     --
-- Description   : Estima disco para resize .                                                            --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : rodar manualmente os comandos (Automacao em andamento)                                --
-- Last Modified : 20/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################



-- SELECT PARA PEGAR OS DADOS DOS CAMPOS -> TOTAL_MB e FREE_MB.
--
--
--set lines 9999
--set pages 9999
--SET SQLFORMAT
--COL NAME HEADING "Disksgroup"
--COL TYPE HEADING "Redundancy"
--COL TOTAL_MB HEADING "Total MB" FORMAT 999,999,999,999  
--COL FREE_MB  HEADING "Free MB"  FORMAT 999,999,999,999 
--COL PERCFREE HEADING "Free %"   FORMAT 999.99 
--
--SELECT NAME, TYPE, TOTAL_MB, FREE_MB, (FREE_MB/TOTAL_MB*100) AS PERCFREE
--FROM (
--	SELECT NAME, 
--	       TYPE,
--		   ( TOTAL_MB / DECODE(TYPE,'HIGH',3,'NORMAL',2,1) )  AS TOTAL_MB, 
--		   USABLE_FILE_MB AS FREE_MB
--	FROM V$ASM_DISKGROUP
--);
--

--
-- Com os dados acima dados, suponhamos que gostariamos de saber quando % o disco vai ficar apos add 1T ou 1024000Mb, somamos os 1024000MB aos valores recuperados da query acima
-- e substituimos na procedure abaixo nos campos total_new e free_new.
--


set serveroutput on size 10000;

declare 
total_new NUMBER(20) := 4576640;    --<-- Valor do Disco atual mais o valor que sera adicionado
free_new NUMBER(20) :=  1093046;      --<-- Espaco livre atual mais o valor que sera adicionado


BEGIN
dbms_output.put_line('=======================================================================================' );
dbms_output.put_line('===            Script para estimar o consumo do disco apos o resize                  ==' );
dbms_output.put_line('=======================================================================================' );
dbms_output.put_line('--                                       |' );
dbms_output.put_line('--                                       |' );
dbms_output.put_line('--                                       V' );
dbms_output.put_line('===========================================================================================' );
dbms_output.put_line(' =   Novo valor do DATA TOTAL em GB: ' || total_new  || ', Porcentagem de consumo apos resize: ' 
                          ||ROUND((1- (free_new / total_new))*100, 2)||'%  =');
dbms_output.put_line('===========================================================================================' );
dbms_output.put_line('===========================================================================================' );
dbms_output.put_line(' =   Novo valor do DATA FREE em GB: ' || free_new ||'                                               =' );
dbms_output.put_line('===========================================================================================' );
end;

/


    
