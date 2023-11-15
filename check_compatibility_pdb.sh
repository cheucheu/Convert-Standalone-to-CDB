#!/bin/sh
#---------------------------------------------------------------------------------
# Copyright(c) 2023 France Telecom Corporation. All Rights Reserved.
#
# NAME
#   Check_compatibility_pdb.sh
#
# DESCRIPTION
#   Check compatibilty to plug DB into CDB
#
# CHANGE LOGS : Herve AGASSE
#---------------------------------------------------------------------------------
export LD_LIBRARY_PATH=/opt/oracle/na/19/lib:/lib:/usr/lib
export ORACLE_BASE=/opt/oracle
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/dell/srvadmin/bin:/opt/dell/srvadmin/sbin:/usr/ccs/bin:/etc:/usr/openwin/bin:/opt/oracle/na/19/bin:/opt/oracle/na/19/OPatch
export NLS_LANG=american_america.we8iso8859p15
export ORACLE_HOME=/opt/oracle/na/19
export ORACLE_SID=PMM8BDD
export NONPDB=$ORACLE_SID
export CDB=CDB1
export REP_LOG=/opt/oracle/dba/tools

sqlplus -s /NOLOG  <<EOF > $REP_LOG/check_compatibility_pdb.log
connect / as sysdba;
shutdown immediate;
startup mount exclusive;
alter database open read only;
select name, open_mode, cdb from v\$database;
BEGIN
DBMS_PDB.DESCRIBE(pdb_descr_file => '/opt/oracle/dba/tools/$ORACLE_SID.xml');
END;
/ 
shutdown immediate;
EOF

export ORACLE_SID=$CDB
sqlplus -s /NOLOG  <<EOF >> $REP_LOG/check_compatibility_pdb.log
connect / as sysdba;
prompt verify compatibility to plug $NONPDB  into $CDB
set serveroutput on size 100000

DECLARE
compatible CONSTANT VARCHAR2(3) := CASE DBMS_PDB.CHECK_PLUG_COMPATIBILITY( pdb_descr_file => '/opt/oracle/dba/tools/$NONPDB.xml', pdb_name => '$NONPDB') WHEN TRUE THEN 'YES' ELSE 'NO'
END;
BEGIN
DBMS_OUTPUT.PUT_LINE('Is the future PDB compatible?  ==>  ' || compatible);
END;
/
set head on feed on 
col cause for a10
col name for a10
col message for a35 word_wrapped
select name,cause,type,message,status from PDB_PLUG_IN_VIOLATIONS where name='$NONPDB';
EOF



