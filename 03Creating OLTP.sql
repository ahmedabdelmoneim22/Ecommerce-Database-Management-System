-->>Create The OLTP<<--
--------------------------------------
-->>DBMS-->>RightClick-->>Tasks-->>Import Data.
--------------------------------------
-->>Import This Dataset<<--.
--1>>olist_customers_dataset.
--2>>olist_geolocation_dataset.
--3>>olist_order_items_dataset.
--4>>olist_order_payments_dataset.
--5>>olist_orders_dataset.
--6>>olist_products_dataset.
--7>>olist_sellers_dataset.
---------------------------------------
-->>Delete data From Dataset logical Error>>Insert.
-->>Delete>>Duplicates.
---------------------------------------
-->>Data Cleaning For Customer , 
-->>Seller and Geolocation Tables<<--
---------------------------------------
---Checking For customer_id Duplicates in Customers Table---
SELECT * FROM DBMS.dbo.customers as c
order by c.customer_zip_code_prefix
--------------------------------------
SELECT * FROM DBMS.dbo.geolocation as g
order by g.geolocation_zip_code_prefix
--------------------------------------
SELECT * FROM DBMS.dbo.customers as c
Where customer_zip_code_prefix Not In (
SELECT geolocation_zip_code_prefix 
FROM DBMS.dbo.geolocation)
-->>Order By c.customer_zip_code_prefix.
-->>INSERT Data Not Include In GeoLocation Table
INSERT INTO DBMS.dbo.geolocation(geolocation_zip_code_prefix,geolocation_city,geolocation_state)
SELECT c.customer_zip_code_prefix,c.customer_city,c.customer_state 
FROM DBMS.dbo.customers as c
Where customer_zip_code_prefix Not In (
SELECT geolocation_zip_code_prefix 
FROM DBMS.dbo.geolocation)
--------------------------------------
SELECT * FROM DBMS.dbo.geolocation
-------------------Checking Data------
SELECT * FROM DBMS.dbo.customers as c
Where customer_zip_code_prefix Not In (
SELECT geolocation_zip_code_prefix 
FROM DBMS.dbo.geolocation)
--------------------------------------
SELECT * FROM DBMS.dbo.geolocation
Where geolocation_lat is NULL and geolocation_lng is Null;
--------------------------------------
SELECT DISTINCT customer_zip_code_prefix, customer_city
FROM DBMS.dbo.customers
WHERE customer_city NOT IN (SELECT geolocation_city FROM DBMS.dbo.geolocation);
--------------------------------------
UPDATE DBMS.dbo.geolocation
SET geolocation_city = c.customer_city
FROM DBMS.dbo.customers AS c
Where geolocation_zip_code_prefix = 13508
----------------Checking The Update----
Select* FROM DBMS.dbo.geolocation
SELECT * FROM DBMS.dbo.customers
Where customer_zip_code_prefix = 13508
--------------------------------------
UPDATE DBMS.dbo.geolocation
SET geolocation_city = c.customer_city
FROM DBMS.dbo.customers AS c
Where geolocation_zip_code_prefix = 15903
--------------------------------------
UPDATE DBMS.dbo.geolocation
SET geolocation_city = c.customer_city
FROM DBMS.dbo.customers AS c
Where geolocation_zip_code_prefix = 28143
---------------------------------------
UPDATE DBMS.dbo.geolocation
SET geolocation_city = c.customer_city
FROM DBMS.dbo.customers AS c
Where geolocation_zip_code_prefix = 29386
----------------------------------------
UPDATE DBMS.dbo.geolocation
SET geolocation_city = c.customer_city
FROM DBMS.dbo.customers AS c
Where geolocation_zip_code_prefix = 45534
-----------------------------------------
UPDATE DBMS.dbo.geolocation
SET geolocation_city = c.customer_city
FROM DBMS.dbo.customers AS c
Where geolocation_zip_code_prefix = 48793
--------------------------------------
UPDATE DBMS.dbo.geolocation
SET geolocation_city = c.customer_city
FROM DBMS.dbo.customers AS c
Where geolocation_zip_code_prefix = 48967
--------------------------------------
UPDATE DBMS.dbo.geolocation
SET geolocation_city = c.customer_city
FROM DBMS.dbo.customers AS c
Where geolocation_zip_code_prefix = 85138
--------------------------------------
-->>Checking Duplicates In Customers Table.
SELECT customer_id,COUNT(*)
FROM DBMS.dbo.customers
Group By customer_id
Having COUNT(*) > 1
--------------------------------------
-->>Checking Duplicates In GeoLocation Table.
SELECT geolocation_zip_code_prefix,COUNT(*)
FROM DBMS.dbo.geolocation
Group By geolocation_zip_code_prefix
Having COUNT(*) > 1
--------------------------------------
-->>Delete The Duplicated Data.
WITH DuplicateData AS (
    SELECT 
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
        ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix 
		                   ORDER BY geolocation_zip_code_prefix ASC) AS RN
    FROM 
        DBMS.dbo.geolocation
)
DELETE FROM DBMS.dbo.geolocation
WHERE geolocation_zip_code_prefix IN (
    SELECT geolocation_zip_code_prefix
    FROM DuplicateData
    WHERE RN > 1
);
-->>Checking Geolocation Table.
SELECT *
FROM DBMS.dbo.geolocation
ORDER BY geolocation_zip_code_prefix
--------------------------------------
SELECT * FROM DBMS.dbo.customers
--------------------------------------
SELECT customer_zip_code_prefix,COUNT(*)
FROM DBMS.dbo.customers
GROUP BY customer_zip_code_prefix
Having COUNT(*) > 1
--------------------------------------
-->>Delete The Duplicated Data.
WITH DuplicateData AS (
    SELECT 
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        ROW_NUMBER() OVER (PARTITION BY customer_zip_code_prefix
		                   ORDER BY customer_zip_code_prefix ASC) AS RN
    FROM 
        DBMS.dbo.customers
)
DELETE FROM DBMS.dbo.customers
WHERE customer_zip_code_prefix IN (
    SELECT customer_zip_code_prefix
    FROM DuplicateData
    WHERE RN > 1
); 
--------------------------------------
SELECT * 
FROM DBMS.dbo.customers
------------------------------------
SELECT customer_id 
FROM DBMS.dbo.customers
WHERE customer_id is NULL
--------------------------------------
INSERT INTO DBMS.dbo.geolocation(geolocation_zip_code_prefix,geolocation_city,geolocation_state)
SELECT customer_zip_code_prefix,customer_city,customer_state 
FROM DBMS.dbo.customers
WHERE customer_zip_code_prefix Not in (
SELECT geolocation_zip_code_prefix 
FROM DBMS.dbo.geolocation)
--------------------------------------
-->>Checking Duplicates in Table.
SELECT seller_zip_code_prefix,COUNT(*) 
FROM DBMS.dbo.sellers
GROUP By seller_zip_code_prefix
Having COUNT(*)>1
--------------------------------------
SELECT *
FROM DBMS.dbo.sellers
Order By seller_zip_code_prefix
--------------------------------------
-->>Delete Duplicates From Table Sales.
WITH DuplicateData AS (
    SELECT 
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        ROW_NUMBER() OVER (PARTITION BY seller_zip_code_prefix
		                   ORDER BY seller_zip_code_prefix ASC) AS RN
    FROM 
        DBMS.dbo.sellers
)
DELETE FROM DBMS.dbo.sellers
WHERE seller_zip_code_prefix IN (
    SELECT seller_zip_code_prefix
    FROM DuplicateData
    WHERE RN > 1
); 
--------------------------------------
--SELECT Data From Sellers Table Not Into GeoLocation.
SELECT * FROM DBMS.dbo.sellers
Where seller_zip_code_prefix NOT IN (
SELECT geolocation_zip_code_prefix 
FROM DBMS.dbo.geolocation
)
--------------------------------------
INSERT INTO DBMS.dbo.geolocation(geolocation_zip_code_prefix,geolocation_city,geolocation_state)
SELECT seller_zip_code_prefix,seller_city,seller_state 
FROM DBMS.dbo.sellers
Where seller_zip_code_prefix NOT IN (
SELECT geolocation_zip_code_prefix 
FROM DBMS.dbo.geolocation)
--------------------------------------
SELECT * FROM DBMS.dbo.sellers
Where seller_zip_code_prefix Not In (
Select geolocation_zip_code_prefix 
FROM DBMS.dbo.geolocation
)
---------------------------------------
--Set>>Primary Key To Geolocation Table
ALTER TABLE DBMS.dbo.geolocation
ALTER COLUMN geolocation_zip_code_prefix INT NOT NULL;
--------------------------------------
ALTER TABLE DBMS.dbo.geolocation
ADD CONSTRAINT PK_geolocation_1 PRIMARY KEY (geolocation_zip_code_prefix);
---------------------------------------
--Set>>Primary Key To Customers Table
ALTER TABLE DBMS.dbo.customers
ALTER COLUMN customer_id nvarchar(255) NOT NULL;
------------------------------
ALTER TABLE DBMS.dbo.customers
ADD CONSTRAINT PK_customers_2 PRIMARY KEY (customer_id);
------------------------------
SELECT * FROM DBMS.dbo.customers
WHERE customer_zip_code_prefix is null
------------------------------
ALTER TABLE DBMS.dbo.customers
ALTER COLUMN customer_zip_code_prefix INT NULL;
--Set>>FOREIGN Key To Customers Table.
ALTER TABLE DBMS.dbo.customers
ADD CONSTRAINT FK_customer_ZIP_code_prefix_25
FOREIGN KEY (customer_zip_code_prefix) 
REFERENCES DBMS.dbo.geolocation(geolocation_zip_code_prefix);
--------------------------------
--Set>>FOREIGN Key To Customers Table.
--ALTER TABLE DBMS.dbo.customers
--ADD CONSTRAINT FK_customer_ZIP_code_prefix_12
--FOREIGN KEY (customer_zip_code_prefix) 
--REFERENCES DBMS.dbo.geolocation(geolocation_zip_code_prefix);
----------------------------------
----------------------------------
Alter Table DBMS.dbo.customers
drop column customer_city,customer_state
Alter Table DBMS.dbo.sellers
drop column seller_city,seller_state
--------------------------------------
ALTER TABLE DBMS.dbo.sellers
ALTER COLUMN seller_id nvarchar(255) NOT NULL;
--------------------------------------
--a duplicate key was found for the object name 'dbo.sellers'.
SELECT seller_id,COUNT(*) 
FROM DBMS.dbo.sellers
GROUP BY seller_id
Having COUNT(*) > 1
--------------------------------------
WITH DuplicateData AS (
    SELECT seller_id,seller_zip_code_prefix,
        ROW_NUMBER() OVER (PARTITION BY seller_id
		                   ORDER BY seller_id ASC) AS RN
    FROM 
        DBMS.dbo.sellers
)
DELETE FROM DBMS.dbo.sellers
WHERE seller_id IN (
    SELECT seller_id
    FROM DuplicateData
    WHERE RN > 1
); 
--------------------------------------
ALTER TABLE DBMS.dbo.sellers
ADD CONSTRAINT PK_sellers PRIMARY KEY (seller_id);
--------------------------------------
ALTER TABLE DBMS.dbo.sellers
ALTER COLUMN seller_zip_code_prefix INT NULL;
--Set>>FOREIGN Key To Customers Table.
ALTER TABLE DBMS.dbo.sellers
ADD CONSTRAINT FK_seller_ZIP_code_prefix_12
FOREIGN KEY (seller_zip_code_prefix) 
REFERENCES DBMS.dbo.geolocation(geolocation_zip_code_prefix);
--------------------------------------
--------------------------------------------------------------
-->>orders Table.
SELECT * FROM DBMS.dbo.orders
----------------------------
SELECT *
FROM DBMS.dbo.orders
Where order_id like '% %'
-->>Cleaning order_id column and make all values without ""
UPDATE DBMS.dbo.orders
SET order_id = REPLACE(TRIM('"'FROM order_id ), '"','');
-->>The TRIM() function removes the space character.
-----------------------------
SELECT * 
FROM DBMS.dbo.orders
-----------------------------
-->Checking For order_id Duplicates in Orders Table.
SELECT order_id,COUNT(*)
FROM DBMS.dbo.orders
GROUP BY order_id
Having COUNT(*) > 1
------------------------------
-->Checking For customer_id Duplicates in Orders Table.
SELECT order_id,customer_id,COUNT(*)
FROM DBMS.dbo.orders
GROUP BY order_id,customer_id
Having COUNT(*) > 1
-------------------------------
/*This Is ERROR
WITH DuplicateData AS (
    SELECT customer_id,
        ROW_NUMBER() OVER (PARTITION BY customer_id
		                   ORDER BY customer_id ASC) AS RN
    FROM 
        DBMS.dbo.orders)
DELETE FROM DBMS.dbo.orders
WHERE customer_id IN (
    SELECT customer_id
    FROM DuplicateData
    WHERE RN > 1
);*/
-------------------------------
-->Cleaning The Orders Table.
SELECT * FROM DBMS.dbo.orders;
/*
>>Delete The Rows That Have NULL Values.
*/
Delete from DBMS.dbo.orders
WHERE order_status = 'delivered' 
and order_delivered_customer_date is null
---------------------------------
Delete from DBMS.dbo.orders
WHERE order_status = 'shipped' 
and order_delivered_carrier_date is null
---------------------------------
-->>Create Order_Status_Types Table.
-->>A clustered index is used to define 
-->>the order or to sort the Table or Arrange 
-->>The data by Alphabetical order just like a Dictionary. 
Create Table DBMS.dbo.order_status_types(
  id int not null, 
  status_type varchar(50) null 
  Constraint PK_status_types primary key clustered(id asc)
)
-->>Inserting Values into order_status_types Table.
Insert into DBMS.dbo.order_status_types(id, status_type) 
Values 
  (1, 'created'), 
  (2, 'shipped'), 
  (3, 'canceled'), 
  (4, 'approved'), 
  (5, 'processing'),
  (6,'unavailable'),
  (7,'delivered'),
  (8,'invoiced')
