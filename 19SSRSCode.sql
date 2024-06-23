-->>SSRS Quuery Designer... Code.
---------------------------------
-->>City product Categry #Order Status #Items Total sales Total freight.
---------------------------------
--SalesByCityAndProduct----------
SELECT 
customer_city AS City,
product_category_english_name As Product_Category,
Count(product_category_english_name) As #Order,
status_type As Status,
sum(product_amount) As #Items,
Sum(sales_amount) As Total_sales, 
Sum(freight_amount) As Total_freight
FROM ECDBMS_DWH.dbo.Fact_Sales AS fs
INNER JOIN ECDBMS_DWH.dbo.Dim_Customers AS dc
ON fs.customer_key = dc.customer_id
INNER JOIN ECDBMS_DWH.dbo.dim_orders AS do
ON fs.order_key=do.order_key
INNER JOIN ECDBMS_DWH.dbo.Dim_products AS dp
ON fs.product_key = dp.product_id
INNER JOIN ECDBMS_DWH.dbo.Dim_sellers AS ds
ON fs.seller_key = ds.seller_id
Group by customer_city,product_category_english_name,status_type
order by customer_city;
----------------------------------
--TotalByCity---------------------
SELECT 
customer_city AS City,
Sum(sales_amount) As Total_Sales, 
Sum(freight_amount) As Total_Freight,
Sum(price_amount) As Total_Price 
FROM ECDBMS_DWH.dbo.Fact_Sales AS fs
INNER JOIN ECDBMS_DWH.dbo.Dim_Customers AS dc
ON fs.customer_key = dc.customer_id
INNER JOIN ECDBMS_DWH.dbo.dim_orders AS do
ON fs.order_key=do.order_key
INNER JOIN ECDBMS_DWH.dbo.Dim_products AS dp
ON fs.product_key = dp.product_id
INNER JOIN ECDBMS_DWH.dbo.Dim_sellers AS ds
ON fs.seller_key = ds.seller_id
Group by customer_city
order by customer_city;
----------------------------------
--SalesByProduct------------------
SELECT ROW_NUMBER() OVER (ORDER BY product_amount DESC) AS Rownumber,
product_key,
product_amount As Qty,
sum(sales_amount) As TotalSales,
sum(freight_amount) As TotalFreight,
sum(price_amount) As TotalPrice
FROM ECDBMS_DWH.dbo.Fact_Sales AS fs
INNER JOIN ECDBMS_DWH.dbo.Dim_Customers AS dc
ON fs.customer_key = dc.customer_id
INNER JOIN ECDBMS_DWH.dbo.dim_orders AS do
ON fs.order_key=do.order_key
INNER JOIN ECDBMS_DWH.dbo.Dim_products AS dp
ON fs.product_key = dp.product_id
INNER JOIN ECDBMS_DWH.dbo.Dim_sellers AS ds
ON fs.seller_key = ds.seller_id
Group by product_key,product_amount
order by product_amount DESC;
---------------------------------
---------------------------------
-->>Order By Items<<--
SELECT 
ROW_NUMBER() OVER (ORDER BY product_amount DESC) AS Rownumber,
fs.order_key,
product_amount As #Items
FROM ECDBMS_DWH.dbo.Fact_Sales AS fs
INNER JOIN ECDBMS_DWH.dbo.Dim_Customers AS dc
ON fs.customer_key = dc.customer_id
INNER JOIN ECDBMS_DWH.dbo.dim_orders AS do
ON fs.order_key=do.order_key
INNER JOIN ECDBMS_DWH.dbo.Dim_products AS dp
ON fs.product_key = dp.product_id
INNER JOIN ECDBMS_DWH.dbo.Dim_sellers AS ds
ON fs.seller_key = ds.seller_id
Group by fs.order_key,product_amount
order by product_amount DESC;
-->>Order by Items<<--.
---------------------------------
-->>Reports<<--



