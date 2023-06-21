SELECT * FROM sales.sales;

SELECT Account FROM sales.sales

-- this is just to double check that account is duplicated in every sale;
-- even if it was not duplicated, it stil logically belongs in a separate entity based on NF3

SELECT Account, COUNT(*) AS count
FROM sales.sales
GROUP BY Account
HAVING COUNT(*) > 1;

-- this retrieves all unique accounts
SELECT DISTINCT Account
FROM sales.sales;


CREATE TABLE sales.accounts(
 Id int NOT NULL AUTO_INCREMENT Primary key,-- creates id primary key number
AccountName VARCHAR(100) NOT NULL);

-- insert from sales table account information to accounts table
INSERT INTO sales.accounts(AccountName)
SELECT DISTINCT Account
FROM sales.sales;

ALTER TABLE sales.sales
ADD COLUMN AccountId int;

-- we are not using an index on Account Name in either sales or accounts table, for this reason DB complains
-- as such opeartions are very slow and inefficient on large tables; since our table is very small, we just tell 
-- the database to do it anyways be switching safe mode off (and remembering to switch it back on afterwards).
-- if the table was very large we would have to create indexes on sales.sales.Account and sales.accounts.AccountName 
-- and it would just work (but thats extra effort ans we are lazy)
SET SQL_SAFE_UPDATES = 0;
UPDATE sales.sales
SET AccountId = (SELECT Id from sales.accounts WHERE sales.accounts.AccountName = sales.sales.Account); 
SET SQL_SAFE_UPDATES = 1;


ALTER TABLE sales.sales
DROP COLUMN Account;

ALTER TABLE sales.sales
ADD FOREIGN KEY (AccountId) REFERENCES sales.accounts(Id);  

-- Script for Region

CREATE TABLE sales.regions(
 Id int NOT NULL AUTO_INCREMENT Primary key,
RegionName VARCHAR(100) NOT NULL);


INSERT INTO sales.regions(RegionName)
SELECT DISTINCT Region
FROM sales.sales;

ALTER TABLE sales.sales
ADD COLUMN RegionId int;

SET SQL_SAFE_UPDATES = 0;
UPDATE sales.sales
SET RegionId = (SELECT Id from sales.regions WHERE sales.regions.RegionName = sales.sales.Region); 
SET SQL_SAFE_UPDATES = 1;


ALTER TABLE sales.sales
DROP COLUMN Region;

ALTER TABLE sales.sales
ADD FOREIGN KEY (RegionId) REFERENCES sales.regions(Id);  


-- Sector Script

CREATE TABLE sales.sectors(
 Id int NOT NULL AUTO_INCREMENT Primary key,
SectorName VARCHAR(100) NOT NULL);

INSERT INTO sales.sectors(SectorName)
SELECT DISTINCT Sector
FROM sales.sales;

ALTER TABLE sales.sales
ADD COLUMN SectorId int;


SET SQL_SAFE_UPDATES = 0;
UPDATE sales.sales
SET SectorId = (SELECT Id from sales.sectors WHERE sales.sectors.SectorName = sales.sales.Sector); 
SET SQL_SAFE_UPDATES = 1;


ALTER TABLE sales.sales
DROP COLUMN Sector;

ALTER TABLE sales.sales
ADD FOREIGN KEY (SectorId) REFERENCES sales.sectors(Id);   


-- item Script

CREATE TABLE sales.items(
 Id int NOT NULL AUTO_INCREMENT Primary key,
ItemName VARCHAR(100) NOT NULL);

INSERT INTO sales.items(ItemName)
SELECT DISTINCT Item
FROM sales.sales;

ALTER TABLE sales.sales
ADD COLUMN ItemId int;


SET SQL_SAFE_UPDATES = 0;
UPDATE sales.sales
SET ItemId = (SELECT Id from sales.items WHERE sales.items.ItemName = sales.sales.Item); 
SET SQL_SAFE_UPDATES = 1;


ALTER TABLE sales.sales
DROP COLUMN Item;

