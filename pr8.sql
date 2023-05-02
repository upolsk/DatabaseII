select * from product;
select * from supplier;
select * from supply;

EXPLAIN PLAN SET STATEMENT_ID = 'st0801' FOR
select sum(amount) from supply 
where prod_id = 2 and supl_id = 2;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0801', 'all'));

--a
EXPLAIN PLAN SET STATEMENT_ID = 'st0801a' FOR
select /*+ NO_INDEX(s) */ sum(amount)
from supply s
where prod_id = 2 and supl_id = 2;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0801a', 'all'));

EXPLAIN PLAN SET STATEMENT_ID = 'st0801b' FOR
select /*+ AND_EQUAL(s supply_prod_idx supply_supplier_idx) */ sum(amount)
from supply s
where prod_id = 2 and supl_id = 2;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0801b', 'all'));



Paper View
EXPLAIN PLAN SET STATEMENT_ID = 'st0801' FOR
select sum(amount) from nikovits.supply
where prod_id = 2 and supl_id = 2;

select plan_table_output from table(dbms_xplan.display('plan_table', 'st0801', 'all'));

/*Plan hash value: 3483641256

----------------------------------------------------------------------------------------------------
| Id | Operation | Name | Rows | Bytes | Cost (%CPU)| Time |
----------------------------------------------------------------------------------------------------
| 0 | SELECT STATEMENT | | 1 | 21 | 4 (0)| 00:00:01 |
| 1 | SORT AGGREGATE | | 1 | 21 | | |
|* 2 | TABLE ACCESS BY INDEX ROWID| SUPPLY | 1 | 21 | 4 (0)| 00:00:01 |
| 3 | AND-EQUAL | | | | | |
|* 4 | INDEX RANGE SCAN | SUPPLY_PROD_IDX | 40 | | 1 (0)| 00:00:01 |
|* 5 | INDEX RANGE SCAN | SUPPLY_SUPPLIER_IDX | 40 | | 3 (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

1 - SEL$1
2 - SEL$1 / S@SEL$1
4 - SEL$1 / S@SEL$1

Predicate Information (identified by operation id):
---------------------------------------------------

2 - filter("PROD_ID"=2 AND "SUPL_ID"=2)
4 - access("PROD_ID"=2)
5 - access("SUPL_ID"=2)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

1 - (#keys=0) SUM("AMOUNT")[22]
2 - "AMOUNT"[NUMBER,22]
3 - "S".ROWID[ROWID,10], "SUPL_ID"[NUMBER,22], "PROD_ID"[NUMBER,22]
4 - ROWID[ROWID,10], "PROD_ID"[NUMBER,22]
5 - ROWID[ROWID,10], "SUPL_ID"[NUMBER,22]
*/


--Give the sum amount of products where the color of product is 'piros' and address of supplier is 'Pecs'.
EXPLAIN PLAN SET STATEMENT_ID = 'st0802' FOR
select sum(sp.amount) from supply sp, supplier s, product p
where sp.prod_id = p.prod_id and sp.supl_id = s.supl_id and s.address = 'Pecs' and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0802', 'all'));

EXPLAIN PLAN SET STATEMENT_ID = 'st0802a' FOR
select /*+ ORDERED */ sum(sp.amount) from supply sp, product p, supplier s
where sp.prod_id = p.prod_id and sp.supl_id = s.supl_id and s.address = 'Pecs' and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0802a', 'all'));

/*
SELECT STATEMENT +  + 
  SORT + AGGREGATE + 
    TABLE ACCESS + FULL + PRODUCT */
EXPLAIN PLAN SET STATEMENT_ID = 'st0803a' FOR
select sum(weight) from product;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0803a', 'all'));

/*
SELECT STATEMENT +  + 
  SORT + AGGREGATE + 
    TABLE ACCESS + BY INDEX ROWID + PRODUCT
      INDEX + UNIQUE SCAN + PROD_ID_IDX */    
EXPLAIN PLAN SET STATEMENT_ID = 'st0803b' FOR
select /*+ INDEX(product) */sum(weight) from product
where prod_id = 1;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0803b', 'all'));


/* 
SELECT STATEMENT +  + 
  SORT + AGGREGATE + 
    HASH JOIN +  + 
      TABLE ACCESS + FULL + PROJECT
      TABLE ACCESS + FULL + SUPPLY */
EXPLAIN PLAN SET STATEMENT_ID = 'st0803c' FOR
select /*+ NO_INDEX(p) USE_HASH(p, s)*/sum(s.amount) from project p, supply s
where p.proj_id = s.proj_id;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0803c', 'all'));


/*
SELECT STATEMENT +  + 
  HASH + GROUP BY + 
    HASH JOIN +  + 
      TABLE ACCESS + FULL + PROJECT
      TABLE ACCESS + FULL + SUPPLY */
EXPLAIN PLAN SET STATEMENT_ID = 'st0803d' FOR
select /*+ USE_HASH(p, s)*/sum(s.amount), p.name from project p, supply s
where p.proj_id = s.proj_id group by p.name;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0803d', 'all'));

/*
SELECT STATEMENT +  + 
  SORT + AGGREGATE + 
    MERGE JOIN +  + 
      SORT + JOIN + 
        TABLE ACCESS + BY INDEX ROWID BATCHED + PRODUCT
          INDEX + RANGE SCAN + PROD_COLOR_IDX
      SORT + JOIN + 
        TABLE ACCESS + FULL + SUPPLY */
EXPLAIN PLAN SET STATEMENT_ID = 'st0803e' FOR
select /*+ USE_MERGE(p, s) INDEX(p)*/sum(s.amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0803e', 'all'));

/*
SELECT STATEMENT +  + 
  FILTER +  + 
    HASH + GROUP BY + 
      HASH JOIN +  + 
        TABLE ACCESS + FULL + PROJECT
        HASH JOIN +  + 
          TABLE ACCESS + FULL + SUPPLIER
          TABLE ACCESS + FULL + SUPPLY */
EXPLAIN PLAN SET STATEMENT_ID = 'st0803f' FOR
select /*+ NO_INDEX(sp) USE_HASH(p, sp, s)*/ p.name from project p, supplier sp, supply s
where p.proj_id = s.proj_id and sp.supl_id = s.supl_id group by p.name having count(*) > 9;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0803f', 'all'));

/*Create a new copy from table NIKOVITS.PRODUCT (-> PRODUCT_TMP) and create two bitmap indexes
on columns COLOR and WEIGHT. Write a query which uses both indexes.*/
drop table product_tmp;
create table product_tmp(prod_id, name, color, weight) as select * from nikovits.product;
create bitmap index bitmap_idx_color on product_tmp(color);
create bitmap index bitmap_idx_weight on product_tmp(weight);

select * from product_tmp;
EXPLAIN PLAN SET STATEMENT_ID = 'st0804' FOR
select * from product_tmp
where color = 'piros' and weight between 13 and 17;
select plan_table_output from table(dbms_xplan.display('plan_table', 'st0804', 'all'));
