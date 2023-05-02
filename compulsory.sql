CREATE OR REPLACE PROCEDURE print_histogram (p_owner varchar, p_table varchar, p_col varchar) IS
    command varchar2(1000);
    max_occur number(15);
    type cur_ref  is ref CURSOR;
    type outputres is record 
    (
        fname varchar(200),
        freq number(10)
    );
    
    res outputres;
    c cur_ref;
    rowcnt number(10);
    table_not_found exception;
    pragma EXCEPTION_INIT(table_not_found, -00942);
begin   

    command := 'select max(count(*)) from '|| p_owner ||'.'|| p_table ||' group by '|| p_col;
    execute immediate command INTO max_occur;
    
    command := 'select count(count(*)) from '|| p_owner ||'.'|| p_table ||' group by ' || p_col;
    execute immediate command INTO rowcnt;
    
    if rowcnt >= 100 or rowcnt <= 0 then
        dbms_output.put_line('Few or too many distinct values in column');
        return;
    end if;
    command := 'select '|| p_col ||' ,count(*)  from '|| p_owner ||'.'|| p_table || ' where '|| p_col ||' is not null group by '|| p_col || ' order by '|| p_col;
    open c for command;
    loop
        fetch c into res;
        exit when c%NOTFOUND;
        dbms_output.put(res.fname || ' --> ');
        for i in 0..(res.freq / (max_occur/50)) loop
            dbms_output.put('*');
        end loop;
        
        dbms_output.put_line('');
        
        
    end loop;
    
    close c;
    exception
    when table_not_found then 
        dbms_output.put_line('Non-existing table or column');   
end;


set serveroutput on
CALL print_histogram('nikovits','customers','cust_credit_limit');
CALL print_histogram('nikovits','customers','cust_income_level');
CALL print_histogram('nikovits','customers','cust_year_of_birth');
CALL print_histogram('nikovits','employees','department_id');
CALL print_histogram('nikovits','employees','job_id');
CALL print_histogram('nikovits','supply','sdate');
CALL print_histogram('nikovits','xxx','xxx');
CALL print_histogram('nikovits','calls_v','call_date');
CALL print_histogram('nikovits','customers','cust_income_level');
CALL print_histogram('nikovits','customers','cust_year_of_birth');

alter session set nls_date_format='yyyy.mm.dd';
CALL print_histogram('nikovits','supply','sdate');
