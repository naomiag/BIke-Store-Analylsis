USE BikeStores;
GO

--ANALYSIS
SELECT * FROM production.brands
SELECT * FROM production.categories
SELECT * FROM production.products
SELECT * FROM production.stocks
SELECT * FROM sales.customers
SELECT * FROM sales.order_items
SELECT * FROM sales.orders
SELECT * FROM sales.staffs
SELECT * FROM sales.stores

--1. Order Data Overview
SELECT
	o.order_id,
	oi.item_id,
	CONCAT(c.first_name,' ', c.last_name) AS customers_full_name,
	c.city,
	c.state,
	o.order_date,
	SUM(oi.quantity) AS 'total_units',
	SUM(oi.quantity * oi.list_price) AS 'revenue',
	p.product_name,
	ct.category_name,
	s.store_name,
	CONCAT(st.first_name, ' ', st.last_name) AS 'sales_rep'
FROM sales.orders o
	INNER JOIN sales.customers c
		ON o.customer_id = c.customer_id
	INNER JOIN sales.order_items oi
		ON o.order_id = oi.order_id
	INNER JOIN production.products p
		ON oi.product_id = p.product_id
	INNER JOIN production.categories ct
		ON p.category_id = ct.category_id
	INNER JOIN sales.stores s
		ON s.store_id = o.store_id
	INNER JOIN sales.staffs st
		ON o.staff_id = st.staff_id
GROUP BY 
	o.order_id, oi.item_id,
	CONCAT(c.first_name,' ', c.last_name),
	c.city, 
	c.state, 
	o.order_date,
	p.product_name,
	ct.category_name,
	s.store_name,
	CONCAT(st.first_name, ' ', st.last_name)
ORDER BY 1

--2. Sales according to year
SELECT YEAR(o.order_date) AS year, SUM ((quantity * list_price - list_price * discount)) AS total_revenue
FROM sales.order_items oi
	JOIN sales.orders o 
		ON oi.order_id = o.order_id
GROUP BY YEAR(o.order_date)
ORDER BY 1

--3. Sales according to month
SELECT MONTH(o.order_date) AS year, SUM ((quantity * list_price - list_price * discount)) AS total_revenue
FROM sales.order_items oi
	JOIN sales.orders o 
		ON oi.order_id = o.order_id
GROUP BY MONTH(o.order_date)
ORDER BY 1

--4. Mean of sales
SELECT AVG ((quantity * list_price - list_price * discount)) AS total_revenue
FROM sales.order_items oi
	JOIN sales.orders o 
		ON oi.order_id = o.order_id

--5. Count of sold product
SELECT p.product_id, p.product_name, SUM(oi.quantity) AS total_sold
FROM sales.order_items oi
	JOIN production.products p 
		ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY 1

--6. Reveneu per product
SELECT oi.product_id, p.product_name, SUM ((oi.quantity * oi.list_price - oi.list_price * oi.discount)) AS revenue_per_product
FROM sales.order_items oi
	JOIN production.products p
		ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY 1

--7. Total sold by category
SELECT c.category_name, SUM(oi.quantity) AS total_sold
FROM sales.order_items oi
	JOIN production.products p 
		ON p.product_id = oi.product_id
	JOIN production.categories c 
		ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY 1

--8. Reveneu sold by category
SELECT c.category_name, SUM ((oi.quantity * oi.list_price - oi.list_price * oi.discount)) AS revenue_per_category
FROM sales.order_items oi
	JOIN production.products p
		ON oi.product_id = p.product_id
	JOIN production.categories c
		ON  p.category_id = c.category_id
GROUP BY c.category_name

--9. Total product per brand
SELECT b.brand_name, SUM(oi.quantity) AS total_sold
FROM sales.order_items oi
	JOIN production.products p 
		ON p.product_id = oi.product_id
	JOIN production.brands b 
		ON b.brand_id = p.brand_id
GROUP BY b.brand_name
ORDER BY 1

--10. Revenue by brand
SELECT b.brand_name, SUM ((oi.quantity * oi.list_price - oi.list_price * oi.discount)) AS revenue_per_brand
FROM sales.order_items oi
	JOIN production.products p
		ON oi.product_id = p.product_id
	JOIN production.brands b
		ON  p.brand_id = b.brand_id
GROUP BY b.brand_name

--11. Top 5 sales of customers
SELECT TOP 5 
	oi.order_id, 
	o.order_date,
	CONCAT(s.first_name, ' ' , s.last_name) AS staff_name,
	SUM ((oi.quantity * oi.list_price - oi.list_price * oi.discount)) AS price
FROM sales.order_items oi
	JOIN sales.orders o
		ON oi.order_id = o.order_id
	JOIN sales.staffs s
		ON o.staff_id = s.staff_id
GROUP BY oi.order_id, o.order_date, CONCAT(s.first_name, ' ' , s.last_name)
ORDER BY 2 DESC 

--12. Staff and total revenue they handle
SELECT s.staff_id, CONCAT(s.first_name, ' ', s.last_name) AS staff_name, SUM ((oi.quantity * oi.list_price - oi.list_price * oi.discount)) AS revenue
FROM sales.order_items oi
	JOIN sales.orders o
		ON oi.order_id = o.order_id
	JOIN sales.staffs s
		ON o.staff_id = s.staff_id
GROUP BY s.staff_id,  CONCAT(s.first_name, ' ', s.last_name) 
ORDER BY 3

--13. Revenue by store
SELECT s.store_name, SUM ((oi.quantity * oi.list_price - oi.list_price * oi.discount)) AS revenue
FROM sales.order_items oi
	JOIN sales.orders o
		ON oi.order_id = o.order_id
	JOIN sales.stores s
		ON  o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY 1 ASC

--14. Total product sold at the stores
SELECT s.store_name, SUM(oi.quantity) AS total_product_sold
FROM sales.order_items oi
	JOIN sales.orders o
		ON oi.order_id = o.order_id
	JOIN sales.stores s
		ON s.store_id = o.store_id
GROUP BY s.store_name 

--15. Average shipment period
SELECT 
	CAST(
		AVG(
			CAST(
				IIF(
					DATEDIFF(DAY, o.order_date, o.shipped_date) IS NULL, 0, DATEDIFF(DAY, o.order_date, o.shipped_date)
				) AS FLOAT
			)
		) AS DECIMAL(4,2)
	) AS avg_process_day
FROM sales.orders o

--16. Total customer by city
SELECT c.city, COUNT(*) AS customers
FROM sales.customers c
GROUP BY c.city
ORDER BY 2 DESC

--17. Total customer by city (state)
SELECT c.state, COUNT(*) AS customers
FROM sales.customers c
GROUP BY c.state
ORDER BY 1

--18. Percentage of sold product
SELECT 
	oi.product_id, 
	SUM(oi.quantity) AS sold, 
	SUM(oi.quantity) + SUM(s.quantity) AS early_stock, 
	CAST(CAST(CAST(CAST(SUM(oi.quantity) AS FLOAT)/CAST(SUM(oi.quantity) + SUM(s.quantity) AS FLOAT) AS DECIMAL(4,2)) * 100 AS INT) AS VARCHAR) + '%' AS sold_percentage
FROM production.stocks s
	JOIN production.products p
		ON s.product_id = p.product_id
	JOIN sales.order_items oi
		ON p.product_id = oi.product_id
GROUP BY oi.product_id
ORDER BY 1
