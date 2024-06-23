-->>Create OLAP.
-->>Create Data Warehouse.
-->>Data WareHouse Design.
-------------Build Data WareHouse----------------
-->>Checking Data in Table<<--
SELECT * 
FROM DBMS.dbo.customers;
------------------------
SELECT * 
FROM DBMS.dbo.geolocation;
------------------------
SELECT * 
FROM DBMS.dbo.items;
------------------------
SELECT * 
FROM DBMS.dbo.order_payments;
------------------------
SELECT* 
FROM DBMS.dbo.order_status_types;
------------------------
SELECT *
FROM DBMS.dbo.orders;
------------------------
SELECT *
FROM DBMS.dbo.payment_types;
------------------------
SELECT * 
FROM DBMS.dbo.products;
------------------------
SELECT *
FROM DBMS.dbo.sellers;
------------------------
-->>Create Database ECDBMS_DWH.
go
Create Database EC_DWH;
--------------------------
use EC_DWH;
-->>Create Table Dim Data Table<<--
CREATE TABLE Dim_Date (
    DateKey INT PRIMARY KEY,
    DateFull Date,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT,
    DayOfWeek INT,
    DayName nvarchar(10),
    MonthName nvarchar(10)
);
-----------------------
-->>Calculate The Minimum() and Maximum().
-----------------------
-->>The Minimum() Time.
SELECT * FROM DBMS.dbo.orders;
SELECT MIN(order_purchase_timestamp)
FROM DBMS.dbo.orders;
-----------------------
-->>The Maximum() Time.
SELECT MAX(order_purchase_timestamp)
FROM DBMS.dbo.orders;
-----------------------
-->>Declare variable StartDate And EndDate.
--use ECDBMS_DWH;
--DECLARE @StartDate DATE = '2016-01-01';
--DECLARE @EndDate DATE = '2018-12-31';
-----------------------
/*
>>INSERT Data Into Dim_Date Table Using While Begin End.
CAST(CONVERT(VARCHAR(8),@StartDate,112) AS INT)>>AS>>Date in Excel serial number.
*/
USE EC_DWH;
DECLARE @StartDate DATE = '2016-01-01';
DECLARE @EndDate DATE = '2018-12-31';
WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO Dim_Date (
        DateKey,
        DateFull,
        Year,
        Quarter,
        Month,
        Day,
        DayOfWeek,
        DayName,
        MonthName
    )
    VALUES (
        CAST(CONVERT(VARCHAR(8), @StartDate, 112) AS INT),
        CONVERT(VARCHAR(10), @StartDate, 120),
        YEAR(@StartDate),
        DATEPART(QUARTER, @StartDate),
        MONTH(@StartDate),
        DAY(@StartDate),
        DATEPART(WEEKDAY, @StartDate),
        DATENAME(WEEKDAY, @StartDate),
        DATENAME(MONTH, @StartDate)
    );

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;
-->>Checking The Data Inserted in Table Dim_Date. 
SELECT * FROM EC_DWH.dbo.Dim_Date; 
--------------------------------------
SELECT DateKey,DateFull,Year,Quarter,Month,Day,DayOfWeek,DayName,MonthName
FROM EC_DWH.dbo.Dim_Date;
--------------------------------------
-->>Dim_Products Table.
-->>Creating Dim_Products Table.
--------------------------------
SELECT * FROM DBMS.dbo.products;
--------------------------------
/*
>>Take The Data From Table products 
Insert Into Dim_products Table. 
*/
Select * 
Into EC_DWH.dbo.Dim_products
From DBMS.dbo.products;
--------------------------------
SELECT * FROM EC_DWH.dbo.Dim_products; 
--------------------------------
SELECT product_id,product_category_name,product_name_lenght,product_description_lenght,product_photos_qty,
product_weight_g,product_length_cm,product_height_cm,product_width_cm
FROM EC_DWH.dbo.Dim_products;
--------------------------------
--------------------------------
---Rename (product_category_name column) to (product_category_english_name column)
use EC_DWH;
EXEC sp_rename 
    @objname = 'dbo.Dim_products.product_category_name',
    @newname = 'product_category_english_name',
    @objtype = 'COLUMN';
