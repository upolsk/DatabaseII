select * from nikovits.emp;

drop index emp1;
select * from dba_indexes where index_name = 'EMP1';
CREATE UNIQUE INDEX  emp1 ON emp (ename);
CREATE INDEX         emp2 ON emp (job, sal DESC);
CREATE INDEX         emp3 ON emp (job, sal) REVERSE;
CREATE INDEX         emp4 ON emp (deptno, job, sal) COMPRESS 2;
CREATE BITMAP INDEX  emp5 ON emp (mgr);          
CREATE INDEX         emp6 ON emp (SUBSTR(ename, 2, 2), job);

select * from dba_ind_columns;



/*1. Give the tables (table_name) which has a column indexed in descending order.
See the name of the column. Why is it so strange? -> DBA_IND_EXPRESSIONS*/
select table_owner, table_name, column_name from dba_ind_columns where descend = 'DESC';

select * from dba_ind_expressions ex join
(select table_owner, table_name, column_name 
from dba_ind_columns where descend = 'DESC') co 
on co.table_owner = ex.table_owner and co.table_name = ex.table_name;



--2. Give the indexes (index name) which are composite and have at least 9 columns (expressions).
select index_name, count(*) from dba_ind_columns
group by index_name
having count(*) >= 9;


--3. Give the name of bitmap indexes on table NIKOVITS.CUSTOMERS.
select owner, index_name
from dba_indexes
where index_type = 'BITMAP'
and table_owner = 'NIKOVITS'
and table_name = 'CUSTOMERS';

--4. Give the indexes which has at least 2 columns and are function-based.
select index_name, index_owner from dba_ind_columns
group by index_name, index_owner
having count(column_name) >= 2
INTERSECT
select index_name, index_owner from dba_ind_expressions;

--5. Give for one of the above indexes the expression for which the index was created.
select index_name, index_owner, column_expression from dba_ind_expressions where index_name = 'EMP6' and index_owner = 'NIKOVITS';

/*7. Write a PL/SQL procedure which gets a file_id and block_id as a parameter and prints out the database
object to which this datablock is allocated. (owner  object_name  object_type).
If the specified datablock is not allocated to any object, the procedure should print out 'Free block'.*/
select * from dba_objects;
select * from dba_extents;
--CREATE OR REPLACE PROCEDURE block_usage(p_fileid NUMBER, p_blockid NUMBER) IS
--ob_owner varchar(500);
--ob_name varchar(500);
--ob_type varchar(500);
--BEGIN
--    for rec in
--      (select * from dba_extents
--      where file_id = upper(p_fileid) and p_blockid between block_id and block_id + blocks - 1)
--    loop
--      select owner, object_name, object_type into ob_owner, ob_name, ob_type from dba_objects 
--      where owner = rec.owner and object_name = rec.segment_name and object_type = rec.segment_type; 
--      DBMS_OUTPUT.PUT_LINE(ob_owner || ' ' || ob_name || ' ' || ob_type);
--    end loop;
--END;


CREATE OR REPLACE PROCEDURE block_usage(p_fileid NUMBER, p_blockid NUMBER) IS
results varchar(1000);
BEGIN
    select min(owner)|| ' '|| min(NVL(segment_name, 'FREE BLOCK'))||' ' || min(segment_type) into results 
    from dba_extents
    where file_id = upper(p_fileid) and p_blockid between block_id and block_id + blocks - 1; 
    DBMS_OUTPUT.PUT_LINE(results);
END;

set serveroutput on
EXECUTE block_usage(2, 615);

EXECUTE check_plsql('block_usage(2,615)');

select * from dba_segments where segment_type = 'INDEX';

-----------------------------------------------
--Compulsory exercise
/*6. Write a PL/SQL procedure which prints out the names and sizes (in bytes) of indexes created
on the parameter table. Indexes should be in alphabetical order, and the format of the 
output should be like this: (number of spaces doesn't count between the columns)
CUSTOMERS_YOB_BIX:   196608*/
describe dba_segments;
describe dba_indexes;
select * from dba_segments where segment_name = 'CUSTOMERS';
CREATE OR REPLACE PROCEDURE list_indexes(p_owner VARCHAR2, p_table VARCHAR2) IS
psize integer;
BEGIN
    for rec in
            (select owner, index_name from dba_indexes
            where table_owner = upper(p_owner) and table_name = upper(p_table)
            order by owner) 
        loop
        select bytes into psize from dba_segments where owner = rec.owner and segment_name = rec.index_name
        and segment_type like 'INDEX%';
        DBMS_OUTPUT.PUT_LINE(rec.index_name || ':   ' || psize);           
   end loop;   
END;

set serveroutput on
EXECUTE list_indexes('nikovits', 'customers');

EXECUTE check_plsql('list_indexes(''nikovits'',''customers'')');
