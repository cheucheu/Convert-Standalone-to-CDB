begin
  DBMS_PDB.DESCRIBE(
    pdb_descr_file => '/tmp/db19c.xml');
END;
/


set serveroutput on

DECLARE
compatible CONSTANT VARCHAR2(3) := CASE DBMS_PDB.CHECK_PLUG_COMPATIBILITY( pdb_descr_file => '/tmp/db19c.xml', pdb_name => 'PMM8BDD') WHEN TRUE THEN 'YES' ELSE 'NO'
END;
BEGIN
DBMS_OUTPUT.PUT_LINE('Is the future PDB compatible?  ==>  ' || compatible);
END;
/
