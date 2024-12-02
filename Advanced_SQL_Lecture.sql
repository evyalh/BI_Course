--========================================================
--=======================INNER JOIN=======================
--========================================================
SELECT 
    OrderDetail.OrderID, 
    Product.ProductName, 
    OrderDetail.Qty
FROM OrderDetail
INNER JOIN Product 
ON OrderDetail.ProductID = Product.ProductID
order by orderid;

select productid 
from OrderDetail
where orderid = 10248

select * 
from product
where productid in (11,42,72)

--========================================================
--=======================LEFT JOIN========================
--========================================================

SELECT 
    Customer.CustID, 
    Customer.CompanyName, 
    SalesOrder.OrderID
FROM Customer
LEFT JOIN SalesOrder 
ON Customer.CustID = cast(SalesOrder.CustID as integer);
where SalesOrder.OrderID is null;

--========================================================
--=======================RIGHT JOIN=======================
--========================================================

SELECT 
    SalesOrder.OrderID, 
    SalesOrder.OrderDate, 
    Customer.CompanyName
FROM SalesOrder
RIGHT JOIN Customer 
ON cast(SalesOrder.CustID as integer) = Customer.CustID;
where SalesOrder.OrderID is null;

--========================================================
--====================FULL OUTER JOIN=====================
--========================================================
SELECT 
    Supplier.CompanyName AS SupplierName, 
    Product.ProductName
FROM Supplier
FULL OUTER JOIN Product 
ON Supplier.SupplierID = Product.SupplierID;

--========================================================
--====================Join Order Example==================
--========================================================
--שלב 1
SELECT table_name,column_name, data_type 
FROM information_schema.columns 
WHERE column_name like '%region%';


select distinct region from customer --CHAR
union 
select distinct region from employee --CHAR
union
select distinct region from supplier --CHAR
union
select distinct region from customer_managers --CHAR
union
select distinct shipregion from salesorder --CHAR
--select distinct regionid from region --int
--select distinct regionid from territory --int
order by 1


-- Step 1: Create the region_state table
CREATE TABLE public.regionstate (
    id SERIAL PRIMARY KEY,                -- Running number
    region_state VARCHAR(255) NOT NULL,   -- Region or state code/name
    region_state_description VARCHAR(255)         -- Description of the region/state
);

-- Step 2: Insert values into the region_state table
INSERT INTO public.regionstate (region_state, region_state_description)
VALUES
    ('region', 'General region'),
    ('AK', 'Alaska, USA'),
    ('Asturias', 'Asturias, Spain'),
    ('BC', 'British Columbia, Canada'),
    ('CA', 'California, USA'),
    ('Co. Cork', 'County Cork, Ireland'),
    ('DF', 'Federal District, Mexico'),
    ('Essex', 'Essex, England'),
    ('ID', 'Idaho, USA'),
    ('Isle of Wight', 'Isle of Wight, England'),
    ('LA', 'Louisiana, USA'),
    ('Lara', 'Lara, Venezuela'),
    ('MA', 'Massachusetts, USA'),
    ('MI', 'Michigan, USA'),
    ('MT', 'Montana, USA'),
    ('NM', 'New Mexico, USA'),
    ('NSW', 'New South Wales, Australia'),
    ('Nueva Esparta', 'Nueva Esparta, Venezuela'),
    ('OR', 'Oregon, USA'),
    ('Québec', 'Québec, Canada'),
    ('RJ', 'Rio de Janeiro, Brazil'),
    ('SP', 'São Paulo, Brazil'),
    ('Táchira', 'Táchira, Venezuela'),
    ('Victoria', 'Victoria, Australia'),
    ('WA', 'Washington, USA'),
    ('WY', 'Wyoming, USA');



select * from public.regionstate

select count(*) 
from employee
left join public.regionstate
on employee.region = regionstate.region_state


select count(*) 
from public.regionstate
left join employee
on employee.region = regionstate.region_state

--========================================================
--====================Join – Star Schema==================
--========================================================
SELECT 
    Product.ProductName, 
    SUM(OrderDetail.qty * Product.UnitPrice) AS TotalRevenue
FROM OrderDetail
JOIN Product ON OrderDetail.ProductID = Product.ProductID
GROUP BY Product.ProductName


--========================================================
--====================Join – Snowflake====================
--========================================================
SELECT 
    Category.CategoryName, 
    SUM(OrderDetail.qty * Product.UnitPrice) AS TotalRevenue, 
    AVG(Product.UnitPrice) AS AveragePrice
FROM OrderDetail
JOIN Product ON OrderDetail.ProductID = Product.ProductID
JOIN Category ON Product.CategoryID = Category.CategoryID
GROUP BY Category.CategoryName


--========================================================
--====================Use Case============================
--========================================================
SELECT table_name,column_name, data_type 
FROM information_schema.columns 
WHERE column_name like '%territory%';

select * from public.employee
select * from public.employeeterritory
select * from public.territory

select count(*) from employee
--9
join public.employeeterritory
on employee.empid = employeeterritory.employeeid
--49
join public.territory
on employeeterritory.territoryid = territory.territoryid
--49

