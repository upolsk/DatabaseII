/*6. Write a PL/SQL function which returns in a character string the list of table names  
(comma separated list in alphabetical order) of owner NIKOVITS, whose penultimate column has data type DATE. */

CREATE OR REPLACE FUNCTION nt_tables RETURN VARCHAR2 IS 
table_names varchar2(30000);
BEGIN
select LISTAGG(t.table_name, ' , ') WITHIN GROUP (ORDER BY t.table_name) into table_names
from dba_tables t, dba_tab_columns tc 
where t.owner = 'NIKOVITS' and tc.owner = 'NIKOVITS'
and tc.data_type = 'DATE' and t.table_name = tc.table_name;
return table_names;
END;
SELECT nt_tables() FROM dual; 
 
--select t.table_name, tc.data_type, tc.owner
--from dba_tables t, dba_tab_columns tc 
--where t.owner = 'NIKOVITS' and tc.owner = 'NIKOVITS'
--and tc.data_type = 'DATE' and t.table_name = tc.table_name;

select t.table_name  from dba_tables t join dba_tab_columns c on t.table_name=c.table_name
    where t.owner='NIKOVITS' and c.data_type='DATE';

CREATE OR REPLACE FUNCTION nt_tables RETURN VARCHAR2 IS
     CURSOR curs1 IS 
      select distinct t.table_name  from dba_tables t join dba_tab_columns c on t.table_name=c.table_name
        where t.owner='NIKOVITS' and c.data_type='DATE' order by t.table_name;
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

--6. Give the name of all tables whose second column has the letter ‘K’ in its name. Also select the column name (table_name, column_name). 
select * from dba_ind_columns;
select distinct table_name, column_name from dba_tab_columns 
where column_id = 2 and column_name like '%K%';
select * from dba_tab_columns;

describe dba_indexes;
describe dba_tab_columns;

select * from dba_tab_columns;
---Give the name, owner and size of all tables that have data allocated in at least 6 extents and have at least 4 columns (table_name, owner, size). 
with t1 as(select segment_name, owner, bytes from dba_extents where extent_id = 6),
t2 as(select index_name, index_owner, table_name from dba_ind_columns group by index_name, index_owner, table_name having count(column_name) > 4)
select t2.table_name, t1.owner, t1.bytes from t1 join t2 on t1.owner = t2.index_owner and t2.index_name = t1.segment_name order by t1.bytes;



