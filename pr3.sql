select rowid,
dbms_rowid.rowid_relative_fno(ROWID) as file_id,
dbms_rowid.rowid_object(ROWID) as object_id,
dbms_rowid.rowid_block_number(ROWID) as block_nr
from nikovits.emp;

/*1. How many data blocks are allocated in the database for the table NIKOVITS.CIKK?
There can be empty blocks, but we count them too.
The same question: how many data blocks does the segment of the table have?*/
select * from dba_segments;
select blocks from dba_segments
where owner = 'NIKOVITS' and segment_name = 'CIKK' and segment_type = 'TABLE';

/*2. How many filled data blocks does the previous table have?
Filled means that the block is not empty (there is at least one row in it).
This question is not the same as the previous !!!
How many empty data blocks does the table have?*/
select count(distinct(dbms_rowid.rowid_block_number(ROWID))) as filled_blocks
from nikovits.cikk;

--2
select allocated_blocks - filled_blocks as empty_blocks
from (select blocks as allocated_blocks from dba_segments
where owner = 'NIKOVITS' and segment_name = 'CIKK' and segment_type = 'TABLE'),
(select count(distinct dbms_rowid.rowid_block_number(ROWID)) as filled_blocks
from nikovits.cikk);


create or replace function calc_empty_blocks return integer
is
    reserved_blocks integer;
    filled_blocks integer;
    empty_blocks integer;
begin
    select blocks into reserved_blocks
    from dba_segments
    where owner = 'NIKOVITS' and segment_name = 'CIKK';

    select count(distinct DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid))
    into filled_blocks
    from nikovits.cikk;

    empty_blocks := reserved_blocks - filled_blocks;
    return empty_blocks;
end;

select calc_empty_blocks() from dual;

-- 3. How many rows are there in each block of the previous table?
select DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid) as block_number, 
count(*) as row_number
from nikovits.cikk
group by DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid);

/* 4.There is a table NIKOVITS.ELADASOK which has the following row:
szla_szam = 100 (szla_szam is a column name)
In which datafile is the given row stored?
Within the datafile in which data block? (block number) 
In which data object? (Give the name of the segment.)*/
select el.rowid,
dbms_rowid.rowid_relative_fno(el.ROWID) as file_id,
dbms_rowid.rowid_object(el.ROWID) as object_id,
dbms_rowid.rowid_block_number(el.ROWID) as block_nr, df.file_name, ob.object_name, ob.object_type 
from NIKOVITS.ELADASOK el, dba_objects ob, dba_data_files df 
WHERE el.szla_szam = 100 and df.file_id = dbms_rowid.rowid_relative_fno(el.ROWID)
and ob.object_id = dbms_rowid.rowid_object(el.ROWID);




create or replace procedure get_file_and_segment is
    fno integer;
    bno integer;
    ono integer;
    fname varchar(100);
    sname varchar(100);
begin
    select DBMS_ROWID.ROWID_RELATIVE_FNO(rowid),
    DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid),
    DBMS_ROWID.ROWID_OBJECT(rowid)
    into fno, bno, ono
    from nikovits.eladasok
    where szla_szam = 100;
    
    select file_name into fname
    from dba_data_files
    where relative_fno = fno;
    
    select segment_name into sname
    from dba_segments
    where relative_fno = fno 
    and bno between header_block and header_block + blocks;
    
    dbms_output.put_line(fname || ' - ' || TO_CHAR(bno) || ' - ' || sname);
end;

set serveroutput on
execute get_file_and_segment();
call get_file_and_segment();

describe dba_data_files;

/*5.
Write a PL/SQL procedure which prints out the number of rows in each data block for the 
following table: NIKOVITS.TABLA_123. (Output format:  file_id; block_id -> num_of_rows.
Hint:
List the extents of the table. You can find the first data block of the extent and the size of the extent (in blocks)
in DBA_EXTENTS. Check the individual data blocks, how many rows they contain. (--> ROWID helps you)*/
describe dba_extents;
select block_id, file_id, blocks from dba_extents where segment_name = 'TABLA_123' and segment_type = 'TABLE' and owner = 'NIKOVITS';

CREATE OR REPLACE PROCEDURE num_of_rows IS 
cnt number;
BEGIN
   for rec in(select block_id, file_id, blocks from dba_extents where segment_name = 'TABLA_123' and segment_type = 'TABLE' and owner = 'NIKOVITS') loop
      for i in 1..rec.blocks loop
          select count(*) into cnt from nikovits.tabla_123 where rec.file_id = dbms_rowid.rowid_relative_fno(ROWID)
          and rec.block_id + i - 1 = dbms_rowid.rowid_block_number(ROWID);
      DBMS_OUTPUT.PUT_LINE(rec.file_id || ' ' || to_char(rec.block_id) || ' ' || to_char(rec.block_id + i - 1) || ' ' || to_char(cnt));
      end loop;
   end loop;
END;

SET SERVEROUTPUT ON
execute num_of_rows();
execute check_plsql('num_of_rows()');

create or replace procedure num_of_rows is
    c integer;
begin
    for rec in (select file_id, block_id, blocks
                from dba_extents
                where owner = 'NIKOVITS' and segment_name = 'TABLA_123')
    loop
        for bno in rec.block_id..rec.block_id + rec.blocks - 1
        loop
            select
            count(DBMS_ROWID.ROWID_ROW_NUMBER(rowid))
            into c
            from nikovits.tabla_123
            where DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid) = bno;
            dbms_output.put_line(TO_CHAR(rec.file_id) ||'; '||TO_CHAR(bno) || ' -> ' || TO_CHAR(c));
        end loop;
    end loop;
end;

execute check_plsql('num_of_rows()');


-----------------------------------------------
--Compulsory exercise
/*6.Write a PL/SQL procedure which counts and prints the number of empty blocks of a table.
Output format -> Empty Blocks: nnn*/

CREATE OR REPLACE PROCEDURE empty_blocks(p_owner VARCHAR2, P_table VARCHAR2) IS
   allocated integer;
   filled integer;
   qr varchar(500);
BEGIN
   select blocks into allocated
   from dba_segments
   where segment_name = upper(p_table) and
   segment_type = 'TABLE' and
   owner = upper(p_owner);

   qr := 'select count(*) from
         (select distinct 
         dbms_rowid.rowid_block_number(ROWID) as block_number
         from ' || p_owner || '.' || p_table ||')';
         
    EXECUTE IMMEDIATE qr INTO filled;
    
    dbms_output.put_line('EmptyBlocks:'||to_char(allocated-filled)); 
END;   

set serveroutput on
EXECUTE empty_blocks('nikovits', 'employees');

EXECUTE check_plsql('empty_blocks(''nikovits'', ''employees'')');