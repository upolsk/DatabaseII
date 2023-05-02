--5. Give the name and size of the BITMAP indexes whose owner is ’NIKOVITS’ (Index_name, Size) 
select i.index_name, sum(s.bytes) as size_of_index
from dba_indexes i, dba_segments s
where i.owner = 'NIKOVITS' and s.owner = 'NIKOVITS' 
and i.index_type = 'BITMAP' and i.index_name = s.segment_name
group by i.index_name
order by sum(s.bytes) desc;

with t1 as(select segment_name, bytes from dba_segments where owner = 'NIKOVITS'),
t2 as(select index_name from dba_indexes where owner = 'NIKOVITS' and index_type = 'BITMAP')
select t2.index_name, t1.bytes from t1 join t2 on t1.segment_name = t2.index_name order by t1.bytes desc;

--5.Give the name and size of all indexes that index tables that have the letter ‘M’ in their name. Select the table name also (index_name, size, table_name).  

with t1 as(select * from dba_segments where segment_type = 'INDEX'),
t2 as(select owner, index_name, table_name from dba_indexes where table_name like '%M%')
select t2.index_name, t1.bytes, t2.table_name from t1 join t2 on t1.segment_name = t2.index_name and t1.owner = t2.owner order by t1.bytes desc;


select * from dba_indexes;
select i.index_name, sum(s.bytes) as size_of_index, i.table_name
from dba_indexes i, dba_segments s
where i.owner = s.owner and i.table_name like '%M%'
and s.segment_name = i.table_name 
group by i.index_name, i.table_name
order by sum(s.bytes) desc;



----5.Give the name and size of all indexes that index tables that have the letter ‘M’ in their name.
--Select the table name also (index_name, size, table_name).

with
    t as
        (select owner, index_name, table_name from DBA_INDEXES where table_name like ('%M%'))
select  t.index_name, t.table_name, sm.bytes from t join dba_segments sm on
(t.owner = sm.owner and t.index_name = sm.segment_name and sm.segment_type = 'INDEX') order by bytes desc;

--5.Give the name and size of indexes having 2 columns (or expressions) whose owner is NIKOVITS. (Index_name, Size)
SELECT * FROM DBA_IND_COLUMNS;
with t1 as(select distinct(segment_name), bytes from dba_segments where owner = 'NIKOVITS'),
t2 as(select index_name from dba_ind_columns where index_owner = 'NIKOVITS' group by index_name having count(*)=2)
select t2.index_name, t1.bytes from t1 join t2 on t1.segment_name = t2.index_name order by t1.bytes;