-----------------------------------------
-->>Checking Data is Inserted.
SELECT * FROM DBMS.dbo.order_status_types
-----------------------------------------
-->>Select All Column Data.
SELECT * FROM DBMS.dbo.orders
-->>Renaming(order_status)column to(order_status_id)column 
-->>in DBMS.dbo.orders;
USE DBMS;
EXEC sp_rename 'orders.order_status', 'order_status_id', 'COLUMN';
-->>Checking Column is Renamed.
SELECT order_id,order_status_id
FROM DBMS.dbo.orders
--------------------
-->>Cleaning The (order_status_id) column in orders Table.
SELECT * 
FROM DBMS.dbo.orders
---------------------
--Update Every One Uniquely--
-->>'created''shipped''canceled''approved''processing'
-->>'unavailable''delivered''invoiced''not_defined'.
Update DBMS.dbo.orders
Set order_status_id = 1
Where order_status_id = 'created' 
-------------------------------
Update DBMS.dbo.orders
Set order_status_id = 2
Where order_status_id = 'shipped'
-------------------------------
Update DBMS.dbo.orders
Set order_status_id = 3
Where order_status_id = 'canceled'
-------------------------------
Update DBMS.dbo.orders
Set order_status_id = 4
Where order_status_id = 'approved'
----------------------------------
Update DBMS.dbo.orders
Set order_status_id = 5
Where order_status_id = 'processing'
----------------------------------
Update DBMS.dbo.orders
Set order_status_id = 6
Where order_status_id = 'unavailable'
----------------------------------
Update DBMS.dbo.orders
Set order_status_id = 7
Where order_status_id = 'delivered'
----------------------------------
Update DBMS.dbo.orders
Set order_status_id = 8
Where order_status_id = 'invoiced'
----------------------------------
Update DBMS.dbo.orders
Set order_status_id = 9
Where order_status_id = 'not_defined'
-------------------------------
SELECT * FROM DBMS.dbo.orders;
-------------------------------
SELECT * FROM DBMS.dbo.order_status_types;
-------------------------------
ALTER TABLE DBMS.dbo.orders
ALTER COLUMN order_status_id INT NULL;
-------------------------------
ALTER TABLE DBMS.dbo.order_status_types
ALTER COLUMN id INT NOT NULL;
-------------------------------
------Checking Values in Table-
SELECT * FROM DBMS.dbo.orders
Where order_status_id Not In (1,2,3,4,5,6,7,8,9)
-------------------------------
ALTER TABLE DBMS.dbo.orders
ADD CONSTRAINT FK_order_status_id_2
FOREIGN KEY (order_status_id) 
REFERENCES DBMS.dbo.order_status_types(id);
--------------------------------
ALTER TABLE DBMS.dbo.orders
ALTER COLUMN order_id nvarchar(255) NOT NULL;
---------------------------------
ALTER TABLE DBMS.dbo.orders
ADD CONSTRAINT PK_123 PRIMARY KEY (order_id);
---------------------------------
SELECT * 
FROM DBMS.dbo.customers;
----------------------------------
SELECT * 
FROM DBMS.dbo.orders;
----------------------------------
/*ALTER TABLE DBMS.dbo.orders
ALTER COLUMN customer_id nvarchar(255) NOT NULL;
-----------------------------------
ALTER TABLE DBMS.dbo.customers
ALTER COLUMN customer_zip_code_prefix int NULL;*/
-----------------------------------
INSERT INTO DBMS.dbo.customers(customer_id)
SELECT customer_id FROM DBMS.dbo.orders
WHERE customer_id Not In (SELECT customer_id FROM DBMS.dbo.customers)
------------------------------------
SELECT customer_id FROM DBMS.dbo.orders
WHERE customer_id Not In (SELECT customer_id FROM DBMS.dbo.customers)
------------------------------------
ALTER TABLE DBMS.dbo.orders
ADD CONSTRAINT FK_customer_id_24_5
FOREIGN KEY (customer_id) 
REFERENCES DBMS.dbo.customers(customer_id);
-------------------------------------
SELECT * FROM DBMS.dbo.customers
--WHERE customer_unique_id is Not Null;
-------------------------------------
-------------------------------------
--Date_Cleaning>>Order_Payments Table.
--------------------------
SELECT * FROM DBMS.dbo.order_payments 
---Cleaning order_id column and make all values without ""
UPDATE DBMS.dbo.order_payments
SET order_id = REPLACE(TRIM('"' FROM order_id ), '"','')
------------------------------
SELECT * 
FROM DBMS.dbo.order_payments
---------------------------
SELECT payment_type
FROM DBMS.dbo.order_payments
GROUP BY payment_type
-->>Creating New_Table payment_types(id,payment_type)>>From Database Mapping.
Create table DBMS.dbo.payment_types(
  id int not null, 
  payment_type varchar(50) null Constraint PK_payment_types primary key clustered(id asc)
)
-->>Inserting Values into payment_types Table.
Insert into DBMS.dbo.payment_types(id, payment_type) 
Values 
  (1, 'credit_card'), 
  (2, 'voucher'), 
  (3, 'boleto'), 
  (4, 'debt_card'), 
  (5, 'not_defined') 
