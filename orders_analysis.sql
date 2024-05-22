
-- find top 10 highest revenue generating products

SELECT TOP 10 product_id, sum(sales_price) as sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC

-- find top 5 heightest selling products from each region

with cte as(
	SELECT region, product_id, sum(sales_price) as sales
	FROM df_orders
	GROUP BY region, product_id)
SELECT * FROM(
	SELECT * 
	, row_number() over(partition by region order by sales desc) as rn
	FROM cte) A
WHERE rn<=5


-- find month over month comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023

with cte as(
	SELECT year(order_date) as year,month(order_date) as month, sum(sales_price) as sales 
	FROM df_orders
	GROUP BY year(order_date), month(order_date)
	)
SELECT month,
sum(CASE WHEN year = 2022 THEN sales ELSE 0 END) as sales_2022,
sum(CASE WHEN year = 2023 THEN sales ELSE 0 END) as sale_2023
FROM cte
GROUP BY month
ORDER BY month


-- for each category which month had heighest sales

with cte as(
SELECT category, format(order_date, 'yyyy-MM') as order_month, sum(sales_price) as sales
	FROM df_orders
	GROUP BY category, format(order_date, 'yyyy-MM')
	--ORDER BY category, format(order_date, 'yyyy-MM')
)
SELECT * FROM(
SELECT *, 
row_number() over(partition by category order by sales desc) as rn
FROM cte) a
WHERE rn = 1


-- which sub category has heighest growth by profit in 2023 compare to 2022


with cte as(
	SELECT sub_category, year(order_date) as year, sum(sales_price) as sales 
	FROM df_orders
	GROUP BY sub_category, year(order_date)
	), 
cte2 as(
SELECT sub_category,
sum(CASE WHEN year = 2022 THEN sales ELSE 0 END) as sales_2022,
sum(CASE WHEN year = 2023 THEN sales ELSE 0 END) as sales_2023
FROM cte
GROUP BY sub_category)
SELECT TOP 1 *,
(sales_2023 - sales_2022)*100/sales_2022 as growth_per
FROM cte2
ORDER BY growth_per DESC