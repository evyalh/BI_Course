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
--=======================Create Fact_Orders===============
--========================================================

CREATE TABLE dwh.Fact_Orders (
    ID SERIAL PRIMARY KEY, -- Generated Key (ID+1)
    Order_ID INTEGER NOT NULL, -- Sales Order ID
    Customer_ID INTEGER NOT NULL, -- Foreign Key: Customer ID
    Employee_ID INTEGER NOT NULL, -- Foreign Key: Employee ID
    OrderDate DATE, -- Order Date
    Arrive_Date DATE, -- Required Arrival Date
    Planned_Shipping_Days INTEGER, -- Planned Shipping Days
    Actual_Shipping_Days INTEGER, -- Actual Shipping Days
    Shipping_Date DATE, -- Shipping Date
    Shipper_ID INTEGER, -- Foreign Key: Shipper ID
    Weight FLOAT, -- Freight Weight
    Shipment_Destination_City CHARACTER VARYING(255), -- Shipment Destination City
    Shipment_Destination_Country CHARACTER VARYING(255), -- Shipment Destination Country
    Total_Revenue FLOAT, -- Total Revenue
    DWH_Created_Date TIMESTAMP DEFAULT NOW(), -- Operational Field: Created Date
    DWH_Updated_Date TIMESTAMP DEFAULT NOW() -- Operational Field: Updated Date
);

INSERT INTO dwh.Fact_Orders (
    Order_ID,
    Customer_ID,
    Employee_ID,
    OrderDate,
    Arrive_Date,
    Planned_Shipping_Days,
    Actual_Shipping_Days,
    Shipping_Date,
    Shipper_ID,
    Weight,
    Shipment_Destination_City,
    Shipment_Destination_Country,
    Total_Revenue,
    DWH_Created_Date,
    DWH_Updated_Date
)
SELECT
    orderid AS Order_ID,
    cast(custid as integer) AS Customer_ID,
    empid AS Employee_ID,
    orderdate::DATE AS OrderDate,
    requireddate::DATE AS Arrive_Date,
    (requireddate::DATE - orderdate::DATE) AS Planned_Shipping_Days,
    (CURRENT_DATE - orderdate::DATE) AS Actual_Shipping_Days,
    shippeddate::DATE AS Shipping_Date,
    shipperid AS Shipper_ID,
    freight AS Weight,
    shipcity AS Shipment_Destination_City,
    shipcountry AS Shipment_Destination_Country,
    SUM(Fact_Order_Details.Total_Revenue) AS Total_Revenue, -- Assuming a join with Fact_Order_Details
    NOW() AS DWH_Created_Date, -- Operational Field: Created Date
    NOW() AS DWH_Updated_Date -- Operational Field: Updated Date
FROM public.salesorder
-- Assuming a join with Fact_Order_Details here
JOIN dwh.Fact_Order_Details ON salesorder.orderid = Fact_Order_Details.Order_ID
GROUP BY orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipcity, shipcountry;


--========================================================
--=======================Create Dim_Employees===============
--========================================================

CREATE TABLE dwh.Dim_Employees (
    ID SERIAL PRIMARY KEY, -- Generated Key (ID+1)
    Employee_ID INTEGER NOT NULL, -- PK: Employee ID
    Employee_Last_Name CHARACTER VARYING(255), -- Last Name
    Employee_First_Name CHARACTER VARYING(255), -- First Name
    Employee_Full_Name CHARACTER VARYING(255), -- Concatenated Last Name + First Name
    Employee_Title CHARACTER VARYING(255), -- Title
    Gender CHARACTER VARYING(255), -- Gender based on Courtesy Title
    Birth_Date DATE, -- Converted Birthdate
    Employment_Start_Date DATE, -- Converted Hiredate
    Employee_Address CHARACTER VARYING(255), -- Address
    Employee_City CHARACTER VARYING(255), -- City
    Employee_Postal_Code CHARACTER VARYING(255), -- Postal Code
    Employee_Country CHARACTER VARYING(255), -- Country
    Employee_Full_Address CHARACTER VARYING(255), -- Full Address (Concatenation)
    Employee_Phone_Number CHARACTER VARYING(255), -- Phone Number
    Employee_Phone_Type CHARACTER VARYING(255), -- Phone Type (Mobile or Landline)
    DWH_Created_Date TIMESTAMP DEFAULT NOW(), -- Operational Field: Created Date
    DWH_Updated_Date TIMESTAMP DEFAULT NOW() -- Operational Field: Updated Date
);


