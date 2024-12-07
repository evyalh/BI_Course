--תרגיל 1
--מהו סדר הפעולות של מנוע SQL סטנדרטי?
FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY --(answer #2)

--תרגיל 2
--צורך עסקי – המנכל מעוניין בהגברה וחיזוק הקשרים העסקיים עם הספקים
--מצאו את כמות הספקים לפי מדינה, בסדר יורד.
SELECT
	COUNTRY,
	COUNT(*) SUPPLIERS_COUNT
FROM
	PUBLIC.SUPPLIER
GROUP BY
	1
ORDER BY
	2 DESC

--תרגיל 3 
--צורך עסקי – המנכל ביקש למנף את המכירות של עשרת המוצרים היקרים בחברה 
--מצאו את 10 המוצרים היקרים של החברה ולהציג את שמם ומחירם המעוגל לספרה אחת אחרי הנקודה העשרונית.
SELECT
	PRODUCTNAME,
	ROUND(UNITPRICE, 1) AS ROUNDEDPRICE
FROM
	PRODUCT
ORDER BY
	2 DESC
LIMIT
	10;


--תרגיל 4
--צורך עסקי – משאבי אנוש מעוניינים להתחיל תכנית הדרכה לעובדים החדשים בחברה
--מצאו את 5 העובדים החדשים בחברה והציגו את שמם המלא, כמה ימים וחודשים (מספר עשרוני) הם בחברה ביחס לזמן ריצת השאילתה.

SELECT
	LASTNAME,
	FIRSTNAME,
	CURRENT_DATE - HIREDATE AS HIRING_PERIOD_IN_DAYS,
	(
		EXTRACT(
			YEAR
			FROM
				AGE (CURRENT_DATE, HIREDATE)
		) * 12
	) + EXTRACT(
		MONTH
		FROM
			AGE (CURRENT_DATE, HIREDATE)
	) AS HIRING_PERIOD_IN_MONTHS
FROM
	PUBLIC.EMPLOYEE
ORDER BY
	HIREDATE ASC
LIMIT
	5;
