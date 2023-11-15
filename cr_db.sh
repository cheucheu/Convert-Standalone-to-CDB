#!/bin/sh
#---------------------------------------------------------------------------------
# Copyright(c) 2023 France Telecom Corporation. All Rights Reserved.
#
# NAME
#    CreateDB_18c.sh
#
# DESCRIPTION
#   Creation CDB database 
#
# CHANGE LOGS : Herve AGASSE
#---------------------------------------------------------------------------------
export LD_LIBRARY_PATH=/opt/oracle/na/19/lib:/lib:/usr/lib
export ORACLE_BASE=/opt/oracle
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/dell/srvadmin/bin:/opt/dell/srvadmin/sbin:/usr/ccs/bin:/etc:/usr/openwin/bin:/opt/oracle/na/19/bin:/opt/oracle/na/19/OPatch
export NLS_LANG=american_america.we8iso8859p15
export ORACLE_HOME=/opt/oracle/na/19
export ORACLE_SID=CDB1

mkdir -p /oradata/CDB1
mkdir -p /oradata/CDB1/pdbseed
mkdir -p /oradata/CDB1/fast_recovery_area
mkdir -p /oradata/CDB1/adm
mkdir -p /oradata/CDB1/adm/adump

export REP_LOG=/opt/oracle/dba/tools
rm -f /opt/oracle/na/19/dbs/spfileCDB1.ora 2>/dev/null 2>&1

sqlplus -s /NOLOG  <<EOF > $REP_LOG/cr_CDB1.log
connect / as sysdba;
shutdown abort;
create spfile from pfile='/opt/oracle/dba/tools/init_CDB1.ora';
startup nomount;
set echo on 
set timing on 
@/opt/oracle/dba/tools/cr_cdb.sql

SELECT dbid, name, created, log_mode, open_mode, cdb, con_id FROM v\$database;
SELECT con_id, dbid, name, open_mode, restricted, TO_CHAR(open_time, 'DD-MON-YY HH:MI:SS AM') OPEN_TIME FROM v\$containers;
SELECT c.name DB_NAME, a.name TABLESPACE_NAME, b.name DATA_FILE_NAME, b.bytes/1024/1024 SIZE_MB, b.status, a.con_id, a.ts#, a.name TABLESPACE_NAME, b.name DATA_FILE_NAME, b.file#, b.blocks, b.bytes/1024/1024 SIZE_MB, b.status, b.enabled, b.creation_time
 FROM v\$tablespace a, v\$datafile b, v\$containers c
 WHERE a.con_id = b.con_id
 AND a.con_id = c.con_id
 AND a.ts# = b.ts#
 ORDER BY a.con_id, a.TS#;
show parameter control_files;
SELECT a.group#, a.members, a.bytes/1024/1024 SIZE_MB, a.status, b.member
 FROM v\$log a, v\$logfile b
 WHERE a.group# = b.group#;
SELECT * FROM v\$nls_parameters WHERE parameter LIKE '%CHARACTERSET%';
exit
EOF

$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/SYS -d $ORACLE_HOME/rdbms/admin -b catalog_output -e -l $REP_LOG catalog.sql
$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/SYS -d $ORACLE_HOME/rdbms/admin -b catproc_output -e -l $REP_LOG catproc.sql
$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u system/MANAGER -d $ORACLE_HOME/sqlplus/admin -b pupbld_output -e -l $REP_LOG  pupbld.sql


sqlplus -s /NOLOG  <<EOF >> $REP_LOG/cr_CDB1.log
connect / as sysdba;
prompt RESULTAT
col comp_name for a40
col version for a15
col status for a10
SELECT name, comp_name, version, status FROM v\$database, dba_registry;
@?/rdbms/admin/utlrp.sql
SELECT name, comp_name, version, status FROM v\$database, dba_registry;
exit
EOF


