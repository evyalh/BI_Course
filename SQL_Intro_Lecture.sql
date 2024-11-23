--===================================
-- 1: Basic Arithmetic Operations  
--===================================

-- Addition (+):  
SELECT UnitPrice + qty AS TotalCost 
FROM Orderdetail;

-- Subtraction (-):  
SELECT UnitPrice - Discount AS NetQuantity 
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

-- Aggregate functions perform calculations across multiple rows:  
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
-- Example:  
SELECT DISTINCT Country 
FROM Customer;

-- Counting unique values:  
SELECT COUNT(DISTINCT Country) AS UniqueCountries 
FROM Customer;

--===================================
-- 4: Limiting Rows with LIMIT  
--===================================

-- LIMIT:  
SELECT * 
FROM Customer 
LIMIT 5;

-- OFFSET: Skips rows before returning data:  
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

-- ROUND: Rounds numeric values:  
SELECT ROUND(UnitPrice, 2) AS RoundedPrice 
FROM Product;

-- CEIL / FLOOR: Rounds up or down:  
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
-- 7: Combining Advanced Features  
--===================================

-- Complex queries combine functions and calculations:  
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

-- This query returns customers with total freight charges exceeding 1000, sorted by average freight in descending order, showing the top 5.  
--===================================
-- 8: Practical Applications  
--===================================

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