------------------------
/*
-->>SELECT All Columns From Dim_products Table.
-->>Where Dim_products Table has one Primary Key>>product_id.
*/
SELECT *
FROM EC_DWH.dbo.Dim_products;
-------------------------
-->>Dim_Customers Table.
-------------------------
/*
Create The Dim_Customers Table From 
>>DBMS.dbo.customers and DBMS.dbo.geolocation.
*/
Select customer_id,customer_unique_id,customer_zip_code_prefix 
FROM DBMS.dbo.customers;
---------------------------------
Select geolocation_zip_code_prefix,geolocation_lat,geolocation_lng,geolocation_city,geolocation_state 
FROM DBMS.dbo.geolocation;
---------------------------------
-->>Create Dimantion Table Customers.
-->>A Dimension Table>>Stores Descriptive Attributes.
---------------------------------
Select 
	c.customer_id,
	c.customer_unique_id,
	G.geolocation_city   as customer_city,
	G.geolocation_state  as customer_state
Into 
	EC_DWH.dbo.Dim_Customers
from DBMS.dbo.customers as C join DBMS.dbo.geolocation as G
On C.customer_zip_code_prefix = G.geolocation_zip_code_prefix;
----------------------------------
SELECT * FROM EC_DWH.dbo.Dim_Customers;
----------------------------------
-->>Dim_Sellers Table.
----------------------------------
SELECT seller_id,seller_zip_code_prefix 
FROM DBMS.dbo.sellers;
-->>Creating Dim_sellers Table.
-->>Every Dimension Table has one Primary key.
Select 
	S.seller_id,
	G.geolocation_city   as seller_city,
	G.geolocation_state  as seller_state
Into 
	EC_DWH.dbo.Dim_sellers
from DBMS.dbo.sellers as S join DBMS.dbo.geolocation as G
On S.seller_zip_code_prefix = G.geolocation_zip_code_prefix;
-----------------------------------
SELECT * FROM DBMS.dbo.orders;
SELECT * FROM DBMS.dbo.order_payments;
SELECT * FROM DBMS.dbo.payment_types;
SELECT * FROM DBMs.dbo.order_status_types;
-----------------------------------
-->>Creating Dim_orders Table.
-->>Insert Into Table dim_orders>>That Descripe of it AS Type. 
Select
		O.order_id      as order_key,
		S.status_type,
		Pt.payment_type,
		P.payment_sequential,
		P.payment_installments
		
Into 
		EC_DWH.dbo.dim_orders
