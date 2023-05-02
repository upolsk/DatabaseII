--4. Give the index organized tables of user NIKOVITS. (table_name)
select table_name from dba_tables where owner = 'NIKOVITS' and iot_type = 'IOT';
select distinct iot_name from dba_tables;
select distinct index_type from dba_indexes;
--Find the table_name, index_name and overflow name (if exists) of the above tables. (table_name, index_name, overflow_name)
select i.table_name, t.iot_name, i.index_name, t.table_name as overflow_name
from dba_indexes i, dba_tables t
where i.table_name = t.iot_name and
i.index_type = 'IOT - TOP' and
t.owner = 'NIKOVITS' and i.owner = 'NIKOVITS';

select i.table_name table_name, index_name index_name, t.table_name overflow_name
from dba_indexes i full outer join
(SELECT table_name, iot_name, owner
FROM dba_tables
where iot_type = 'IOT_OVERFLOW'
) 
t
on i.table_name = t.iot_name
and i.owner = t.owner
where i.index_type like 'IOT%'
and i.owner = 'NIKOVITS';

SELECT t.table_name, t.iot_name, i.index_name 
FROM dba_tables t,
(select owner, index_name, table_name
from dba_indexes) i
WHERE t.owner='NIKOVITS'
and t.owner = i.owner
and i.table_name = t.iot_name
and t.iot_type = 'IOT_OVERFLOW';

select * from dba_tables;

select iot_name
from dba_tables
where owner = 'NIKOVITS'
and not iot_name is null;

select object_id table_oid
from dba_objects o,
(select i.table_name table_name, index_name index_name, t.table_name overflow_name
from dba_indexes i full outer join
(SELECT table_name, iot_name, owner
FROM dba_tables
where iot_type = 'IOT_OVERFLOW'
) 
t
on i.table_name = t.iot_name
and i.owner = t.owner
where i.index_type like 'IOT%'
and i.owner = 'NIKOVITS');

--5. Give the names and sizes (in bytes) of the partitions of table NIKOVITS.ELADASOK (name, size)
DESCRIBE DBA_SEGMENTS;
select tablespace_name, partition_name, segment_name, bytes from dba_segments
where owner = 'NIKOVITS' and segment_name = 'ELADASOK' and segment_type = 'TABLE PARTITION';

select segment_name, partition_name, bytes
from dba_segments
where segment_name = 'ELADASOK'
and owner = 'NIKOVITS';

select segment_name, partition_name, sum(bytes)
from dba_extents
where segment_name = 'ELADASOK'
and owner = 'NIKOVITS'
group by segment_name, partition_name;

--6. Which is the biggest partitioned table (in bytes) in the database? (owner, name, size). 
--It can have subpartitions as well.
select distinct segment_type from dba_segments;
select owner, segment_name, sum(bytes) from dba_segments
where segment_type in ('TABLE PARTITION', 'TABLE SUBPARTITION')
group by segment_name, owner order by sum(bytes) desc fetch next 1 row only;


select owner, segment_name, sum(bytes)
from dba_segments
where segment_type like 'TABLE%PARTITION'
group by owner, segment_name
having sum(bytes) =
(select max(sum(bytes)) m
from dba_segments
where segment_type like 'TABLE%PARTITION'
group by owner, segment_name);
--7. Give a cluster whose cluster key consists of 3 columns. (owner, name)
--A cluster can have more than two tables on it!!!
select * from dba_tables;
select owner, cluster_name, count(clu_column_name) from dba_clu_columns
group by owner, cluster_name
having count(clu_column_name) >= 3;

--8. List the clusters which use NOT THE DEFAULT hash function. (owner, name)
--(So the creator defined a hash expression.)
select * from dba_cluster_hash_expressions;

select count(*)
from DBA_CLUSTERs
where cluster_type = 'HASH'
and not function = 'DEFAULT%';


--Compulsory exercise
/*9.Write a PL/SQL procedure which prints out the storage type (heap organized, partitioned, index organized or clustered) 
for the parameter table. Output should look like the following:
   Clustered: NO Partitioned: YES IOT: NO*/
select cluster_name from dba_tables;
CREATE OR REPLACE PROCEDURE print_type(p_owner VARCHAR2, p_table VARCHAR2) IS
is_partitioned varchar(100);
is_index_organized varchar(100);
is_clustered varchar(100);

BEGIN
    select partitioned, iot_type, cluster_name into is_partitioned, is_index_organized, is_clustered
    from dba_tables
    where owner = upper(p_owner) and table_name = upper(p_table);
    DBMS_OUTPUT.PUT_LINE('Partitioned: ' || is_partitioned);
    DBMS_OUTPUT.PUT_LINE('Iot: ' || coalesce(is_index_organized, 'NO'));
    DBMS_OUTPUT.PUT_LINE('Clustered: ' || coalesce(is_clustered, 'NO'));
END;

set serveroutput on
execute print_type('nikovits', 'emp');
execute print_type('nikovits', 'eladasok5');
execute print_type('nikovits', 'cikk_iot');
execute print_type('nikovits', 'emp_clt');


SELECT owner, table_name, cluster_name, partitioned, iot_type 
FROM dba_tables WHERE owner='NIKOVITS' 
AND table_name IN ('EMP', 'ELADASOK5', 'CIKK_IOT', 'EMP_CLT');

EXECUTE check_plsql('print_type(''nikovits'',''emp_clt'')');


