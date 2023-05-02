--EXERCISE 6
--Give the sum amount of products where the color of the product is 'kek' (color = 'kek') and the status of the supplier is 20. Give hints in order to get the following execution plans:
--PRODUCT(prod_id, name, color, weight)
--
--SUPPLIER(supl_id, name, status, address)
--
--PROJECT(proj_id, name, address)
--
--SUPPLY(supl_id, prod_id, proj_id, amount, sDate)

EXPLAIN PLAN SET STATEMENT_ID = 'f1' FOR 
select sum(s.amount) from product p, supply s, supplier sp
where p.prod_id = s.prod_id and s.supl_id = sp.supl_id
and  p.color = 'kek' and sp.status = 20;

select plan_table_output from table(dbms_xplan.display('plan_table', 'f1', 'all'));
---------------------------------------------------------------------------------
| Id  | Operation            | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |          |     1 |    26 |    20   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE      |          |     1 |    26 |            |          |
|*  2 |   HASH JOIN          |          |   228 |  5928 |    20   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL | SUPPLIER |     4 |    24 |     3   (0)| 00:00:01 |
|*  4 |    HASH JOIN         |          |   910 | 18200 |    17   (0)| 00:00:01 |
|*  5 |     TABLE ACCESS FULL| PRODUCT  |    91 |   910 |     4   (0)| 00:00:01 |
|   6 |     TABLE ACCESS FULL| SUPPLY   | 10000 |    97K|    13   (0)| 00:00:01 |
---------------------------------------------------------------------------------


--In the execution plan all joins should be HASH JOIN join, and no index should be used for any table.
--FIRST WAY(FULL)
EXPLAIN PLAN SET STATEMENT_ID = 'f2' FOR 
select /*+ USE_HASH(p, s, sp) FULL(p) FULL(s) FULL(sp) */ sum(s.amount) from product p, supply s, supplier sp
where p.prod_id = s.prod_id and s.supl_id = sp.supl_id
and  p.color = 'kek' and sp.status = 20;

select plan_table_output from table(dbms_xplan.display('plan_table', 'f2', 'all'));
--SECOND WAY(NO_INDEX)
EXPLAIN PLAN SET STATEMENT_ID = 'f2a' FOR 
select /*+ USE_HASH(p, s, sp) NO_INDEX(p) NO_INDEX(s) NO_INDEX(sp) */ sum(s.amount) from product p, supply s, supplier sp
where p.prod_id = s.prod_id and s.supl_id = sp.supl_id
and  p.color = 'kek' and sp.status = 20;

select plan_table_output from table(dbms_xplan.display('plan_table', 'f2a', 'all'));

---------------------------------------------------------------------------------
| Id  | Operation            | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |          |     1 |    26 |    20   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE      |          |     1 |    26 |            |          |
|*  2 |   HASH JOIN          |          |   228 |  5928 |    20   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL | SUPPLIER |     4 |    24 |     3   (0)| 00:00:01 |
|*  4 |    HASH JOIN         |          |   910 | 18200 |    17   (0)| 00:00:01 |
|*  5 |     TABLE ACCESS FULL| PRODUCT  |    91 |   910 |     4   (0)| 00:00:01 |
|   6 |     TABLE ACCESS FULL| SUPPLY   | 10000 |    97K|    13   (0)| 00:00:01 |

--In the execution plan all joins should be SORT-MERGE join, and one index should be used for the supplier table.
EXPLAIN PLAN SET STATEMENT_ID = 'f3' FOR 
select /*+ USE_MERGE(p, s, ps) INDEX(sp) NO_INDEX(p) NO_INDEX(s) */ sum(s.amount) from product p, supply s, supplier sp
where p.prod_id = s.prod_id and s.supl_id = sp.supl_id
and  p.color = 'kek' and sp.status = 20;

select plan_table_output from table(dbms_xplan.display('plan_table', 'f3', 'all'));

| Id  | Operation                               | Name            | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |                 |     1 |    26 |    21  (10)| 00:00:01 |
|   1 |  SORT AGGREGATE                         |                 |     1 |    26 |            |          |
|   2 |   MERGE JOIN                            |                 |   228 |  5928 |    21  (10)| 00:00:01 |
|   3 |    SORT JOIN                            |                 |  2500 | 40000 |    16   (7)| 00:00:01 |
|*  4 |     HASH JOIN                           |                 |  2500 | 40000 |    15   (0)| 00:00:01 |
|*  5 |      TABLE ACCESS BY INDEX ROWID BATCHED| SUPPLIER        |     4 |    24 |     2   (0)| 00:00:01 |
|   6 |       INDEX FULL SCAN                   | SUPPLIER_ID_IDX |    15 |       |     1   (0)| 00:00:01 |
|   7 |      TABLE ACCESS FULL                  | SUPPLY          | 10000 |    97K|    13   (0)| 00:00:01 |
|*  8 |    SORT JOIN                            |                 |    91 |   910 |     5  (20)| 00:00:01 |
|*  9 |     TABLE ACCESS FULL                   | PRODUCT         |    91 |   910 |     4   (0)| 00:00:01 |
----------------------------------------------------------------------------------
--In the execution plan all joins should be NESTED LOOP join, and two index should be used.
EXPLAIN PLAN SET STATEMENT_ID = 'f4' FOR 
select /*+ USE_NL(p, s, ps) INDEX(p) INDEX(s) NO_INDEX(sp) */ sum(s.amount) from product p, supply s, supplier sp
where p.prod_id = s.prod_id and s.supl_id = sp.supl_id
and  p.color = 'kek' and sp.status = 20;

select plan_table_output from table(dbms_xplan.display('plan_table', 'f4', 'all'));
-----------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name            | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |                 |     1 |    26 |   917   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE                         |                 |     1 |    26 |            |          |
|*  2 |   HASH JOIN                             |                 |   228 |  5928 |   917   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL                    | SUPPLIER        |     4 |    24 |     3   (0)| 00:00:01 |
|   4 |    NESTED LOOPS                         |                 |   910 | 18200 |   914   (0)| 00:00:01 |
|   5 |     NESTED LOOPS                        |                 |   910 | 18200 |   914   (0)| 00:00:01 |
|   6 |      TABLE ACCESS BY INDEX ROWID BATCHED| PRODUCT         |    91 |   910 |     5   (0)| 00:00:01 |
|*  7 |       INDEX RANGE SCAN                  | PROD_COLOR_IDX  |    91 |       |     1   (0)| 00:00:01 |
|*  8 |      INDEX RANGE SCAN                   | SUPPLY_PROD_IDX |    10 |       |     1   (0)| 00:00:01 |
|   9 |     TABLE ACCESS BY INDEX ROWID         | SUPPLY          |    10 |   100 |    10   (0)| 00:00:01 |



--EXERCISE 7
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
            