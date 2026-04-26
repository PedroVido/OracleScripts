--========================================================================================================
-- Oracle s oratop Utility
-- Overview
-- Oracle oratop is a real-time monitoring utility for Oracle databases that provides a top-like interface, 
-- allowing users to track database activity, performance metrics, and resource usage.
--========================================================================================================


/*
Example Output

Oracle 19c - 07:09:19 Primary  r/w dnat up: 1.5y, 158 sn,  2 ins,  2 er, 3.8T sz,  36G sga,    0%fra, archivelog            4.2
ID CPU  %CPU LOAD  AAS  ASC  ASI  ASW  ISW  REDO TEMP IORT MBPS IOPS  R/S  W/S  LIO GCPS  %FRE  PGA  NETV UTPS UCPS SQRT %DBC %
 1  16  16.0  2.6  1.2    0    0    0   78  3.7k   2M  29u   19 2.2k 2.2k 14.1  50k 35.3  26.2 1.5G  619k  0.1 40.4 574u  2.9
 2  16   6.7  0.9  0.1    0    0    1   79  3.9k   8M   7u  0.5 52.6 30.6   22  388 22.7  14.7 2.6G   64k    0 53.5 147u  0.8

EVENT (C)                                                              T/O  WAIT  TIME   AVG  %DBT                      WAIT_CL
DB CPU                                                                            1.5y        62.0
db file sequential read                                                      22G   87d  350u    10                        User
control file sequential read                                                 25G   63d  200u   7.3                      System
RMAN backup & recovery I/O                                                   74M   37d   22m   4.3                      System
gc cr grant 2-way                                                           3.3G   13d  350u   1.5                         Clus

ID   SID     SPID USERNAME PROGRAM   SRV SERVICE OPN SQLID/BLOCKER  E/T %CPU %LIO  PGA STS STE WAIT_CLASS EVENT/OBJECT NAME
 2  1285   545526 HR       sqr7wt.ex DED abctest PL/ fg0qt4akg7gd8 9.9t  0.2 33.7 5.6M ACT WAI Idle       PL/SQL lock timer   8
 2    25  1480351 SYS      JDBC Thin DED SYS$USE SEL gfbg8k1jsdv6b  40m  6.8 29.7 6.2M INA WAI Idle       SQL*Net message fro
 2   411    93141 SYS      JDBC Thin DED SYS$USE                   117m  0.2    0 3.1M INA WAI Idle       SQL*Net message fro 1
 1  1083   743492 SYS      JDBC Thin DED SYS$USE SEL fyujkwa6bvtxd  23m  0.2    0 4.5M INA WAI Idle       SQL*Net message fro
 2   235   570211 ABCUSER  w3wp.exe  DED abctest                    13s    0  9.7 3.4M INA WAI Idle       SQL*Net message fro
 2   821   570117 ABCUSER  w3wp.exe  DED abctest                    18s    0  9.7 3.4M INA WAI Idle       SQL*Net message fro
 2   125   561018 ABCUSER  w3wp.exe  DED abctest                   7.0s    0  9.7 5.9M INA WAI Idle       SQL*Net message fro 7
 1   235    86248 ABCUSER  w3wp.exe  DED abctest                    19s    0    0 3.4M INA WAI Idle       SQL*Net message fro
 1  1087    86921 ABCUSER  w3wp.exe  DED abctest                    14s    0    0 3.4M INA WAI Idle       SQL*Net message fro
*/ 
 
Usage
 export LD_LIBRARY_PATH=$ORACLE_HOME/lib 
 cd /u01/app/oracle/product/19.3.0.0.0/dbhome_1/suptools/oratop
 ./oratop -f / as sysdba
 
Change to dir matching your install: locate oratop

Help
./oratop -help

Usage:
   oratop [  [Options] [Logon] ]

   Logon:  {username[@connect_identifier] | / } [AS SYSDBA]
           Password is prompted and the connect_identifier is TNS/ EZconnect

   Options:
        -b: batch mode. Used with -n iteration (default is console)
        -n: maximum number of iterations (requires a value)
        -o: Write console output to a file (in batch mode)
        -i: interval delay (requires a value, default: 5)
        -r: real-time (RT) wait events. (section 3, default: Cumulative)
        -m: Session/Process MODULE/ACTION (default: USERNAME/PROGRAM)
        -s: SQL mode. (section 4, default: session/process mode)
        -f: detailed format, 132 columns. (default: standard, 80 columns)
        -v: oratop release version number
        -h: this help
Most Common Options
 a = ASM (if RAC used)
 m = Toggle: Programs|Modules
 r = toggle between [Cumulative (C)] & Real-Time (RT) (section 3)
 s = SQL mode
 t = tablespaces
 
-- ================================================================= 
Alias for .bashrc
alias otop='export LD_LIBRARY_PATH=$ORACLE_HOME/lib;
  cd /u01/app/oracle/product/19.3.0.0.0/dbhome_1/suptools/oratop;
  ./oratop -f / as sysdba'
-- ================================================================= 


 ./oratop -f / as sysdba          -- Visao completa 132 Colunas (Padrao 80)
 ./oratop -b -n 100 / as sysdba   -- Prompt mode com varias execucoes (100 execucoes)
 ./oratop -s / as sysdba          -- Focado em sql executando 
 ./oratop -r / as sysdba          -- Real time