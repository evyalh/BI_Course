--===================================
-- SQL Order example 
--===================================
SELECT country, count(*) employee_count -->6
FROM public.salesorder -->1
JOIN public.employee ON salesorder.empid = employee.empid -->2
WHERE lower(titleofcourtesy) like '%mr%' -->3
GROUP BY country -->4
HAVING COUNT(*)>160 -->5
ORDER BY employee_count DESC; -->7

--===================================
-- 1: Basic Arithmetic Operations  
--===================================

-- Addition (+): 
SELECT qty,
qty + 5 AS Increase_Qty 
FROM Orderdetail;

-- Subtraction (-): 
SELECT qty, 
qty - 5 AS Decrease_Qty 
FROM Orderdetail;

-- Multiplication (*): 
SELECT qty * UnitPrice AS TotalRevenue 
FROM Orderdetail;

-- Division (/):
SELECT Freight / 100 AS FreightInHundreds 
FROM salesorder;

-- Modulo (%): 
SELECT empid, OrderID, OrderID % 2 AS IsEven 
FROM salesorder;

--===================================
-- 2: Aggregate Functions  
--===================================

-- SUM: Calculates the total of a numeric column.  
SELECT SUM(qty) AS TotalQuantity 
FROM Orderdetail;

-- AVG: Calculates the average value.  
SELECT AVG(UnitPrice) AS AveragePrice 
FROM Product;

-- MAX: Finds the maximum value.  
SELECT MAX(Freight) AS MaxFreight 
FROM salesorder;

-- MIN: Finds the minimum value.  
SELECT MIN(UnitPrice) AS MinPrice 
FROM Product;

-- COUNT: Counts the number of rows or non-NULL values.  
SELECT COUNT(*) AS TotalOrders 
FROM salesorder;

--===================================
-- 3: Using DISTINCT  
--===================================

-- The DISTINCT keyword ensures unique values in results:  
SELECT DISTINCT Country 
FROM Customer;

-- Counting unique values:  
SELECT COUNT(DISTINCT Country) AS UniqueCountries 
FROM Customer;

--===================================
-- 4: Limiting Rows with LIMIT  
--===================================

-- LIMIT:  Retrieve the first 5 customers from the table.
SELECT * 
FROM Customer 
LIMIT 5;

-- OFFSET: Skip the first 10 rows and retrieve the next 5.
SELECT * 
FROM salesorder 
LIMIT 5 OFFSET 10;

--===================================
-- 5: Retrieving Top N Rows  
--===================================

-- To fetch top N rows based on criteria:  
-- Sorting and limiting:  
SELECT ProductName, SUM(qty) AS TotalSold 
FROM Orderdetail 
join product
on Orderdetail.productid = product.productid
GROUP BY ProductName 
ORDER BY TotalSold DESC 
LIMIT 3;

--===================================
-- 6: Advanced Mathematical Functions
--===================================

-- ROUND: Rounds numeric values to two decimal places.
SELECT ROUND(UnitPrice, 2) AS RoundedPrice 
FROM Product;

-- CEIL / FLOOR: Round up or down to the nearest whole number.
SELECT 
UnitPrice,
CEIL(UnitPrice) AS RoundedUp, 
FLOOR(UnitPrice) AS RoundedDown 
FROM Product;

-- ABS: Returns the absolute value: 
select orderid, freight, freight *-1
FROM salesOrder 
where orderid in (10248,10249,10250)

begin transaction 

UPDATE salesOrder
set freight = freight *-1
where orderid in (10248,10249,10250)

commit

SELECT ABS(Freight) AS Freight_ABS 
FROM salesOrder
where orderid in (10248,10249,10250);


--===================================
-- 7: Data Types in SQL
--===================================

-- Examples of common data types:
-- Numeric Types: INTEGER, DECIMAL, FLOAT
-- Text Types: VARCHAR, TEXT
-- Date and Time Types: DATE, TIMESTAMP

-- Querying column data types:
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'employee';

--===================================
-- 8: Casting  
--===================================

select 
custid,
cast(custid as integer),
freight,
cast(freight as integer)
FROM salesorder

--===================================
-- 9: Dates  
--===================================

-- CURRENT_DATE():
SELECT CURRENT_DATE

-- EXTRACT:
SELECT OrderDate
,EXTRACT(YEAR FROM OrderDate) AS Year
,EXTRACT(QUARTER FROM OrderDate) AS QUARTER
,EXTRACT(MONTH FROM OrderDate) AS MONTH
,EXTRACT(WEEK FROM OrderDate) AS WEEK
,EXTRACT(DAY FROM OrderDate) AS DAY
FROM salesOrder 
limit 10;