-->>Chicking Data Inserted in Table.
SELECT * 
FROM DBMS.dbo.payment_types;
---------------------------
SELECT * FROM DBMS.dbo.order_payments;
---------------------------
-->>Renaming (payment_type)column to (payment_type_id)column in DBMS.dbo.order_payments.
USE DBMS;
EXEC sp_rename 
    @objname = 'order_payments.payment_type',
    @newname = 'payment_type_id',
    @objtype = 'COLUMN';
--------------------------------------------
-->>Checking The Coulmn is Renamed.
SELECT * FROM DBMS.dbo.order_payments;
--------------------------------------------
-->>Update one By one.
Update DBMS.dbo.order_payments
Set payment_type_id = 1
Where payment_type_id = 'credit_card'
Update DBMS.dbo.order_payments
Set payment_type_id = 2
Where payment_type_id = 'voucher'
Update DBMS.dbo.order_payments
Set payment_type_id = 3
Where payment_type_id = 'boleto'
Update DBMS.dbo.order_payments
Set payment_type_id = 4
Where payment_type_id = 'debit_card'
Update DBMS.dbo.order_payments
Set payment_type_id = 5
Where payment_type_id = 'not_defined'
-------------------------------------
SELECT * FROM DBMS.dbo.order_payments;
-------------------------------------
SELECT * FROM DBMS.dbo.payment_types;
-------------------------------------
ALTER TABLE DBMS.dbo.payment_types
ALTER COLUMN id INT NOT NULL;
-------------------------------------
ALTER TABLE DBMS.dbo.order_payments
ALTER COLUMN payment_type_id INT NULL;
-------------------------------------
ALTER TABLE DBMS.dbo.order_payments
ADD CONSTRAINT FK_payment_type_id_24
FOREIGN KEY (payment_type_id) 
REFERENCES DBMS.dbo.payment_types(id);
--------------------------------------
ALTER TABLE DBMS.dbo.order_payments
ALTER COLUMN order_id nvarchar(255) NOT NULL;
--------------------------------------
/*A duplicate key was found for the object name 'dbo.order_payments'*/
-->>Checking The Duplicate.
SELECT order_id,COUNT(*)
FROM DBMS.dbo.order_payments
GROUP BY order_id
Having COUNT(*) > 1
--------------------------------------
-->>Delete The Duplicates.
WITH DuplicateData AS (
    SELECT order_id,payment_sequential,payment_type_id,payment_installments,payment_value,
           ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id ASC) AS RN
    FROM 
        DBMS.dbo.order_payments
)
DELETE FROM DBMS.dbo.order_payments
WHERE order_id IN (SELECT order_id FROM DuplicateData WHERE RN > 1);
--------------------------------------
SELECT * FROM DBMS.dbo.order_payments;
--------------------------------------
ALTER TABLE DBMS.dbo.order_payments
ADD CONSTRAINT PK_order_id_15_5 PRIMARY KEY (order_id);
--------------------------------------
/*
The ALTER TABLE statement conflicted with 
the FOREIGN KEY constraint "FK_order_id_249".
*/
--------------------------------------
-->>I Have Error<<--
INSERT INTO DBMS.dbo.orders(order_id)
SELECT order_id FROM DBMS.dbo.order_payments
WHERE order_id Not IN (SELECT order_id FROM DBMS.dbo.orders);
--------------------------------------
INSERT INTO DBMS.dbo.order_payments(order_id)
SELECT order_id FROM DBMS.dbo.orders
WHERE order_id Not IN (SELECT order_id FROM DBMS.dbo.order_payments);
--------------------------------------
ALTER TABLE DBMS.dbo.order_payments
ADD CONSTRAINT FK_order_id_249
FOREIGN KEY (order_id) 
REFERENCES DBMS.dbo.orders(order_id);
--------------------------------------
-->>order_payments(order_id)&orders(order_id);
--------------------------
SELECT * FROM DBMS.dbo.order_items
-->>Cleaning order_id column and make all values without ""
UPDATE DBMS.dbo.order_items
SET order_id = REPLACE(TRIM('"'FROM order_id ), '"','');
--------------------------------------------------------
---Checking, is every order has only one Distinct product ?
Select order_id,COUNT(distinct product_id) 
From DBMS.dbo.order_items
Group by order_id 
Having COUNT(distinct product_id) > 1
-------------------------------------
---Summarize the order_items Table and Add (product_counter) column 
---And Insert the returned result into New_Table items.
SELECT * 
FROM DBMS.dbo.order_items;
-------------------------------------
SELECT order_id,seller_id,shipping_limit_date,price,
freight_value,product_id,COUNT(product_id) AS product_counter
INTO DBMS.dbo.items
FROM DBMS.dbo.order_items
GROUP BY order_id,seller_id,shipping_limit_date,price,freight_value,product_id;
--------------------------------------
SELECT * 
FROM DBMS.dbo.items;
-------------------
---Delete DBMS.dbo.orderitems Table from Database.
Drop Table DBMS.dbo.order_items
-->>Chicking The Table<<--
SELECT * FROM DBMS.dbo.items
--------------------
---Checking for (order_id and product_id)>>>Duplicates in items Table.
Select * 
From (Select *,ROW_NUMBER() Over(Partition by order_id,product_id Order by order_id,product_id) as RN
From DBMS.dbo.items) as te
Where RN > 1;
---------------------
SELECT order_id FROM DBMS.dbo.items
Where order_id NOT IN (SELECT order_id FROM DBMS.dbo.orders)
---------------------
INSERT INTO DBMS.dbo.items(order_id)
SELECT order_id FROM DBMS.dbo.orders
Where order_id NOT IN (SELECT order_id FROM DBMS.dbo.items)
---------------------
-->>Checking are there any product_id values in 
-->>in items Table that not exist in products Table. 
SELECT product_id
FROM DBMS.dbo.items
WHERE product_id NOT IN (SELECT product_id FROM DBMS.dbo.products)
---------------------
SELECT product_id
FROM DBMS.dbo.products
WHERE product_id NOT IN (SELECT product_id FROM DBMS.dbo.items)
---------------------
---------------------
INSERT INTO DBMS.dbo.sellers(seller_id)
SELECT seller_id FROM DBMS.dbo.items
WHERE seller_id NOT IN(SELECT seller_id FROM DBMS.dbo.sellers)
---------------------
INSERT INTO DBMS.dbo.items(seller_id)
SELECT seller_id FROM DBMS.dbo.sellers
WHERE seller_id NOT IN(SELECT seller_id FROM DBMS.dbo.items)
----------------------
--ORDERs And Items;
SELECT order_id FROM DBMS.dbo.items
WHERE order_id Not In (SELECT order_id FROM DBMS.dbo.orders);
----------------------
SELECT order_id FROM DBMS.dbo.orders
WHERE order_id Not In (SELECT order_id FROM DBMS.dbo.items);
----------------------
ALTER TABLE DBMS.dbo.items
ADD CONSTRAINT FK_order_id_27
FOREIGN KEY (order_id) 
REFERENCES DBMS.dbo.orders(order_id);
-----------------------
-->>ITEMS And Sellers;
-----------------------
-----------------------
SELECT seller_id FROM DBMS.dbo.items
WHERE seller_id NOT IN (SELECT seller_id FROM DBMS.dbo.sellers)
-----------------------
SELECT seller_id FROM DBMS.dbo.sellers
WHERE seller_id NOT IN (SELECT seller_id FROM DBMS.dbo.items)
-----------------------
--INSERT INTO DBMS.dbo.sellers(seller_id).
SELECT * FROM DBMS.dbo.items
-----------------------
-->>Delete The Duplicated Data.
WITH DuplicateData AS (
    SELECT 
        seller_id,
        ROW_NUMBER() OVER (PARTITION BY seller_id 
		                   ORDER BY seller_id ASC) AS RN
    FROM 
        DBMS.dbo.items
)
DELETE FROM DBMS.dbo.items
WHERE seller_id IN (
    SELECT seller_id
    FROM DuplicateData
    WHERE RN > 1
);
---------------------------
ALTER TABLE DBMS.dbo.items
ADD CONSTRAINT FK_sellers_id_278
FOREIGN KEY (seller_id) 
REFERENCES DBMS.dbo.sellers(seller_id);
-----------------------------
-->>Products(product_ID)PK>>>items(product_ID)FK.
------------------------------
SELECT product_id FROM DBMS.dbo.products
Where product_id Not In (SELECT product_id FROM DBMS.dbo.items);
------------------------------
SELECT product_id FROM DBMS.dbo.items
Where product_id Not In (SELECT product_id FROM DBMS.dbo.products);
------------------------------
------------------------------
ALTER TABLE DBMS.dbo.products
ALTER COLUMN product_id nvarchar(255) NOT NULL;
------------------------------
ALTER TABLE DBMS.dbo.products
ADD CONSTRAINT PK_product_id_16 PRIMARY KEY (product_id);
-------------------------------
ALTER TABLE DBMS.dbo.items
ADD CONSTRAINT FK_product_id_300
FOREIGN KEY (product_id) 
REFERENCES DBMS.dbo.products(product_id);
--------------------------------
-->>Finish IT.
--------------------------------
/*
>>Data Cleaning And INSERT THE DATA FIRST THAN Create FK and PK.
>>FK>>It can be NULL or duplicate.
*/
