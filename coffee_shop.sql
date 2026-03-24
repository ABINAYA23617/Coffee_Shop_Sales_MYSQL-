SELECT * FROM coffee_shop_sales;
describe coffee_shop_sales;
SET SQL_SAFE_UPDATES = 0; 
UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');
ALTER TABLE coffee_shop_sales
MODIFY transaction_time TIME;
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');
ALTER TABLE coffee_shop_sales 
MODIFY transaction_date DATE;


SELECT ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 3 -- May Month 

SELECT ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 3;

WITH monthly_sales AS (
    SELECT  
        MONTH(transaction_date) AS month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (4,5)
    GROUP BY MONTH(transaction_date)
)

SELECT  
    month,
    ROUND(total_sales) AS total_sales,
    (total_sales - LAG(total_sales) OVER (ORDER BY month)) 
    / LAG(total_sales) OVER (ORDER BY month) * 100 AS mom_increase_percentage
FROM monthly_sales
ORDER BY month;

SELECT COUNT(transaction_id) as Total_Orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5; -- for month of(CM- MAY)

WITH monthly_orders AS(
	SELECT 
		MONTH(transaction_date) AS month,
        COUNT(transaction_id) AS Total_Orders
	FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (4,5)
    GROUP BY MONTH(transaction_date)
)

SELECT 
	month,
    Total_Orders,
    (Total_Orders - LAG(Total_Orders) OVER(ORDER BY month))
    / LAG(Total_Orders) OVER (ORDER BY MONTH) * 100 AS mom_increase_percentage
FROM monthly_orders
ORDER BY month;

SELECT SUM(transaction_qty) AS Total_Quantity_Sold
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5; -- for may month


WITH monthly_qty AS(
	SELECT 
		MONTH(transaction_date) AS month,
        SUM(transaction_qty) AS Total_Quantity_Sold
	FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (4,5)
    GROUP BY MONTH(transaction_date)
)

SELECT
	month,
    Total_Quantity_Sold,
    (Total_Quantity_Sold - LAG(Total_Quantity_Sold) OVER (ORDER BY MONTH))
    / LAG(Total_Quantity_Sold) OVER(ORDER BY month) * 100 AS mom_increase_percentage
FROM monthly_qty
ORDER BY month;



SELECT * FROM coffee_shop_sales;
SELECT 
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K')AS Total_Sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1), 'K') AS  Total_Qty_Sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS Total_Orders
FROM coffee_shop_sales
WHERE 
	transaction_date = '2023-05-18';

-- WEEKENDS -SAT AND SUN
-- WEEKDAYS - MON TO FRI


SELECT 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'	
    ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- MAY MONTH
GROUP BY 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'	
    END;
    
SELECT 
	store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS Total_Sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5 -- May Month'
    GROUP BY store_location;


SELECT ROUND(AVG(unit_price * transaction_qty),1) AS Avg_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;


SELECT
	CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS Avg_Sales
FROM
	(
    SELECT SUM(transaction_qty * unit_price) AS Total_Sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY transaction_date
    ) AS Internal_query;
    
SELECT 
	DAY(transaction_date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 
GROUP BY DAY(transaction_date);

SELECT 
	day_of_month,
    CASE 
		WHEN Total_Sales > Avg_Sales THEN 'Above Average'
        WHEN Total_Sales < Avg_Sales THEN 'Below Average'
        ELSE 'Equal to Average'
	END AS sales_status,
    total_sales
FROM (
	SELECT 
		DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
	FROM 
		coffee_shop_sales
	WHERE 
		MONTH(transaction_date) = 5
	GROUP BY 
		DAY(transaction_date)
) AS sales_data
ORDER BY 
	day_of_month;

SELECT 	
	product_category, 
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category 
ORDER BY SUM(unit_price * transaction_qty) DESC;

SELECT 	
	product_type,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category= 'Coffee'
GROUP BY product_type 
ORDER BY SUM(unit_price * transaction_qty) DESC;


SELECT 
	SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS Total_Qty_Sold,
	COUNT(*) AS Total_Orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May month
AND DAYOFWEEK(transaction_date) = 1 -- Monday
AND HOUR(transaction_time) = 14; -- Hour No. 14

SELECT 
	HOUR(transaction_time),
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);

SELECT
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'MONDAY'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'TUESDAY'
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'WEDNESDAY'
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'THURSDAY'
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'FRIDAY'
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'SATURDAY'
        ELSE 'SUNDAY'
	END AS Day_Of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
	coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 -- FILTER FOR MAY
GROUP BY 
	CASE 
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'MONDAY'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'TUESDAY'
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'WEDNESDAY'
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'THURSDAY'
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'FRIDAY'
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'SATURDAY'
        ELSE 'SUNDAY'
	END;
    
		
    