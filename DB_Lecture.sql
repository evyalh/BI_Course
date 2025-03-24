--========================================================================
--==================Basic entities on Postgres DB
--========================================================================

--==================VIEW

CREATE VIEW customer_managers AS
SELECT 
    custid, 
    companyname, 
    contactname, 
    contacttitle, 
    address, 
    city, 
    region, 
    postalcode, 
    country, 
    phone, 
    fax
FROM 
    public.customer
WHERE 
    contacttitle LIKE '%Manager%' 
    OR contacttitle LIKE '%Owner%';


--==================PROCEDURE

--==================Create new table
-- DROP TABLE IF EXISTS public.product_restock;

CREATE TABLE IF NOT EXISTS public.product_restock
(
    productid integer NOT NULL DEFAULT nextval('product_productid_seq'::regclass),
    productname character varying(40) COLLATE pg_catalog."default" NOT NULL,
    supplierid integer,
    categoryid integer,
    quantityperunit character varying(20) COLLATE pg_catalog."default",
    unitprice numeric(10,2),
    unitsinstock smallint,
    unitsonorder smallint,
    reorderlevel smallint,
    discontinued character(1) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT product_restock_pkey PRIMARY KEY (productid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.product
    OWNER to postgres;

--==================Populate new table
INSERT INTO public.product_restock (
    productid, 
    productname, 
    supplierid, 
    categoryid, 
    quantityperunit, 
    unitprice, 
    unitsinstock, 
    unitsonorder, 
    reorderlevel, 
    discontinued
)
SELECT 
    productid, 
    productname, 
    supplierid, 
    categoryid, 
    quantityperunit, 
    unitprice, 
    unitsinstock, 
    unitsonorder, 
    reorderlevel, 
    discontinued
FROM public.product;

--==================PROCEDURE

--Function to Calculate and Apply Percentage Increase

CREATE OR REPLACE PROCEDURE update_products_prices(supplier_id INT, percentage INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update the price for products of specific supplier
    UPDATE product_restock
    SET unitprice = cast(unitprice * (1 + (percentage * 1.0 / 100)) as numeric(10,2))
    WHERE supplierid = supplier_id;

    -- Raise a notice to indicate the operation
    RAISE NOTICE 'Products by Supplier ID # % experienced price change by % percentage.', supplier_id, percentage;
END;
$$;

CALL update_products_prices(7, 10);

select supplierid, unitprice
from product_restock
where supplierid=7
order by 2 limit 5

select supplierid, unitprice
from product
where supplierid=7
order by 2 limit 5


--==================FUNCTION

--Get Total Sales by Employee
--This function calculates the total sales (order amounts) for a given employee, optionally filtered by a year

CREATE OR REPLACE FUNCTION get_total_sales_by_employee(employee_id INT, sales_year INT DEFAULT NULL)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales NUMERIC := 0;
BEGIN
    SELECT SUM(od.unitprice * od.qty * (1 - od.discount))
    INTO total_sales
    FROM salesorder o
    JOIN orderdetail od ON o.orderid = od.orderid
    WHERE o.empid = employee_id
      AND (sales_year IS NULL OR EXTRACT(YEAR FROM o.orderdate) = sales_year);

    RETURN total_sales;
END;
$$;

--Get total sales for a specific employee without year filtering:

SELECT get_total_sales_by_employee(5);

--Get total sales for a specific employee for a specific year:

SELECT get_total_sales_by_employee(5, 2006);


--========================================================================
--==================Reserved words on Postgres DB
--========================================================================

CREATE TABLE example (
    user VARCHAR(50)
);

CREATE TABLE example (
    "user" VARCHAR(50)
);

--========================================================================
--==================Query systables on Postgres DB
--========================================================================

--Get a List of Tables
--This query lists all the tables in the current database under a specific schema (e.g., public):

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;

--Get a List of Indexes per Table
--This query lists all indexes for each table in the current database:

SELECT 
    t.relname AS table_name,
    i.relname AS index_name,
    pg_size_pretty(pg_relation_size(i.oid)) AS index_size
FROM 
    pg_class t
JOIN 
    pg_index ix ON t.oid = ix.indrelid
JOIN 
    pg_class i ON i.oid = ix.indexrelid
WHERE 
    t.relkind = 'r'  -- Filter only tables
	--AND t.relname NOT LIKE 'pg_%'
ORDER BY index_size desc 
    --t.relname, i.relname;

--Get Storage Quota per Table
--This query provides the size of each table, including indexes and total size:

SELECT 
    relname AS table_name,
    pg_size_pretty(pg_table_size(oid)) AS table_size,
    pg_size_pretty(pg_indexes_size(oid)) AS indexes_size,
    pg_size_pretty(pg_total_relation_size(oid)) AS total_size
FROM 
    pg_class
WHERE 
    relkind = 'r'  -- Filter only tables
	AND relname NOT LIKE 'pg_%'
ORDER BY 
    total_size DESC;

--Get analize and vacuum stats on tables

SELECT 
    schemaname,
    relname AS table_name,
    last_analyze, 
    last_autoanalyze, 
    last_vacuum, 
    last_autovacuum
FROM 
    pg_stat_all_tables
WHERE 
    schemaname NOT IN ('pg_catalog', 'information_schema') -- Exclude system schemas
	AND relname NOT LIKE 'pg_%'
ORDER BY 
    GREATEST(
        COALESCE(last_analyze, '1970-01-01'), 
        COALESCE(last_autoanalyze, '1970-01-01'), 
        COALESCE(last_vacuum, '1970-01-01'), 
        COALESCE(last_autovacuum, '1970-01-01')
    ) DESC;

--Analize & Vacuum specific table 
ANALYZE public.shipper;
VACUUM public.shipper;
VACUUM FULL public.shipper; --(full clean)

--Analize entire db
ANALYZE;



--========================================================================
--==================Create MRR Database on Postgres DB
--========================================================================

CREATE DATABASE "MRR"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

--========================================================================
--==================Create MRR Tables on Postgres DB
--========================================================================

-- Table: public.category

-- DROP TABLE IF EXISTS public.category;

CREATE TABLE IF NOT EXISTS public.category
(
    categoryid integer NOT NULL,
    categoryname character varying(15) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
	DWH_Created_Date timestamp,
	DWH_Updated_Date timestamp,
    CONSTRAINT category_pkey PRIMARY KEY (categoryid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.category
    OWNER to postgres;

--========================================================================
--==================Get fields data type per table
--========================================================================

SELECT 
    c.table_schema,
    c.table_name,
    c.column_name,
    c.data_type,
    CASE 
        WHEN pk.column_name IS NOT NULL THEN 'YES' 
        ELSE 'NO' 
    END AS is_primary_key,
    CASE 
        WHEN ix.column_name IS NOT NULL THEN 'YES' 
        ELSE 'NO' 
    END AS is_indexed
FROM information_schema.columns c
LEFT JOIN (
    -- Find primary keys
    SELECT 
        kcu.table_schema, 
        kcu.table_name, 
        kcu.column_name
    FROM information_schema.key_column_usage kcu
    JOIN information_schema.table_constraints tc 
        ON kcu.constraint_name = tc.constraint_name
    WHERE tc.constraint_type = 'PRIMARY KEY'
) pk ON c.table_schema = pk.table_schema 
    AND c.table_name = pk.table_name 
    AND c.column_name = pk.column_name
LEFT JOIN (
    -- Find indexed columns
    SELECT 
        i.schemaname AS table_schema,
        i.tablename AS table_name,
        a.attname AS column_name
    FROM pg_indexes i
    JOIN pg_class c ON i.tablename = c.relname
    JOIN pg_attribute a ON c.oid = a.attrelid
    JOIN pg_index ix ON c.oid = ix.indrelid AND a.attnum = ANY(ix.indkey)
) ix ON c.table_schema = ix.table_schema 
    AND c.table_name = ix.table_name 
    AND c.column_name = ix.column_name
WHERE c.table_schema = 'public' -- Adjust schema if needed
ORDER BY c.table_schema, c.table_name, c.ordinal_position;