INSERT INTO dwh.Dim_Employees (
    Employee_ID,
    Employee_Last_Name,
    Employee_First_Name,
    Employee_Full_Name,
    Employee_Title,
    Gender,
    Birth_Date,
    Employment_Start_Date,
    Employee_Address,
    Employee_City,
    Employee_Postal_Code,
    Employee_Country,
    Employee_Full_Address,
    Employee_Phone_Number,
    Employee_Phone_Type,
    DWH_Created_Date,
    DWH_Updated_Date
)
SELECT
    empid AS Employee_ID,
    lastname AS Employee_Last_Name,
    firstname AS Employee_First_Name,
    lastname || ' ' || firstname AS Employee_Full_Name, -- Concatenate Last Name + First Name
    title AS Employee_Title,
    CASE 
        WHEN titleofcourtesy IN ('Ms.', 'Mrs.') THEN 'Female'
        WHEN titleofcourtesy = 'Mr.' THEN 'Male'
        ELSE 'NA'
    END AS Gender, -- Gender based on Courtesy Title
    CAST(birthdate AS DATE) AS Birth_Date, -- Convert Birthdate to DATE
    CAST(hiredate AS DATE) AS Employment_Start_Date, -- Convert Hiredate to DATE
    address AS Employee_Address,
    city AS Employee_City,
    postalcode AS Employee_Postal_Code,
    country AS Employee_Country,
    address || ', ' || city || ' - ' || postalcode || '; ' || country AS Employee_Full_Address, -- Concatenated Full Address
    phone AS Employee_Phone_Number,
    CASE
        WHEN LENGTH(phone) > 13 THEN 'Mobile'
        ELSE 'Land Line'
    END AS Employee_Phone_Type, -- Phone Type based on Length
    NOW() AS DWH_Created_Date, -- Operational Field: Created Date
    NOW() AS DWH_Updated_Date -- Operational Field: Updated Date
FROM public.employee;


--========================================================
--=======================Create Dim_Customers===============
--========================================================

CREATE TABLE dwh.Dim_Customers (
    ID SERIAL PRIMARY KEY, -- Generated Key (ID+1)
    Customer_ID INTEGER NOT NULL, -- PK: Customer ID
    Company_Name CHARACTER VARYING(255), -- Company Name
    Contact_Person CHARACTER VARYING(255), -- Contact Name
    Contact_Person_Position CHARACTER VARYING(255), -- Contact Title
    Position_Type CHARACTER VARYING(255), -- Position Type
    Is_Manager CHARACTER VARYING(255), -- Manager or Employee
    Company_Address CHARACTER VARYING(255), -- Address
    Company_City CHARACTER VARYING(255), -- City
    Company_Postal_Code CHARACTER VARYING(255), -- Postal Code
    Company_Country CHARACTER VARYING(255), -- Country
    Company_Full_Address CHARACTER VARYING(255), -- Full Address (Concatenation)
    Company_Phone_Number CHARACTER VARYING(255), -- Phone Number
    Company_Phone_Type CHARACTER VARYING(255), -- Phone Type (Mobile or Landline)
    Company_Fax_Number CHARACTER VARYING(255), -- Fax Number
    DWH_Created_Date TIMESTAMP DEFAULT NOW(), -- Operational Field: Created Date
    DWH_Updated_Date TIMESTAMP DEFAULT NOW() -- Operational Field: Updated Date
);

INSERT INTO dwh.Dim_Customers (
    Customer_ID,
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
    custid AS Customer_ID,
    companyname AS Company_Name,
    contactname AS Contact_Person,
    contacttitle AS Contact_Person_Position,
    CASE 
        WHEN LOWER(contacttitle) LIKE '%sales%' THEN 'Sales'
        WHEN LOWER(contacttitle) LIKE '%marketing%' THEN 'Marketing'
        WHEN LOWER(contacttitle) LIKE '%accounting%' THEN 'Accounting'
        ELSE 'NA'
    END AS Position_Type, -- Position Type based on Contact Title
    CASE
        WHEN LOWER(contacttitle) LIKE '%manager%' OR LOWER(contacttitle) LIKE '%owner%' THEN 'Manager'
        ELSE 'Employee'
    END AS Is_Manager, -- Is Manager based on Contact Title
    address AS Company_Address,
    city AS Company_City,
    postalcode AS Company_Postal_Code,
    country AS Company_Country,
    address || ', ' || city || ' - ' || postalcode || '; ' || country AS Company_Full_Address, -- Full Address Concatenation
    phone AS Company_Phone_Number,
    CASE
        WHEN LENGTH(phone) > 13 THEN 'Mobile'
        ELSE 'Land Line'
    END AS Company_Phone_Type, -- Phone Type based on Length
    fax AS Company_Fax_Number,
    NOW() AS DWH_Created_Date, -- Operational Field: Created Date
    NOW() AS DWH_Updated_Date -- Operational Field: Updated Date
FROM public.customer;


--========================================================
--=======================Create Dim_Categories===============
--========================================================

CREATE TABLE dwh.Dim_Categories (
    ID SERIAL PRIMARY KEY, -- Generated Key (ID+1)
    Category_ID INTEGER NOT NULL, -- PK: Category ID
    Category_Name CHARACTER VARYING(255), -- Category Name
    Category_Description CHARACTER VARYING(255), -- Category Description
    DWH_Created_Date TIMESTAMP DEFAULT NOW(), -- Operational Field: Created Date
    DWH_Updated_Date TIMESTAMP DEFAULT NOW() -- Operational Field: Updated Date
);

INSERT INTO dwh.Dim_Categories (
    Category_ID,
    Category_Name,
    Category_Description,
    DWH_Created_Date,
    DWH_Updated_Date
)
SELECT
    categoryid AS Category_ID,
    categoryname AS Category_Name,
    description AS Category_Description,
    NOW() AS DWH_Created_Date, -- Operational Field: Created Date
    NOW() AS DWH_Updated_Date -- Operational Field: Updated Date
FROM public.category;
