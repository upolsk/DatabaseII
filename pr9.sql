/*Give a SELECT statement which has the following execution plan (owner of tables is NIKOVITS)
a)

SELECT STATEMENT +  +

  SORT + ORDER BY +

    FILTER +  +

      HASH + GROUP BY +

        NESTED LOOPS +  +

          NESTED LOOPS +  +

            TABLE ACCESS + FULL + NIKOVITS.SUPPLY

            INDEX + UNIQUE SCAN + NIKOVITS.PROD_ID_IDX

          TABLE ACCESS + BY INDEX ROWID + NIKOVITS.PRODUCT*/
          
EXPLAIN PLAN SET STATEMENT_ID = 'c1' FOR
select /*+ordered use_nl(s,p)  index(p PROD_ID_IDX)*/ sum(amount), sDate
from nikovits.supply s natural join nikovits.product p   
where color  = 'piros'  
group by sDate
having count(*) = 2
order by sum (prod_id) ;
select plan_table_output from table(dbms_xplan.display('plan_table', 'c1', 'all'));
          
/*b)

SELECT STATEMENT +  +

  SORT + ORDER BY +

    FILTER +  +

      HASH + GROUP BY +

        MERGE JOIN +  +

          SORT + JOIN +

            TABLE ACCESS + BY INDEX ROWID BATCHED + NIKOVITS.PRODUCT

              INDEX + RANGE SCAN + NIKOVITS.PROD_COLOR_IDX

          SORT + JOIN +

            TABLE ACCESS + FULL + NIKOVITS.SUPPLY*/
EXPLAIN PLAN SET STATEMENT_ID = 'c2' FOR
select /*+USE_MERGE(s, p)  index(p PROD_COLOR_IDX)*/ sum(amount), sDate
from nikovits.supply s natural join nikovits.product p   
where color  = 'piros'  
group by sDate
having count(*) = 2
order by sum (prod_id) ;
select plan_table_output from table(dbms_xplan.display('plan_table', 'c2', 'all'));            
            