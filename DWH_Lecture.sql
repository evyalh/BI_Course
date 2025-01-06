--========================================================
--=======================Create dwh schema================
--========================================================

-- SCHEMA: dwh

-- DROP SCHEMA IF EXISTS dwh ;

CREATE SCHEMA IF NOT EXISTS dwh
    AUTHORIZATION pg_database_owner;

COMMENT ON SCHEMA dwh
    IS 'standard dwh schema';

GRANT USAGE ON SCHEMA dwh TO PUBLIC;

GRANT ALL ON SCHEMA dwh TO pg_database_owner;

--========================================================
--=======================Create Dim_Products==============
--========================================================

--DDL
CREATE TABLE dwh.Dim_Products (
    ID SERIAL ,                     -- Auto-incrementing unique key
    Product_ID INTEGER NOT NULL PRIMARY KEY,               -- Product ID from the source data
    Product_Name CHARACTER VARYING(255),        -- Product Name
    Supplier_ID INTEGER,                       -- Supplier ID
    Category_ID INTEGER,                       -- Category ID
    Unit_Price FLOAT,                          -- Unit Price
    Is_Cancelled BOOLEAN,                      -- Discontinued status
    DWH_Created_Date TIMESTAMP DEFAULT NOW(),  -- Record creation timestamp
    DWH_Updated_Date TIMESTAMP DEFAULT NOW()   -- Record update timestamp
);


--DML
INSERT INTO dwh.Dim_Products (
    Product_ID, 
    Product_Name, 
    Supplier_ID, 
    Category_ID, 
    Unit_Price, 
    Is_Cancelled
)
SELECT
    CAST(productid AS INTEGER) AS Product_ID,
    CAST(productname AS CHARACTER VARYING(20)) AS Product_Name,
    CAST(supplierid AS INTEGER) AS Supplier_ID,
    CAST(categoryid AS INTEGER) AS Category_ID,
    CAST(unitprice AS FLOAT) AS Unit_Price,
    CAST(discontinued AS BOOLEAN) AS Is_Cancelled
FROM public.product;

select * from dwh.Dim_Products;

--========================================================
--=======================Create Dim_Suppliers=============
--========================================================

--DDL
CREATE TABLE dwh.Dim_Suppliers (
    ID SERIAL,
    Supplier_ID INTEGER NOT NULL PRIMARY KEY,
    Company_Name CHARACTER VARYING(255),
    Contact_Person CHARACTER VARYING(255),
    Contact_Person_Position CHARACTER VARYING(255),
    Position_Type CHARACTER VARYING(255),
    Is_Manager CHARACTER VARYING(255),
    Company_Address CHARACTER VARYING(255),
    Company_City CHARACTER VARYING(255),
    Company_Postal_Code CHARACTER VARYING(255),
    Company_Country CHARACTER VARYING(255),
    Company_Full_Address CHARACTER VARYING(255),
    Company_Phone_Number CHARACTER VARYING(255),
    Company_Phone_Type CHARACTER VARYING(255),
    Company_Fax_Number CHARACTER VARYING(255),
    DWH_Created_Date TIMESTAMP DEFAULT NOW(),
    DWH_Updated_Date TIMESTAMP DEFAULT NOW()
);

--DML
INSERT INTO dwh.Dim_Suppliers (
    Supplier_ID,
    Company_Name,
    Contact_Person,
    Contact_Person_Position,
    Position_Type,
    Is_Manager,
    Company_Address,
    Company_City,
    Company_Postal_Code,
    Company_Country,
    Company_Full_Address,
    Company_Phone_Number,
    Company_Phone_Type,
    Company_Fax_Number,
    DWH_Created_Date,
    DWH_Updated_Date
)
SELECT
    supplierid AS Supplier_ID,
    companyname AS Company_Name,
    contactname AS Contact_Person,
    contacttitle AS Contact_Person_Position,
    CASE 
        WHEN LOWER(contacttitle) LIKE '%sales%' THEN 'Sales'
        WHEN LOWER(contacttitle) LIKE '%marketing%' THEN 'Marketing'
        WHEN LOWER(contacttitle) LIKE '%accounting%' THEN 'Accounting'
        WHEN LOWER(contacttitle) LIKE '%product%' THEN 'Product'
        WHEN LOWER(contacttitle) LIKE '%purchas%' OR LOWER(contacttitle) LIKE '%order%' THEN 'Procurement'
        WHEN LOWER(contacttitle) LIKE '%foreign%' OR LOWER(contacttitle) LIKE '%export%' THEN 'Export'
        ELSE 'TBD'
    END AS Position_Type,
    CASE 
        WHEN LOWER(contacttitle) LIKE '%manager%' OR LOWER(contacttitle) LIKE '%owner%' THEN 'Manager'
        ELSE 'Employee'
    END AS Is_Manager,
    address AS Company_Address,
    city AS Company_City,
    postalcode AS Company_Postal_Code,
    country AS Company_Country,
    CONCAT(address, ', ', city, ' - ', postalcode, '; ', country) AS Company_Full_Address,
    phone AS Company_Phone_Number,
    CASE 
        WHEN LENGTH(phone) > 13 THEN 'Mobile'
        ELSE 'Land Line'
    END AS Company_Phone_Type,
    fax AS Company_Fax_Number,
    NOW() AS DWH_Created_Date,
    NOW() AS DWH_Updated_Date
FROM public.supplier;



--========================================================
--=======================Create Fact_Order_Details========
--========================================================

--DDL
CREATE TABLE dwh.Fact_Order_Details (
    ID SERIAL , -- Generated Key (ID+1)
    Order_ID INTEGER NOT NULL, -- PK: Order ID
    Product_ID INTEGER NOT NULL, -- PK: Product ID
    Unit_Price FLOAT, -- Unit Price
    Quantity INTEGER, -- Quantity
    Discount FLOAT, -- Discount Percentage
    Total_Revenue FLOAT, -- Total Revenue (Quantity * Unit Price)
    Total_Discount FLOAT, -- Total Discount (Quantity * Unit Price * Discount)
    Net_Income FLOAT, -- Net Income (Total Revenue - Total Discount)
    DWH_Created_Date TIMESTAMP DEFAULT NOW(), -- Operational Field: Created Date
    DWH_Updated_Date TIMESTAMP DEFAULT NOW(), -- Operational Field: Updated Date
    PRIMARY KEY (Order_ID, Product_ID) -- Composite Primary Key
);

--DML
INSERT INTO dwh.Fact_Order_Details (
    Order_ID,
    Product_ID,
    Unit_Price,
    Quantity,
    Discount,
    Total_Revenue,
    Total_Discount,
    Net_Income
)
SELECT
    orderid AS Order_ID,
    productid AS Product_ID,
    unitprice AS Unit_Price,
    qty AS Quantity,
    discount AS Discount,
    qty * unitprice AS Total_Revenue,
    qty * unitprice * discount AS Total_Discount,
    (qty * unitprice) - (qty * unitprice * discount) AS Net_Income
FROM public.orderdetail;

--========================================================
--=======================Final DWH Joins==================
--========================================================

--DWH Solution
select * 
from dwh.fact_order_details
left join dwh.dim_products
on fact_order_details.Product_ID = dim_products.Product_ID
left join dwh.dim_suppliers
on dim_products.Supplier_ID = dim_suppliers.Supplier_ID

--Source Solution
select * 
from public.orderdetail
left join public.product
on orderdetail.productid = product.productid
left join public.supplier
on product.supplierid = supplier.supplierid
