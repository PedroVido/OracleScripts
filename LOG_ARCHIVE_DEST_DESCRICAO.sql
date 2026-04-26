LOG_ARCHIVE_DEST_n parameter setting in Oracle Dataguard
LOG_ARCHIVE_DEST_n: this parameter is used to transfer the archived redo from the primary database to standby database. Standby to primary in case of switchover.

Note: LOG_ARCHIVE_DEST_n destination must have either a LOCATION or SERVICE attribute to specify a local disk directory or a remotely accessed database. All other parameter are optional.

Configured two parameter for primary and standby mode
Primary (LOG_ARCHIVE_DEST_1) define the physical location for the primary database archived redo logs.
Secondary (LOG_ARCHIVE_DEST_2) handle the transmission of the standby site’s archived redo logs back to the original primary database
when these two databases exchange roles in the future.

Example
Set the parameter LOG_ARCHVICE_DEST_n for defining the PRIM and STANBY database server.
The DB_UNIQUE_NAME parameter specifies PRIM (DB_UNIQUE_NAME=PRIM), which is also specified with the DB_UNIQUE_NAME attribute on the LOG_ARCHIVE_DEST_1 parameter.
The DB_UNIQUE_NAME attribute on the LOG_ARCHIVE_DEST_2 parameter specifies the STANBY destination.
Both PRIM and STANBY are listed in the LOG_ARCHIVE_CONFIG=DG_CONFIG parameter.

Primary parameter example
DB_UNIQUE_NAME=PRIM
LOG_ARCHIVE_CONFIG='DG_CONFIG=(PRIM,STANBY)'
LOG_ARCHIVE_DEST_1='LOCATION=/arch1/ VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=PRIM'
LOG_ARCHIVE_DEST_2='SERVICE=STANBY VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=STANBY'
LOG_ARCHIVE_DEST_STATE_1=ENABLE
LOG_ARCHIVE_DEST_STATE_2=ENABLE

Parameter used in Log_archive_dest with Example

AFFIRM and NOAFFIRM
Redo transport service use sync or async I/O to write redo data to disk. Default is NOAFFIRM.
AFFIRM: all disk I/O to archived redo log files and standby redo log file is performed synchronously and complete before continue.
NOAFFIRM: it do asynchronous, log writer doesn’t wait on primary database of disk I/O complete, it continues.
Note: AFFIRM and NOAFFIRM applied on remote standby destinations and have no effect on disk I/O for the primary database’s online redo log files.

Use following combination:
LGWR and AFFIRM attributes the log writer process sync writes the redo data to disk, control is not returned to the user until the disk I/O completes,
and online redo log files on the primary database might not be reusable until archiving is complete.
ARCH and AFFIRM attributes ARCn processes synchronously write the redo data to disk, the archival operation might take longer, and online redo log files on the primary database might not be reusable until archiving is complete.
ASYNC and AFFIRM attributes No performance effect

Example:
LOG_ARCHIVE_DEST_3='SERVICE=stby1 LGWR SYNC AFFIRM'
LOG_ARCHIVE_DEST_STATE_3=ENABLE

ARCH and LGWR
Redo transport services use to choose archiver processes ARCH or the log writer process (LGWR) to collect transaction redo data and move to standby destinations. Default is ARCH process.

Example:
LOG_ARCHIVE_DEST_3='SERVICE=standby LGWR'
LOG_ARCHIVE_DEST_STATE_3=ENABLE

DELAY
It is time lag when redo data is archived on a standby and when the archived redo log file is applied to the standby database.

Example
LOG_ARCHIVE_DEST_3='SERVICE=standby DELAY=120'
LOG_ARCHIVE_DEST_STATE_3=ENABLE

VALID FOR
used for redo transport services transmit redo data to a destination. Default value is ALL_LOGFILES & ALL_ROLES.
Different parameter available:
ONLINE_LOGFILE This destination is valid only when archiving online redo log files
STANDBY_LOGFILE This destination is valid only when archiving standby redo log files.
ALL_LOGFILES This destination is valid when archiving any one of above ONLINE_LOGFILE or STANDBY_LOGFILE.
PRIMARY_ROLE This destination is valid only when the database is running in the primary role.
STANDBY_ROLE This destination is valid only when the database is running in the standby role.
ALL_ROLES This destination is valid when the database is running in either the primary or the standby role.

Example:
LOG_ARCHIVE_DEST_1='LOCATION=/arch VALID_FOR=(ALL LOGFILES, ALL_ROLES)';
LOG_ARCHIVE_DEST_STATE_1=ENABLE

SYNC and ASYNC
network I/O is to be done synchronously (SYNC) or asynchronously (ASYNC) when archival is performed using the log writer process (LGWR).
Note:
1. With LGWR, default is sync used.
2. With ARCH , only SYNC is valid.
3. SYNC attribute is used for no data loss. It ensure that redo is transmitted successfully at destination before continue.

Example:
LOG_ARCHIVE_DEST_3='SERVICE=stby1 LGWR SYNC'
LOG_ARCHIVE_DEST_STATE_3=ENABLE

Reference link:
https://docs.oracle.com/cd/B19306_01/server.102/b14239/log_arch_dest_param.htm#i78506

--=================================================--


Resolving error, ORA-16857: standby disconnected from redo source for longer than specified threshold


1. Check for any network error and/or redo transport error from v$archive_dest in the primary database.  

2. Check for any errors related to REDO transport (network) are reported in the Data Guard broker log file in both the primary and standby databases. 
I.e DRC<SID>.log which resides in the same location as the alert log.

3. If  a  delay in the redo transport is expected, then change the threshold value to clear the error.


ApplyLagThreshold = '30'
TransportLagThreshold = '30'
TransportDisconnectedThreshold = '30'


30 seconds is the default value.  To change, use:

edit database onbasecrf set property ApplyLagThreshold='120';
edit database onbasecrf set property TransportLagThreshold='120';
edit database onbasecrf set property TransportDisconnectedThreshold='120';