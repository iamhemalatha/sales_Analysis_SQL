SELECT * FROM amazon_sales.amazon;
use amazon_sales

-- checking the shape of table
SELECT COUNT(*) AS rows_count,
(SELECT COUNT(*) 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'amazon_sales'
  AND TABLE_NAME = 'amazon')AS columns_count from amazon;
  
-- checking the data type of Each column of table
DESC amazon_sales.amazon;
SHOW COLUMNS FROM amazon;

-- count of each datatype 
SELECT DATA_TYPE, COUNT(*) AS count_dtype
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'amazon_sales' 
GROUP BY DATA_TYPE;

-- RENAMING THE COLUMN NAMES THAT ARE HAVING SPACES

ALTER TABLE amazon
CHANGE COLUMN `Invoice ID` Invoice_Id VARCHAR(30);
ALTER TABLE amazon
CHANGE COLUMN `Customer type` Customer_type VARCHAR(30);
ALTER TABLE amazon
CHANGE COLUMN `Product line` Product_line VARCHAR(100);
ALTER TABLE amazon
CHANGE COLUMN `Unit price` Unit_price DECIMAL(10, 2);
ALTER TABLE amazon
CHANGE COLUMN `Tax 5%` VAT FLOAT(6,4);
ALTER TABLE amazon
CHANGE COLUMN payment Payment_method VARCHAR(15);
ALTER TABLE amazon
CHANGE COLUMN `gross margin percentage` Gross_Margin_Percentage FLOAT(11, 9);
ALTER TABLE amazon
CHANGE COLUMN `gross income` Gross_income DECIMAL(10, 2);

-- concatinating Date and Time columns

ALTER table amazon add time_of_day VARCHAR(30);

SET SQL_SAFE_UPDATES=0;
UPDATE amazon SET time_of_day = 
 CASE 
    WHEN TIME(Time) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    ELSE 'Evening'
 END ;
 
SET SQL_SAFE_UPDATES=1;

ALTER table amazon add COLUMN day_name VARCHAR(20);

SET SQL_SAFE_UPDATES=0;
UPDATE amazon SET day_name = DAYNAME(Date);
SET SQL_SAFE_UPDATES=1;

ALTER TABLE amazon ADD COLUMN Month_name VARCHAR(20);

SET SQL_SAFE_UPDATES=0;
UPDATE amazon SET Month_name = monthname(Date);
SET SQL_SAFE_UPDATES=1;

-- Finding the distinct value in each column

select Branch, count(Branch) as branch_count from amazon
group by Branch
order by branch_count DESC;

select City, count(City) as City_count from amazon
group by City
order by City_count DESC;

select Customer_type, count(Customer_type) as Customer_type_count from amazon
group by Customer_type
order by Customer_type_count DESC;

select Gender, count(Gender) as Gender_count from amazon
group by Gender
order by Gender_count DESC;

select Product_line, count(Product_line) as Product_line_count from amazon
group by Product_line
order by Product_line_count DESC;

select Payment_method, count(Payment_method) as count from amazon
group by Payment_method
order by count DESC;

select Quantity, count(Quantity) as Quantity_count from amazon
group by Quantity
order by Quantity_count DESC; 

select time_of_day, count(time_of_day) as count from amazon
group by time_of_day
order by count DESC;

select day_name, count(day_name) as count from amazon
group by day_name
order by count DESC;

select month_name, count(month_name) as count from amazon
group by month_name
order by count DESC;

-- Business Questions To Answer:

-- 1. What is the count of distinct cities in the dataset?
select City, count(City) as City_count from amazon
group by City
order by City_count DESC;

-- For each branch, what is the corresponding city?
select distinct branch, City from amazon;

-- What is the count of distinct product lines in the dataset?
select Product_line, count(Product_line) as Product_line_count from amazon
group by Product_line
order by Product_line_count DESC;

-- Which payment method occurs most frequently?
select Payment_method, count(*) as count from amazon
group by Payment_method
order by count DESC;

-- Which product line has the highest sales?
select Product_line, round(sum(Total),2) as Total_Sales from amazon
group by Product_line
order by Total_Sales desc;

-- How much revenue is generated each month?
select month_name, round(sum(Total),2) as generated_revenue from amazon
group by month_name
order by generated_revenue desc;

