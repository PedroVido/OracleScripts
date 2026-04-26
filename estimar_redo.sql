-- ########################################################################################################
--                                                                                                       --
-- File Name     : estimar_redo.sql                                                                      --
-- Description   : Estimar a quantidade e Tamanho dos REDOS ideiais.                                     --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access V$ views.                                                                      --
-- Call Syntax   : N/A                                                                                   --
-- Last Modified : 17/11/2025                                                                            --
-- Author        : Pedro Vido - pedro.carvalho.vido@accenture.com                                        --
--                                                                                                       --
-- ########################################################################################################

/*
Calculate Size of Redo log file according to no of switches you need in Oracle
Leave a reply
Determine the size of Redo file according no of switches per hour in Oracle
For calculating the Size of Redo log file, we can use the following formula:

(Current Switches per hour * Redo Log Size)/(Desired number of Switches)=New redo log size
Example: Suppose we are having 100 M Size of redo log file which switch on an average 10 times in hours and we want to make switch 4 times per hours. For that we can calculate the New Redo log size by using the formula:

Current Switches per hour = 10
Redo log Size = 100 M
Desired number of switches = 4
Calculate New Redo log Size: 10*100/4 = 250M New Size needed for Redo log file to make switches 4 per hours.
Note: 
New Redo Size = (Current Switches per hour * Redo Log Size)/(Desired number of Switches)
*/


--> Calculo 

(Numero atual de switchs * tamanho atual do REDO) / (Quantidade de switchs desejados) = Tamanho do REDO ideal

29*500/12=1.2
90*500/12=3.75

50*500/12=


-- Query apoio

--> Mostra a geracao de REDOs em sec e min por snap e os MB por segundo

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
select thread#,
       sequence# ,FIRST_TIME,NEXT_TIME,blocks*block_size/1024/1024 "MB",
       (next_time-first_time)*86400 "sec", 
       trunc((next_time-first_time),4) * 24 * 60 "min",
       (blocks*block_size/1024/1024)/((next_time-first_time)*86400) "MB/s"  
  from V$ARCHIVED_LOG 
 where ((next_time-first_time)*86400<>0) 
   and first_time between to_date('2025/11/10 00:00:00','YYYY/MM/DD HH24:MI:SS')
   and to_date('2025/11/10 23:59:00','YYYY/MM/DD HH24:MI:SS') 
and dest_id=1
order by first_time;



/*
Para tamanho a baixo de 2G se usa o bytes - exemplo abaixo:

-- 128M e o padrao do RDS inicial

EXEC rdsadmin.rdsadmin_util.add_logfile(bytes => 536870912); -> 512 MB
EXEC rdsadmin.rdsadmin_util.add_logfile(bytes => 1073741824); -> 1G


Para tamanho a partir de 2G se usa o p_size - exemplo abaixo:

EXEC rdsadmin.rdsadmin_util.add_logfile(p_size => '2G');
*/


