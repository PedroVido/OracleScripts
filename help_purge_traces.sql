-- Help Traces

 -- How to purge old traces, logs and audits

--======================================
-- Apagar arquivos de hoje pra traz 
--======================================


 find /u01/app/grid/11.2.0/log/diag/tnslsnr/RSARIOSRVRACPRD001/listener_scan2/alert -ctime +1 -exec rm -rf "{}" \;

 find . -name "ochad.trc*" -mtime +1 -exec rm -rf {} \;
 find . -name "*.json" -mtime +5 -exec rm -rf {} \;
 find . -name "*.xml" -mtime +1 -exec rm -rf {} \;
 find . -name "*.log" -mtime +1 -exec rm -rf {} \;
 find . -name "*.trc" -mtime +5 -exec rm -rf {} \;
 find . -name "*.tr*" -mtime +1 -exec rm -rf {} \;
 find . -name "*.trm" -mtime +1 -exec rm -rf {} \;
 find . -name "*.aud" -mtime +1 -exec rm -rf {} \;
 find . -name "core.*" -mtime +30 -exec rm -rf {} \;
 find . -name "*.gz" -mtime +1 -exec rm -rf {} \;
 find . -name "*.aud" -mtime +1 -exec rm -rf {} \;
 find . -name "ora_audit_*" -mtime +1 -exec rm -rf {} \;
 find /backup/ogg/brmprd* -mtime +120 -exec rm {} \;
 find . -name "rp*" -mtime +1 -exec rm -rf {} \;
 find . -name "*.xml" -exec rm -rf {} \;
 find . -name "core.*" -exec rm -rf {} \;

--======================================
-- Find Files by Modification Date #
--======================================

The find command can also search for files based on their last modification, access, or change time.
Same as with size, use the plus and minus symbols for “greater than” or “less than”.
Let’s say that a few days ago, you modified one of the dovecot configuration files, but you forgot which one. 
You can easily filter all files under the /etc/dovecot/conf.d directory that end with .conf and have been modified in the last five days:


find /etc/dovecot/conf.d -name "*.conf" -mtime -5

Here is another example of filtering files based on the modification date using the -daystart option. 
The command below will list all files in the /home directory that were modified 30 or more days ago:

find /home -mtime +30 -daystart