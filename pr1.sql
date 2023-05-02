select * from dba_objects;
select * from dba_tab_columns;

select * from dba_objects;
--1.Who is the owner of the view DBA_TABLES? Who is the owner of table DUAL? (owner)
select distinct owner from dba_objects where object_name = 'DBA_TABLES' and object_type = 'VIEW';
select distinct owner from dba_objects where object_name = 'DUAL' and object_type = 'TABLE';

--2.Who is the owner of synonym DBA_TABLES? (or synonym DUAL) (owner)
select distinct owner from dba_objects where object_name = 'DBA_TABLES' and object_type = 'SYNONYM';
select distinct owner from dba_objects where object_name = 'DUAL' and object_type = 'SYNONYM';

--3.What kind of objects the database user ORAUSER has? (dba_objects.object_type column)
select distinct object_type from dba_objects where owner = 'ORAUSER';

--4.What are the object types existing in the database? (object_type) 
select distinct object_type from dba_objects order by object_type;

--5.Which users have more than 10 different kind of objects in the database? (owner)
select owner from dba_objects group by owner having count(distinct object_type) > 10;

--6.Which users have both triggers and views in the database? (owner)
select owner from dba_objects where object_type = 'TRIGGER'
INTERSECT
select owner from dba_objects where object_type = 'VIEW';

--7.Which users have views but don't have triggers? (owner)
select owner from dba_objects where object_type = 'VIEW'
MINUS
select owner from dba_objects where object_type = 'TRIGGER';

--8.Which users have more than 40 tables, but less than 30 indexes? (owner)
select owner from dba_objects where object_type = 'TABLE' group by owner having count(*) > 40
INTERSECT
select owner from dba_objects where object_type = 'INDEX' group by owner having count(*) < 30;

--9.Let's see the difference between a table and a view (dba_objects.data_object_id).
select * from dba_objects where object_type = 'TABLE' fetch next 5 rows only;
select * from dba_objects where object_type = 'VIEW' fetch next 5 rows only;  --null

--10.Which object types have NULL (or 0) in the column data_object_id? (object_type)
select distinct object_type from dba_objects where data_object_id is null;

--11.Which object types have non NULL (and non 0) in the column data_object_id? (object_type)
select distinct object_type from dba_objects where data_object_id is not null;

--12.What is the intersection of the previous 2 queries? (object_type)
select distinct object_type from dba_objects where data_object_id is null
INTERSECT
select distinct object_type from dba_objects where data_object_id is not null;

-----------------------------------------------
select * from dba_tab_columns;

--13.How many columns nikovits.emp table has? (num)
select count(*) as num from dba_tab_columns where owner = 'NIKOVITS' and table_name = 'EMP';

--14.What is the data type of the 6th column of the table nikovits.emp? (data_type)
select data_type from dba_tab_columns where owner = 'NIKOVITS' and table_name = 'EMP' and column_id = 6;

--15.Give the owner and name of the tables which have column name beginning with letter 'Z'.(owner, table_name)
select owner, table_name from dba_tab_columns where owner like 'Z%';

--16.Give the owner and name of the tables which have at least 8 columns with data type DATE.(owner, table_name)
select owner, table_name from dba_tab_columns where data_type = 'DATE' group by owner, table_name having count(*) > 8;

--17.Give the owner and name of the tables whose 1st and 4th column's datatype is VARCHAR2.(owner, table_name)
select owner, table_name from dba_tab_columns where data_type = 'VARCHAR2' and column_id in (1, 4);

/*18.Write a PL/SQL procedure, which prints out the owners and names of the tables beginning with the 
parameter character string. */
CREATE OR REPLACE PROCEDURE table_print(p_char VARCHAR2) IS
   cursor mycursor Is
     select owner, table_name from dba_tables where owner like p_char || '%';
     
BEGIN
   for rec_row in mycursor
   loop
           DBMS_OUTPUT.PUT_LINE(rec_row.owner || ' ' || rec_row.table_name);
   end loop;
END;

set serveroutput on
execute table_print('I');

--without cursor
CREATE OR REPLACE PROCEDURE table_print(p_char VARCHAR2) IS     
BEGIN
   for rec_row in(
   select owner, table_name from dba_tables where owner like p_char || '%')
   loop
           DBMS_OUTPUT.PUT_LINE(rec_row.owner || ' ' || rec_row.table_name);
   end loop;
END;

set serveroutput on
execute table_print('I');

--------------------------------
CREATE TABLE test1(col1 INTEGER PRIMARY KEY, col2 VARCHAR2(20));

--sequence creation
CREATE SEQUENCE seq1 
MINVALUE 1 MAXVALUE 100 INCREMENT BY 5 START WITH 50 CYCLE;

CREATE OR REPLACE TRIGGER test1_bir -- before insert row
BEFORE INSERT ON test1 
FOR EACH ROW 
WHEN (new.col1 is null) 
BEGIN
  :new.col1 := seq1.nextval;
END;
/
BEGIN
 FOR i IN 1..14 LOOP 
  INSERT INTO test1 VALUES(null, 'trigger'||to_char(i,'FM09'));
 END LOOP;
 INSERT INTO test1 VALUES(seq1.currval + 1, 'sequence + 1'); 
 COMMIT;
END;
/
SELECT * FROM test1 ORDER BY col2;

DROP TABLE test1;    -- trigger will be dropped too
DROP sequence seq1;  -- sequence is not bound to the table


-----------------------------------------------
--Compulsory exercise
drop table PR01;
CREATE TABLE PR01 AS
SELECT object_name FROM dba_objects where owner = 'NIKOVITS' and object_name like  '%B%';

select * from PR01;