-- In which month did the cost of goods sold reach its peak?
select month_name, round(sum(cogs),2) as cogs_sold from amazon
group by month_name
limit 1;

-- Which product line generated the highest revenue?
select Product_line, round(sum(Total),2) as highest_revenue from amazon
group by Product_line
limit 1;

-- In which city was the highest revenue recorded?
select City, round(sum(Total),2) as highest_revenue from amazon
group by City
limit 1;

-- Which product line incurred the highest Value Added Tax?
select Product_line, max(VAT)as highest_VAT from amazon
group by Product_line
limit 1;

-- For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT AVG(Total) FROM amazon;

select Product_line, 
CASE
WHEN Total > (SELECT AVG(Total) FROM amazon) THEN "Good"
ELSE "Bad"
END
as product_status from amazon;

-- Identify the branch that exceeded the average number of products sold.
SELECT AVG(Quantity) FROM amazon;

select Branch,city from amazon
WHERE Quantity > (SELECT AVG(Quantity) FROM amazon)
GROUP BY Branch,city;

-- Which product line is most frequently associated with each gender?
select Product_line, Gender,COUNT(*) AS frequency,
RANK() OVER (PARTITION BY Gender ORDER BY COUNT(*) DESC) AS ranks
from amazon
GROUP BY Product_line, Gender;

-- Calculate the average rating for each product line.
SELECT Product_line, ROUND(AVG(Rating),2) FROM amazon
GROUP BY Product_line
ORDER BY Product_line DESC;

-- Count the sales occurrences for each time of day on every weekday.
SELECT day_name, COUNT(Invoice_Id) as NO_sales_occurrences FROM amazon 
WHERE day_name NOT IN ("Saturday","Sunday")
GROUP BY day_name
ORDER BY NO_sales_occurrences DESC;

-- Identify the customer type contributing the highest revenue.
SELECT Customer_type, SUM(Total)AS highest_contributing 
FROM amazon
GROUP BY Customer_type
LIMIT 1;

-- Determine the city with the highest VAT percentage.
select City, MAX((VAT/Total)*100) as highest_VAT_percent from amazon
GROUP BY City
LIMIT 1;

-- Identify the customer type with the highest VAT payments.
select Customer_type, SUM(VAT) from amazon
GROUP BY Customer_type
LIMIT 1;

-- What is the count of distinct customer types in the dataset?
select  count(DISTINCT Customer_type) as Customer_type_count from amazon
order by Customer_type_count DESC;

-- What is the count of distinct payment methods in the dataset?
select count(DISTINCT Payment_method) as Payment_method_count from amazon;

-- Which customer type occurs most frequently?
select Customer_type, count(*) as Customer_type_count from amazon
GROUP BY Customer_type
ORDER BY Customer_type_count DESC
LIMIT 1;

-- Identify the customer type with the highest purchase frequency.
select Customer_type, count(Customer_type) as MAX_purchase_frequency from amazon
GROUP BY Customer_type
ORDER BY MAX_purchase_frequency DESC
LIMIT 1;

-- Determine the predominant gender among customers.
select Gender, count(Gender) as Gender_count from amazon
group by Gender
order by Gender_count DESC
LIMIT 1;

-- Examine the distribution of genders within each branch.
select Branch, Gender, count(Gender) as Gender_count from amazon
group by Branch,Gender
order by Gender_count DESC;

-- Identify the time of day when customers provide the most ratings.
select time_of_day,  count(Rating) as Rating_count from amazon
group by time_of_day
order by Rating_count DESC
LIMIT 1;

-- Determine the time of day with the highest customer ratings for each branch.
select time_of_day, count(Rating) as Rating_count, Branch from amazon
group by time_of_day, Branch
order by Rating_count DESC
LIMIT 1; 

-- Identify the day of the week with the highest average ratings.
select day_name, AVG(Rating) as AVG_Rating_count from amazon
group by day_name
order by AVG_Rating_count DESC
LIMIT 1; 

-- Determine the day of the week with the highest average ratings for each branch.
select day_name, AVG(Rating) as AVG_Rating_count, Branch from amazon
group by day_name, Branch
order by AVG_Rating_count DESC; 

