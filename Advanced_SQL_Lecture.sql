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
--===================Class Exercise=======================
--========================================================
--Exercise 1: Employee Order Insights
--Task: Find the top 5 employees with the highest number of processed orders. 
--Include their names, total orders processed, and indicate whether the count is "High" (above 50 orders) or "Moderate" (50 or fewer). Use COUNT, JOIN, and CASE.

--Solution:

SELECT 
    Employee.FirstName || ' ' || Employee.LastName AS EmployeeName,
    COUNT(salesOrder.OrderID) AS TotalOrdersProcessed,
    CASE 
        WHEN COUNT(salesOrder.OrderID) > 50 THEN 'High'
        ELSE 'Moderate'
    END AS OrderLevel
FROM Employee
JOIN salesOrder ON Employee.EmpID = salesOrder.EmpID
GROUP BY Employee.FirstName, Employee.LastName
ORDER BY TotalOrdersProcessed DESC
LIMIT 5;

--========================================================
--===================Break Rooms Exercise=================
--========================================================
--שלב 1
--מצאו את סך הכל כמות המוצרים לפי שם מוצר
--שדות : שם מוצר, סך הכל כמות שנמכרה
--מיון : שדה #2, סדר יורד
SELECT 
    Product.ProductName, 
    SUM(OrderDetail.qty) AS TotalQuantitySold
FROM OrderDetail
JOIN Product ON OrderDetail.ProductID = Product.ProductID
GROUP BY Product.ProductName
ORDER BY 2 DESC;

--שלב 2
--כעת נרצה למצוא את שם הספק שמוצריו נמכרים בכמויות הכי גבוהות
--שדות : שם ספק, סך הכל כמות שנמכרה
--מיון : שדה #2, סדר יורד
SELECT 
    Supplier.companyname, 
    SUM(OrderDetail.qty) AS TotalQuantitySold
FROM OrderDetail
JOIN Product ON OrderDetail.ProductID = Product.ProductID
JOIN Supplier ON Product.supplierid = Supplier.supplierid
GROUP BY Supplier.companyname
ORDER BY 2 DESC;

--שלב 3
--כעת נרצה להוסיף ממוצע מחיר יחידה לפי ספק, מעוגל ל 2 ספרות אחרי הנקודה העשרונית. נשאיר את שם הספק ואת מוצריו הנמכרים בכמויות הכי גבוהות
--שדות : שם ספק, סך הכל כמות שנמכרה, ממוצע מחיר יחידה
--מיון : שדות מספר 2 ו 3 בסדר יורד
SELECT 
    Supplier.companyname, 
    SUM(OrderDetail.qty) AS TotalQuantitySold,
	ROUND(AVG(Product.UnitPrice), 2) AS AverageSellingPrice
FROM OrderDetail
JOIN Product ON OrderDetail.ProductID = Product.ProductID
JOIN Supplier ON Product.supplierid = Supplier.supplierid
GROUP BY Supplier.companyname
ORDER BY 2 DESC,3 DESC;


--שלב 4
--כעת נוסיף סינון לכל השאילתא - נציג רק הזמנות שכמות היחידות שלהן גבוהה מ 3000 (לא כולל)
--השאירו את השאילתא כמות שהיא למעט התוספת המתבקשת
SELECT 
    Supplier.companyname, 
    SUM(OrderDetail.qty) AS TotalQuantitySold,
	ROUND(AVG(Product.UnitPrice), 2) AS AverageSellingPrice
FROM OrderDetail
JOIN Product ON OrderDetail.ProductID = Product.ProductID
JOIN Supplier ON Product.supplierid = Supplier.supplierid
GROUP BY Supplier.companyname
HAVING SUM(OrderDetail.qty) > 3000
ORDER BY 2 DESC,3 DESC;