-- DATEDIFF:
SELECT requireddate - shippeddate AS date_diff
FROM salesOrder;

SELECT AGE(requireddate, shippeddate) AS date_diff
FROM salesOrder;

--===================================
-- 10: Aliases  
--===================================

-- Aliases make column and table names more readable.

-- Example: Rename columns for better clarity.
SELECT ProductName AS Product, UnitPrice AS Price 
FROM Product;

--===================================
-- 11: Pattern Matching  
--===================================

-- Use LIKE with % and _ for pattern-based filtering.

-- Find customers whose names contain "Shop".
SELECT contactname 
FROM Customer 
WHERE contactname LIKE '%Ja%';

--===================================
-- 12: Conditional Logic with CASE  
--===================================

-- Use CASE for conditional expressions in queries.

-- Categorize products as "Expensive" or "Affordable".
SELECT ProductName,
       CASE 
           WHEN UnitPrice > 50 THEN 'Expensive'
           ELSE 'Affordable'
       END AS PriceCategory
FROM Product;

--===================================
-- 13: Subqueries  
--===================================

-- Subqueries are nested queries that provide data for the main query.

-- Find products in the "Beverages" category.

select PriceCategory
,count(distinct ProductName)
from
(SELECT ProductName,
       CASE 
           WHEN UnitPrice > 50 THEN 'Expensive'
           ELSE 'Affordable'
       END AS PriceCategory
FROM Product)
group by PriceCategory;

SELECT ProductName 
FROM Product 
WHERE CategoryID = (SELECT CategoryID FROM Category WHERE CategoryName = 'Beverages');

--===================================
-- 14: Self Joins  
--===================================

-- Self joins compare rows within the same table.

-- Example: Match managers with their employees.
SELECT A.EmpID AS Manager, B.EmpID AS Employee 
FROM Employee A 
JOIN Employee B ON A.EmpID = B.ReportsTo;

--===================================
-- 15: Transactions  
--===================================

-- Transactions ensure data consistency during operations.

-- Example: Adjust prices with rollback capability.

select unitprice, UnitPrice * 1.1 as increase ,CategoryID
from Product
WHERE CategoryID = 1;


BEGIN;
UPDATE Products SET UnitPrice = UnitPrice * 1.1 WHERE CategoryID = 1;
ROLLBACK;

--===================================
-- 16: Views  
--===================================

-- A view is a virtual table created from a query.

-- Example: Create a view of top customers by total orders.
CREATE or replace VIEW Top10Customers AS 
SELECT CustID, COUNT(OrderID) AS TotalOrders 
FROM salesOrder 
GROUP BY CustID 
ORDER BY TotalOrders DESC
limit 10;

-- Retrieve data from the view:
SELECT * FROM Top10Customers;

--===================================
-- 17: Common Table Expressions (CTEs)
--===================================

-- CTEs simplify complex queries and improve readability.

-- Example: Summarize freight totals by customer.
WITH OrderSummary AS (
    SELECT CustID, SUM(Freight) AS TotalFreight 
    FROM salesOrder 
    GROUP BY CustID
)
SELECT CustID, TotalFreight 
FROM OrderSummary 
WHERE TotalFreight > 100;


--===================================
-- 18: Combining SQL Features  
--===================================

-- This query returns customers with total freight charges exceeding 1000, sorted by average freight in descending order, showing the top 5.  
SELECT CustID,
	   COUNT(orderid) AS Order_Count,
       SUM(Freight) AS TotalFreight, 
       AVG(Freight) AS AverageFreight, 
       MAX(Freight) AS MaxFreight,
	   MIN(Freight) AS MinFreight
FROM salesOrder
GROUP BY CustID
HAVING SUM(Freight) > 1000
ORDER BY AverageFreight DESC
LIMIT 5;

-- Sales Analysis by Category:  
SELECT CategoryName, SUM(Qty) AS TotalSold 
FROM Product 
JOIN Category ON Product.CategoryID = Category.CategoryID
JOIN OrderDetail ON Product.ProductID = OrderDetail.ProductID
GROUP BY CategoryName
ORDER BY TotalSold DESC
LIMIT 10;

-- Top Customers by Revenue:  
SELECT CustID, SUM(UnitPrice * Qty) AS TotalRevenue 
FROM OrderDetail
JOIN salesOrder ON OrderDetail.OrderID = salesOrder.OrderID
GROUP BY CustID
ORDER BY TotalRevenue DESC
LIMIT 5;

