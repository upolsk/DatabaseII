--5. Give the name and size of the Cluster indexes whose owner is ’LKPETER’ (Index_name, Size)
with t1 as(select segment_name, bytes from dba_segments where owner = 'LKPETER'),
t2 as(select index_name from dba_indexes where owner = 'LKPETER' and index_type = 'CLUSTER')
select t2.index_name, t1.bytes from t1 join t2 on t1.segment_name = t2.index_name order by t1.bytes desc;

/*6. Write a PL/SQL function which returns in a character string the list of non-clustered table names
(comma separated list in alphabetical order) of owner LKPETER, where the table has a DATE data type column,
and the table has datablocks in a single datafile.*/
select * from dba_extents;
select * from dba_clu_columns;

CREATE OR REPLACE FUNCTION nt_tables RETURN VARCHAR2 IS 
table_names varchar2(30000);
BEGIN
select LISTAGG(t.table_name, ' , ') WITHIN GROUP (ORDER BY t.table_name) into table_names
from dba_tables t, dba_tab_columns tc 
where t.owner = 'LKPETER' and tc.owner = 'LKPETER'
and tc.data_type = 'DATE' and t.table_name = tc.table_name and t.cluster_name is null;
return table_names;
END;
SELECT nt_tables() FROM dual; 


CREATE OR REPLACE FUNCTION nt_tables RETURN VARCHAR2 IS
     CURSOR curs1 IS 
      select distinct t.table_name  from dba_tables t join dba_tab_columns c on t.table_name=c.table_name
        where t.owner='LKPETER' and c.data_type='DATE' and t.cluster_name is null order by t.table_name;
      rec curs1%ROWTYPE;
      resString varchar(30000);
BEGIN
    OPEN curs1;
    LOOP
        FETCH curs1 INTO rec;
        EXIT WHEN curs1%NOTFOUND;
            resString := resString||', '||rec.table_name;
            dbms_output.put_line(rec.table_name);
    END LOOP;
  CLOSE curs1;
  
  return resString;
END;

SELECT nt_tables() FROM dual;

/*7. Write a PL/SQL procedure which prints out the data blocks of table NIKOVITS.CIKK
in which the number of records is greater than 10. The output has 3 columns: File_id, Block_number
and the number of records within that block. Columns are separeted by semicolons --> 2;697;35;...*/

CREATE OR REPLACE PROCEDURE gt_10 IS
begin    
    for rec in (
        select dbms_rowid.rowid_relative_fno(rowid) as fno, dbms_rowid.rowid_block_number(rowid)
        as bn,count(*) nr_recs
        from  NIKOVITS.CIKK
        group by dbms_rowid.rowid_relative_fno(rowid), dbms_rowid.rowid_block_number(rowid)
        having count(*) > 10
        )loop
            dbms_output.put_line(rec.fno || ';' || rec.bn || ';' || rec.nr_recs||';');        
        end loop;
end;

SET SERVEROUTPUT ON 
execute gt_10; 