ALTER TABLE sales.sales
ADD FOREIGN KEY (ItemId) REFERENCES sales.items(Id); 

use sales;

SELECT * FROM sales;
SELECT * FROM accounts;
SELECT * FROM regions;
SELECT * FROM sectors;


SELECT sales.`Sales ID`, sales.Date, accounts.AccountName, regions.RegionName, sectors.SectorName, sales.Units
FROM sales 
INNER JOIN accounts ON sales.AccountId = accounts.Id
INNER JOIN regions ON sales.RegionId = regions.Id
INNER JOIN sectors ON sales.SectorId = sectors.Id
WHERE regions.RegionName = 'London'
AND sales.Units >= 300
AND sales.Units < 2000
ORDER BY sales.Units DESC
LIMIT 10;


SELECT sales.`Sales ID`, sales.Date, accounts.AccountName, regions.RegionName, sectors.SectorName, SUM(sales.Units) AS total_quantity
FROM sales 
INNER JOIN accounts ON sales.AccountId = accounts.Id
INNER JOIN regions ON sales.RegionId = regions.Id
INNER JOIN sectors ON sales.SectorId = sectors.Id
GROUP BY sales.`Sales ID`, sales.Date, accounts.AccountName, regions.RegionName, sectors.SectorName
ORDER BY total_quantity DESC
LIMIT 10;

SELECT sectors.SectorName, regions.RegionName, SUM(sales.Units) AS total_quantity
FROM sales
INNER JOIN sectors ON sales.SectorId = sectors.Id
INNER JOIN regions ON sales.RegionId = regions.Id
GROUP BY sales.SectorId, sales.RegionId
ORDER BY total_quantity DESC
LIMIT 10;

-- FIND DATE THAT HAD MOST SALES
-- THEN FIND THE SECTOR

SELECT sectors.SectorName, SUM(sales.units) AS total_sales
FROM sales
INNER JOIN sectors ON sales.SectorId = sectors.Id
WHERE sales.Date = (
    SELECT sales.Date
    FROM sales
    GROUP BY sales.Date
    ORDER BY SUM(sales.units) DESC
    LIMIT 1
)
GROUP BY sectors.SectorName
ORDER BY total_sales DESC
LIMIT 5;



SELECT sales.Date, SUM(sales.Units) AS total_quantity
FROM sales
GROUP BY sales.Date
ORDER BY total_quantity DESC
LIMIT 5;

SELECT sectors.SectorName, SUM(sales.Units) AS total_quantity
    FROM sales
    INNER JOIN sectors ON sales.SectorId = sectors.Id
    GROUP BY sectors.SectorName
    ORDER BY total_quantity DESC
    LIMIT 5;

            

SELECT dateWithMostSales.Date, sectorWithMostSales.SectorName, sectorWithMostSales.total_quantity AS sector_total_quantity
FROM
  (SELECT sales.Date, SUM(sales.Units) AS total_quantity
    FROM sales
    GROUP BY sales.Date
    ORDER BY total_quantity DESC
    LIMIT 1) AS dateWithMostSales
CROSS JOIN
  (SELECT sectors.SectorName, SUM(sales.Units) AS total_quantity
    FROM sales
    INNER JOIN sectors ON sales.SectorId = sectors.Id
    GROUP BY sectors.SectorName
    ORDER BY total_quantity DESC
    LIMIT 5) AS sectorWithMostSales;
    
SELECT 
    AccountName, Units, Date, 'Quarter 1 2022 Total Sales' AS type
FROM sales
INNER JOIN accounts ON sales.AccountId = accounts.Id
WHERE Date BETWEEN '2022-01-01' AND '2022-03-31'
UNION 
SELECT AccountId, Units, Date, 'Quarter 2 2022 Total Sales' AS type
FROM sales
WHERE Date BETWEEN '2022-04-01' AND '2022-06-30'
UNION
SELECT AccountId, Units, Date, 'Quarter 3 2022 Total Sales' AS type
FROM sales
WHERE Date BETWEEN '2022-07-01' AND '2022-09-30';

    
    
