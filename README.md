"# 19c Convert in place  Standalone DB to CDB" 

First Step : Create the CDB 
-----------------------------

- Define a initialization file :  init_CDB1.ora
+   The parameter enable_pluggable_database=true is mandatory
+   The SGA must be at minimal to 1 Go

- Define the CREATE DATABASE :  cr_crdb.sql

- Run the shell : cr_db.sh

Second Step: Verify the compatibility of the standalone to convert as a PDB
------------------------------------------------------------------------------

- Run the shell : check_compatibility_pdb.sh

Third Step : Convert the standalone as a PDB into the CBD
---------------------------------------------------------
+ The shell must be executed with the SID of the CDB !
+ A pluggable DB is created by COPY with the definition XML of the standalone DB.
  CREATE PLUGGABLE DATABASE $NONPDB  USING '/opt/oracle/dba/tools/$NONPDB.xml'
COPY file_name_convert=('/oradata/$NONPDB','/oradata/$ORACLE_SID/$NONPDB');
+ After the creation, the script @?/rdbms/admin/noncdb_to_pdb.sql must be executed inside the  new PDB of the STANDALONE DB 
+ To workaround the problem "	Noncdb_to_pdb.sql Script Taking Too Long To Run (Doc ID 2814341.1)", set these parameters

  ALTER SESSION SET CONTAINER=$NONPDB;
  ALTER SESSION SET "_OLD_CONNECT_BY_ENABLED"=FALSE;
  ALTER SESSION SET optimizer_features_enable=11.2.0.4;

- Run the shell : convert_pdb.sh

After the conversion, a new PDB is pluggued into the CDB1 :

SQL> select name,open_mode,restricted from v$pdbs

NAME                       OPEN_MODE  RES
-------------------------- ---------- ---
PDB$SEED                   READ ONLY  NO
PMM8BDD                    READ WRITE NO <---- The Standalone DB 

To connect to the PDB :  SQL> alter session set container = PMM8BDD;
To verify the connexion to the PDB : SQL> SHOW CON_NAME  -> the result is PMM8BDD


For more informations : Https://oracle-base.com/articles/12c/multitenant-connecting-to-cdb-and-pdb-12cr1

