--========================================================
--=========================תרגיל 1========================
--========================================================

--ממוצע 7 שילוחים הכי כבדים לפי מדינה
SELECT shipcountry, ROUND(AVG(freight),2) AVG_FREIGHT
FROM public.salesorder
GROUP BY 	1
ORDER BY 	2 DESC
LIMIT 7;

--184.79

--הוכחה לפי המדינה הכי גבוהה
--נוציא את הערכים לאקסל ונבדוק ממוצע
select freight
FROM public.salesorder
where shipcountry = 'Austria'

--184.788
--העלאת רמת הדיוק
SELECT shipcountry, ROUND(AVG(freight),3) AVG_FREIGHT
FROM public.salesorder
GROUP BY 	1
ORDER BY 	2 DESC
LIMIT 7;

--========================================================
--=========================תרגיל 2========================
--========================================================

--חשבו את מספר השנים שחלפו בין תאריך ההזמנה לבין התאריך ריצת שאילתה, עבור הזמנות שמספרן נע בין 10397 ל-10402
SELECT  orderid,
EXTRACT(YEAR FROM CURRENT_DATE)- EXTRACT(YEAR FROM OrderDate) AS Year
FROM salesOrder
WHERE orderid BETWEEN 10397 AND 10402

--========================================================
--=========================תרגיל 3========================
--========================================================
--הצגת כמות הזמנות לפי שנה ורבעון בסדר יורד
select extract(year from OrderDate) as year
,extract(quarter from orderdate) as quarter
,count(orderid)
FROM public.salesorder
group by 1,2
order by 3 desc



--========================================================
--=========================תרגיל 4========================
--========================================================
--הזמנות שזמן הוצאת המשלוח שלהן עבר  7 ימים
--שאלה - האם אלה ימי עסקים או ימים קלנדריים?
--דוגמא - חשיבות סדר הפעולות ב sql
select orderid,
 AGE(shippeddate,orderdate) order_to_ship_time
FROM public.salesorder
where order_to_ship_time > 7
order by 2 desc

--דוגמא - הבנת הפורמט עמו אנחנו עובדים והתאמה אליו
select orderid,
 AGE(shippeddate,orderdate) order_to_ship_time
FROM public.salesorder
where AGE(shippeddate,orderdate) > 7
order by 2 desc

--תשובה סופית
select orderid,
 AGE(shippeddate,orderdate) order_to_ship_time
FROM public.salesorder
where AGE(shippeddate,orderdate) > '7 days'
order by 2 desc

--העמקה - נרצה לראות את זמני השילוח של כל ההזמנות
-- דוגמא - התמודדות עם ערכי null
select orderid,
 AGE(shippeddate,orderdate) order_to_ship_time
FROM public.salesorder
--where AGE(shippeddate,orderdate) > '7 days'
order by 2 desc

--תחקור מקור ה nulls שלנו
select orderid,
shippeddate,
orderdate,
 AGE(shippeddate,orderdate) order_to_ship_time
FROM public.salesorder
--where AGE(shippeddate,orderdate) > '7 days'
order by 2 desc

--התמודדות עם ערכי null
select orderid,
shippeddate,
orderdate,
 AGE(shippeddate,orderdate) order_to_ship_time
FROM public.salesorder
where shippeddate is not null
--where AGE(shippeddate,orderdate) > '7 days'
order by 2 desc
