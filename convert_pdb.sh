#!/bin/sh
#---------------------------------------------------------------------------------
# Copyright(c) 2023 France Telecom Corporation. All Rights Reserved.
#
# NAME
#   Convert_pdb.sh
#
# DESCRIPTION
#   Convert NON CDB to PDB
#
# CHANGE LOGS : Herve AGASSE
#---------------------------------------------------------------------------------
export LD_LIBRARY_PATH=/opt/oracle/na/19/lib:/lib:/usr/lib
export ORACLE_BASE=/opt/oracle
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/dell/srvadmin/bin:/opt/dell/srvadmin/sbin:/usr/ccs/bin:/etc:/usr/openwin/bin:/opt/oracle/na/19/bin:/opt/oracle/na/19/OPatch
export NLS_LANG=american_america.we8iso8859p15
export ORACLE_HOME=/opt/oracle/na/19
export ORACLE_SID=CDB1
export NONPDB=PMM8BDD

export REP_LOG=/opt/oracle/dba/tools

mkdir -p /oradata/$ORACLE_SID/$NONPDB

sqlplus -s /NOLOG  <<EOF > $REP_LOG/convert_CDB1.log
connect / as sysdba;
set timing on time on echo on 

prompt Create Pluggable 
select to_char(sysdate, 'DD/MM/YYYY HH24:MI') from dual;
CREATE PLUGGABLE DATABASE $NONPDB  USING '/opt/oracle/dba/tools/$NONPDB.xml'
COPY file_name_convert=('/oradata/$NONPDB','/oradata/$ORACLE_SID/$NONPDB');
select to_char(sysdate, 'DD/MM/YYYY HH24:MI') from dual;
select name, open_mode, cdb from v\$database;
col pdb_name format a30
SELECT pdb_name , status from cdb_pdbs;
col name for a30
select name, open_mode from v\$pdbs;
prompt run noncdb_to_pdb.sql
ALTER SESSION SET CONTAINER=$NONPDB;
ALTER SESSION SET "_OLD_CONNECT_BY_ENABLED"=FALSE;
ALTER SESSION SET optimizer_features_enable=11.2.0.4;
show con_name
@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql
alter pluggable database PMM8BDD open;
select name,open_mode,restricted from v\$pdbs;
EOF

