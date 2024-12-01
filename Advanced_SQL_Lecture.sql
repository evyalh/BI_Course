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




