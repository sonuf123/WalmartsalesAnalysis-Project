-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATE NOT NULL,  -- Changed DATETIME to DATE
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,  -- Removed precision specifier
    gross_income DECIMAL(12, 4),
    rating FLOAT(2)  -- Removed precision specifier
);

step 2: IMPORT/EXPORT
IMPORT THE .CSV FILE

-- Data cleaning
SELECT
	*
FROM sales;

--------FEATURE ENGINEERING 


-- Add the time_of_day column

SELECT
	time,
	(CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_day
FROM sales;

ALTER table sales ADD column time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
);

--Add a new column named day_name that contains the extracted days of the week 


SELECT
    date,
    TO_CHAR(date, 'Day') AS day_name
FROM 
    sales;


ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = TO_CHAR(date, 'Day')


-----Add a new column named month_name that contains the extracted months of the year

SELECT
    date,
    TO_CHAR(date, 'Mon') AS month_name
FROM 
    sales;


ALTER table sales ADD column month_name VARCHAR(10);
Update sales
SET month_name = TO_CHAR(date, 'Mon')


--1. How many unique cities does the data have?


select DISTINCT(city) from sales
--------------------------------------------------

--2. What is the most selling product line

select 
SUM(quantity)as qty,
product_line
from sales
GROUP BY product_line,quantity 
ORDER BY quantity DESC

---------------------------------------------------------
-- What is the total revenue by month

Select SUM(total) as Total_Revenue ,
month_name as Month
from SALES
group by total,month_name
Order by total_revenue desc;

--------------------------------------------
-- What month had the largest COGS?

select 
MAX (cogs) as cogs,
month_name 
from sales 
group by month_name
order by cogs desc



---------------------------------------------------
-- What product line had the largest revenue?

SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;



-----------------------
-- What product line had the largest VAT?
select 
product_line, 
AVG(tax_pct) as Higest_VAT 
from sales
Group by product_line
ORDER BY Higest_VAT DESC;

-- What is the city with the largest revenue?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue;


|product_line          |higest_vat   |
|----------------------|-------------|
|Home and lifestyle    |16.03033125  |
|Sports and travel     |15.8126295181|
|Health and beauty     |15.4115723684|
|Food and beverages    |15.3653103448|
|Electronic accessories|15.2205970588|
|Fashion accessories   |14.5280617978|

--------------------------------------------------------------------

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

select product_line,
CASE
 WHEN AVG(quantity) > 6 THEN 'GOOD'
ELSE 'BAD'
END as remark
FROM sales
GROUP BY product_line ;


product_line          |remark|
----------------------+------+
Fashion accessories   |BAD   |
Electronic accessories|BAD   |
Health and beauty     |BAD   |
Sports and travel     |BAD   |
Food and beverages    |BAD   |
Home and lifestyle    |BAD   |

-----------------------------------------------------------------------------------------------------------------------------------------------

-- Which branch sold more products than average product sold?


SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

branch|qnty|
------+----+
A     |1859|
C     |1831|
B     |1820|


----------------------------------------------------------------------------------------------------------------------------------------------------
-- What is the most common product line by gender


SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;


gender|product_line          |total_cnt|
------+----------------------+---------+
Female|Fashion accessories   |       96|
Female|Food and beverages    |       90|
Female|Sports and travel     |       88|
Male  |Health and beauty     |       88|
Male  |Electronic accessories|       86|
Male  |Food and beverages    |       84|
Female|Electronic accessories|       84|
Male  |Fashion accessories   |       82|
Male  |Home and lifestyle    |       81|
Female|Home and lifestyle    |       79|
Male  |Sports and travel     |       78|
Female|Health and beauty     |       64|


-------------------------------------------------------------------------------------------

-- What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?


SELECT
	DISTINCT customer_type
FROM sales;


------------------------------------------------------------------
-- How many unique payment methods does the data have?


SELECT
	DISTINCT payment
FROM sales;

-----------------------------------------------------------------------

-- What is the most common customer type?


SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

----------------------------------------------------------------------

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-------------------------------------------------------------------------------------
-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;
----------------------------------------------------
-- What is the gender distribution per branch?

SELECT
	gender,
	COUNT(*) as gender_count
FROM sales
WHERE branch = 'C'
GROUP BY gender
ORDER BY gender_cnt DESC;

gender|gender_count|
------+----------+
Female|       178|
Male  |       150|

-----------------------------------------------------------------
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?


SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;


time_of_day|avg_rating       |
-----------+-----------------+
Afternoon  |7.031299737783579|
Morning    |6.960732966817487|
Evening    |6.926851844346082|

----------------------------------------------------------------------------------------------------------------
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?

SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'A'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

time_of_day|avg_rating       |
-----------+-----------------+
Afternoon  |7.188888894187079|
Morning    |7.005479440297166|
Evening    |6.893617017894772|

--------------------------------------------------------------------------------

-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?


SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;


day_name |avg_rating        |
---------+------------------+
Monday   | 7.153599990844727|
Friday   |7.0762589783977266|
Sunday   | 7.011278177562513|
Tuesday  | 7.003164541872242|
Saturday | 6.901829292134541|
Thursday | 6.889855060024538|
Wednesday| 6.805594407595121|

---------------------------------------------------------------------------------
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?


SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 


SELECT
    day_name,
    time_of_day,
    COUNT(*) AS total_sales
FROM
    sales
WHERE
    day_name <> 'Sunday'
GROUP BY
    time_of_day,
    day_name
ORDER BY
    total_sales DESC;
-----------------------------------------------------------------

-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?


SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;


--------------------------------------------------------------------

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

----------------------------------------------------

-- Which customer type pays the most in VAT?


SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax desc;


customer_type|total_tax         |
-------------+------------------+
Normal       |15.148707414829662|
Member       |15.609109780439121|

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------


