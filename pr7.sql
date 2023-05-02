create table emp as select * from nikovits.emp;
create table sal_cat as select * from nikovits.sal_cat;
create table dept as select * from nikovits.dept;


create table PLAN_TABLE (
        statement_id       varchar2(30),
        plan_id            number,
        timestamp          date,
        remarks            varchar2(4000),
        operation          varchar2(30),
        options            varchar2(255),
        object_node        varchar2(128),
        object_owner       varchar2(30),
        object_name        varchar2(30),
        object_alias       varchar2(65),
        object_instance    numeric,
        object_type        varchar2(30),
        optimizer          varchar2(255),
        search_columns     number,
        id                 numeric,
        parent_id          numeric,
        depth              numeric,
        position           numeric,
        cost               numeric,
        cardinality        numeric,
        bytes              numeric,
        other_tag          varchar2(255),
        partition_start    varchar2(255),
        partition_stop     varchar2(255),
        partition_id       numeric,
        other              long,
        distribution       varchar2(30),
        cpu_cost           numeric,
        io_cost            numeric,
        temp_space         numeric,
        access_predicates  varchar2(4000),
        filter_predicates  varchar2(4000),
        projection         varchar2(4000),
        time               numeric,
        qblock_name        varchar2(30),
        other_xml          clob
);

drop table plan_table;
--delete from plan_table;
select * from plan_table;

EXPLAIN PLAN SET statement_id='st1'  
   FOR 
select distinct dname from emp e, dept d, sal_cat c
where e.deptno=d.deptno and c.category=1 and e.sal between lowest_sal and highest_sal;

--1st way for execution plan
SELECT LPAD(' ', 2*(level-1))||operation||' + '||options||' + '
  ||object_owner||nvl2(object_owner,'.','')||object_name xplan
FROM plan_table
START WITH id = 0 AND statement_id = 'st1'                 -- 'st1' -> unique name of the statement
CONNECT BY PRIOR id = parent_id AND statement_id = 'st1'   -- 'st1' -> again
ORDER SIBLINGS BY position;

--2nd way for execution plan
select plan_table_output from table(dbms_xplan.display('plan_table', 'st1', 'all'));

create index cat_ind on sal_cat(category);
EXPLAIN PLAN SET statement_id='st2' FOR 
select distinct dname from emp e, dept d, sal_cat c
where e.deptno=d.deptno and c.category=1 and e.sal between lowest_sal and highest_sal;

select plan_table_output from table(dbms_xplan.display('plan_table', 'st2', 'all'));

/*Query: Give the sum amount of products where color = 'piros' ('piros' in Hungarian means 'red'). 
PRODUCT(prod_id, name, color, weight)
SUPPLIER(supl_id, name, status, address)
PROJECT(proj_id, name, address)
SUPPLY(supl_id, prod_id, proj_id, amount, sDate)*/

CREATE TABLE product(prod_id, name, color, weight) AS SELECT * FROM NIKOVITS.CIKK;
CREATE TABLE supplier(supl_id, name, status, address) AS SELECT * FROM nikovits.szallito;
CREATE TABLE project(proj_id, name, address) AS SELECT * FROM nikovits.projekt;
CREATE TABLE supply(supl_id, prod_id, proj_id, amount, sDate) AS SELECT * FROM nikovits.szallit;
GRANT select on product to public;
GRANT select on supplier to public;
GRANT select on project to public;
GRANT select on supply to public;

-- The tables have indexes too.
CREATE INDEX prod_color_idx ON product(color);
CREATE UNIQUE INDEX prod_id_idx ON product(prod_id);
CREATE UNIQUE INDEX proj_id_idx ON PROJECT(proj_id);
CREATE UNIQUE INDEX supplier_id_idx ON supplier(supl_id);
CREATE INDEX supply_supplier_idx ON supply(supl_id);
CREATE INDEX supply_proj_idx ON supply(proj_id);
CREATE INDEX supply_prod_idx ON supply(prod_id);

EXPLAIN PLAN SET STATEMENT_ID = 'ex7' FOR
select sum(amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'ex7', 'all'));

--a) no index at all  //actually by default full
EXPLAIN PLAN SET STATEMENT_ID = 'ex7a' FOR
select /*+ FULL(p) FULL(s) */ sum(amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'ex7a', 'all'));

--b) one index
EXPLAIN PLAN SET STATEMENT_ID = 'ex7b' FOR
select /*+ INDEX(p) */ sum(amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'ex7b', 'all'));

--c) index for both tablesv
EXPLAIN PLAN SET STATEMENT_ID = 'ex7c' FOR
select /*+ INDEX(p) INDEX(s) */ sum(amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'ex7c', 'all'));

--d) SORT-MERGE join
EXPLAIN PLAN SET STATEMENT_ID = 'ex7d' FOR
select /*+ USE_MERGE(p, s) */ sum(amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'ex7d', 'all'));

--e) NESTED-LOOPS join
EXPLAIN PLAN SET STATEMENT_ID = 'ex7e' FOR
select /*+ USE_NL(p,s) */ sum(amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'ex7e', 'all'));

--f) NESTED-LOOPS join and no index
EXPLAIN PLAN SET STATEMENT_ID = 'ex7f' FOR
select /*+ USE_NL(p, s) FULL(s) FULL(p) */ sum(amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'ex7f', 'all'));

--g) HASH join
EXPLAIN PLAN SET STATEMENT_ID = 'ex7g' FOR
select /*+ USE_HASH(p, s) */ sum(amount) from product p, supply s
where p.prod_id = s.prod_id and p.color = 'piros';
select plan_table_output from table(dbms_xplan.display('plan_table', 'ex7g', 'all'));

--Compulsory exercise
create index cat_ind on sal_cat(category);
select distinct dname from emp e, dept d, sal_cat c
where e.deptno=d.deptno and c.category=1 and e.sal between lowest_sal and highest_sal;

--RESEARCH
--MARKETING
--SALES
--
--SELECT STATEMENT + +
-- HASH + UNIQUE +
-- HASH JOIN + SEMI +
-- MERGE JOIN + CARTESIAN +
-- TABLE ACCESS + BY INDEX ROWID BATCHED + IHLG15.SAL_CAT
-- INDEX + RANGE SCAN + IHLG15.CAT_IND
-- BUFFER + SORT +
-- TABLE ACCESS + FULL + IHLG15.DEPT
-- TABLE ACCESS + FULL + IHLG15.EMP
