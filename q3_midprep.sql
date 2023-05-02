/*Write a PL/SQL procedure which prints out the number of rows in each data block for the  
following table: NIKOVITS.CUSTOMERS. The output has 3 columns: file_id, block_id, num_of_rows. */

create or replace procedure num_of_rows is
    c integer;
begin
    for rec in (select file_id, block_id, blocks
                from dba_extents
                where owner = 'NIKOVITS' and segment_name = 'CIKK')
    loop
        for bno in rec.block_id..rec.block_id + rec.blocks - 1
        loop
            select
            count(DBMS_ROWID.ROWID_ROW_NUMBER(rowid))
            into c 
            from nikovits.cikk
            where DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid) = bno having sum(DBMS_ROWID.ROWID_ROW_NUMBER(rowid))>10 fetch next 1 row only ;
            dbms_output.put_line(TO_CHAR(rec.file_id) ||'; '||TO_CHAR(bno) || '; ' || TO_CHAR(c));
        end loop;
    end loop;
end;

SET SERVEROUTPUT ON 
execute num_of_rows(); 

/*7.Write a PL/SQL procedure which prints out the data blocks of table NIKOVITS. TABLA_123 
in which the number of records is greater than 40. The output has 3 columns: File_id, Block_number 
and the number of records within that block. Columns are separated by semicolons. */
create or replace procedure gt_40 is
row_id integer;
    c integer;
begin
    for rec in (select file_id, block_id, blocks
                from dba_extents
                where owner = 'NIKOVITS' and segment_name = 'TABLA_123')
    loop
            select count(DBMS_ROWID.ROWID_ROW_NUMBER(rowid))
            into  c
            from nikovits.tabla_123
            having count(DBMS_ROWID.ROWID_ROW_NUMBER(rowid)) >= 10;
            dbms_output.put_line(TO_CHAR(rec.file_id) ||'; '||TO_CHAR(rec.block_id) || '; ' || TO_CHAR(c));
    end loop;
end;


set serveroutput on 
EXECUTE gt_40(); 


EXECUTE check_plsql('gt_40()');