From 
DBMS.dbo.orders as O Join DBMS.dbo.order_payments as P
on o.order_id = P.order_id Join DBMS.dbo.payment_types as Pt
on P.payment_type_id = Pt.id Join DBMS.dbo.order_status_types as S
on O.order_status_id = S.id;
-------------------------------------
-->>Dimension Table>>That Descripe the orders As (status_type,payment_type).
SELECT * FROM EC_DWH.dbo.dim_orders;
-------------------------------------
-->>Create Factsales Table>>(FACTsales Table).
-->>[Creating Factsales Table].
-------------------------------
-->>A Fact Table usually contains two Types of Columns:- 
-->>Measures and Foreign Keys From Dim_Tables. 
-->>In a Data-Warehouse,
-->>A Measure is a property on which Calculations can be Made.
--------------------------------
-->>Creating Factsales Table.
-->>Checking>>Tables Measures and Primary Keys.
-----------------------------------------------
-->>Checking Tables You Take Data.
SELECT *
FROM DBMS.dbo.orders;-->>Take order_id And order Column has Time.
---------------------
SELECT * 
FROM DBMS.dbo.order_payments;-->>Take payment_value Column.
---------------------
/*Price would be included in The Fact Table as a Measure. 
>>Measures are typically numerical values that you want to Analyze, Aggregate, and Report on.
*/
SELECT * 
FROM DBMS.dbo.items;-->>shipping_limit_date,price,freight_value,product_counter.
---------------------
SELECT *
FROM DBMS.dbo.sellers;-->>Take seller_id.
---------------------
SELECT *
FROM DBMS.dbo.products;-->>product_id.
---------------------
/*
Build Fact Table According to Business Requirements.
*/
-->>Take Dim primary keys As Foreign.
SELECT 
ord.order_id as order_key,
ord.customer_id as customer_key,
S.seller_id as seller_key,
Pro.product_id as product_key,
ord.order_purchase_timestamp      as purchase_timestamp_key,
ord.order_approved_at             as approved_at_key,
ord.order_delivered_carrier_date  as delivered_carrier_date_key,
ord.order_delivered_customer_date as delivered_customer_date_key,
ord.order_estimated_delivery_date as estimated_delivery_date_key,
I.shipping_limit_date           as shipping_limit_date_key,
I.product_counter               as product_amount,
op.payment_value                 as sales_amount,
I.freight_value                 as freight_amount,
I.price							as price_amount
INTO EC_DWH.dbo.Fact_Sales
FROM DBMS.dbo.orders as ord 
Join DBMS.dbo.order_payments as op
on ord.order_id = op.order_id 
Join DBMS.dbo.items as I
on ord.order_id = I.order_id
Join DBMS.dbo.sellers as S
on S.seller_id = I.seller_id
Join DBMS.dbo.products as Pro
on Pro.product_id = I.product_id;
---------------------------------
-->>Check The Fact Table.
SELECT * FROM EC_DWH.dbo.Fact_Sales;
----------------------------------------
----------------------------------------
-->>Add Primary-key Foreign-key To Tables.
----------------------------------------
-->>Dim_Customer Table.
ALTER TABLE EC_DWH.dbo.Dim_Customers
ADD CONSTRAINT PK_Dim_Customers PRIMARY KEY (customer_id);
----------------------------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN customer_key nvarchar(255) NULL;
----------------------------------------
INSERT INTO EC_DWH.dbo.Dim_Customers(customer_id)
SELECT customer_key FROM EC_DWH.dbo.Fact_Sales
WHERE customer_key NOT IN (SELECT customer_id FROM EC_DWH.dbo.Dim_Customers);
----------------------------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_customer_key12
FOREIGN KEY (customer_key) 
REFERENCES EC_DWH.dbo.Dim_Customers(customer_id);
----------------------------------------
SELECT * FROM EC_DWH.dbo.Dim_Customers;
----------------------------------------
-->>Dim_products Table.
ALTER TABLE EC_DWH.dbo.Dim_products
ADD CONSTRAINT PK_Dim_products PRIMARY KEY (product_id);
----------------------------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_products_key12
FOREIGN KEY (product_key) 
REFERENCES EC_DWH.dbo.Dim_products(product_id);
----------------------------------------
-->>Dim_sellers Table.
ALTER TABLE EC_DWH.dbo.Dim_sellers
ADD CONSTRAINT PK_Dim_sellers PRIMARY KEY (seller_id);
-----------------------------------------
INSERT INTO EC_DWH.dbo.Dim_sellers(seller_id)
SELECT seller_key FROM EC_DWH.dbo.Fact_Sales
WHERE seller_key NOT IN (SELECT seller_id FROM EC_DWH.dbo.Dim_sellers);
-----------------------------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_seller_key
FOREIGN KEY (seller_key) 
REFERENCES EC_DWH.dbo.Dim_sellers(seller_id);
------------------------------------------
-->>Dim_orders Table.
ALTER TABLE EC_DWH.dbo.Dim_orders
ADD CONSTRAINT PK_Dim_orders PRIMARY KEY (order_key);
------------------------------------------
INSERT INTO EC_DWH.dbo.dim_orders(order_key)
SELECT order_key FROM EC_DWH.dbo.Fact_Sales
WHERE order_key NOT IN (SELECT order_key FROM EC_DWH.dbo.dim_orders);
------------------------------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_order_key
FOREIGN KEY (order_key) 
REFERENCES EC_DWH.dbo.dim_orders(order_key);
------------------------------------------
-->>Dim_Date Time.
-------------------
SELECT * FROM EC_DWH.dbo.Dim_Date;
-------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN purchase_timestamp_key VARCHAR(255) NULL;
-------------------
UPDATE EC_DWH.dbo.Fact_Sales
SET purchase_timestamp_key = CONVERT(INT, CONVERT(VARCHAR(8), 
CONVERT(DATETIME, purchase_timestamp_key), 112));
-------------------
SELECT * FROM EC_DWH.dbo.Fact_Sales;
-------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN purchase_timestamp_key INT NULL;
-------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_purchase_timestamp_key
FOREIGN KEY (purchase_timestamp_key) 
REFERENCES EC_DWH.dbo.Dim_Date(DateKey);
------------------
--approved_at_key.
--delivered_carrier_date_key.
--delivered_customer_date_key.
--estimated_delivery_date_key.
--shipping_limit_date_key.
------------------
SELECT approved_at_key,delivered_carrier_date_key,
estimated_delivery_date_key,shipping_limit_date_key 
FROM EC_DWH.dbo.Fact_Sales;
------------------
-->>approved at key.
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN approved_at_key VARCHAR(255) NULL;
-------------------
UPDATE EC_DWH.dbo.Fact_Sales
SET approved_at_key = CONVERT(INT, CONVERT(VARCHAR(255), 
CONVERT(DATETIME, approved_at_key), 112));
-------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN approved_at_key INT NULL;
-------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_approved_at_key
FOREIGN KEY (approved_at_key) 
REFERENCES EC_DWH.dbo.Dim_Date(DateKey);
--------------------
--delivered_carrier_date_key.
UPDATE EC_DWH.dbo.Fact_Sales
SET delivered_carrier_date_key = '1900-01-01'
WHERE delivered_carrier_date_key IS NULL;
---------------------------------------------
SELECT * 
FROM EC_DWH.dbo.Fact_Sales;
---------------------------------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN delivered_carrier_date_key VARCHAR(255) NULL;
--------------------
--ALTER TABLE ECDBMS_DWH.dbo.Fact_Sales
--ALTER COLUMN delivered_carrier_date_key INT NOT NULL;
--------------------
UPDATE EC_DWH.dbo.Fact_Sales
SET delivered_carrier_date_key = CONVERT(INT, CONVERT(VARCHAR(255), 
CONVERT(DATETIME, delivered_carrier_date_key), 112));
--------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN delivered_carrier_date_key INT NULL;
---------------------
INSERT INTO EC_DWH.dbo.Dim_Date(DateKey)
SELECT TOP 1 delivered_carrier_date_key FROM EC_DWH.dbo.Fact_Sales
WHERE delivered_carrier_date_key = 19000101
---------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_delivered_carrier_date_key
FOREIGN KEY (delivered_carrier_date_key) 
REFERENCES EC_DWH.dbo.Dim_Date(DateKey);
--------------------
-->delivered_customer_date_key
UPDATE EC_DWH.dbo.Fact_Sales
SET delivered_customer_date_key = '1900-01-01'
WHERE delivered_customer_date_key IS NULL;
--------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN delivered_customer_date_key VARCHAR(255) NULL;
--------------------
UPDATE EC_DWH.dbo.Fact_Sales
SET delivered_customer_date_key = CONVERT(INT, CONVERT(VARCHAR(255), 
CONVERT(DATETIME, delivered_customer_date_key), 112));
--------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN delivered_customer_date_key INT NULL;
--------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_delivered_customer_date_key
FOREIGN KEY (delivered_customer_date_key) 
REFERENCES EC_DWH.dbo.Dim_Date(DateKey);
--------------------
--estimated_delivery_date_key.
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN estimated_delivery_date_key VARCHAR(255) NULL;
--------------------
UPDATE EC_DWH.dbo.Fact_Sales
SET estimated_delivery_date_key = CONVERT(INT, CONVERT(VARCHAR(255), 
CONVERT(DATETIME, estimated_delivery_date_key), 112));
--------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN estimated_delivery_date_key INT NULL;
--------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_estimated_delivery_date_key
FOREIGN KEY (estimated_delivery_date_key) 
REFERENCES EC_DWH.dbo.Dim_Date(DateKey);
--------------------
--shipping_limit_date_key.
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN shipping_limit_date_key VARCHAR(255) NULL;
--------------------
UPDATE EC_DWH.dbo.Fact_Sales
SET shipping_limit_date_key = CONVERT(INT, CONVERT(VARCHAR(255), 
CONVERT(DATETIME, shipping_limit_date_key), 112));
--------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ALTER COLUMN shipping_limit_date_key INT NULL;
--------------------
INSERT INTO EC_DWH.dbo.Dim_Date (DateKey)
SELECT DISTINCT shipping_limit_date_key
FROM EC_DWH.dbo.Fact_Sales
WHERE shipping_limit_date_key NOT IN (SELECT DateKey FROM EC_DWH.dbo.Dim_Date);
--------------------
ALTER TABLE EC_DWH.dbo.Fact_Sales
ADD CONSTRAINT FK_shipping_limit_date_key
FOREIGN KEY (shipping_limit_date_key) 
REFERENCES EC_DWH.dbo.Dim_Date(DateKey);
--------------------
SELECT * FROM ECDBMS_DWH.dbo.Fact_Sales;
--------------------
--------------------
--SELECT ALL Column From Fact_Sales Table.
SELECT *
FROM ECDBMS_DWH.dbo.Fact_Sales
Order By purchase_timestamp_key,approved_at_key,delivered_carrier_date_key,
delivered_customer_date_key,estimated_delivery_date_key,shipping_limit_date_key;
---------------------
---------------------
---------------------



