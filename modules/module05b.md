# Module 05b - Data Warehousing

[< Previous Module](../modules/module05a.md) - **[Home](../README.md)** - [Next Module >](./module05c.md)

## :stopwatch: Estimated Duration

30 minutes

## :thinking: Prerequisites

- [x] Completed [Module 05a](../modules/module05.md)

## :loudspeaker: Introduction

With the completion of Module 05a, we have the plumbing in place to ingest data from the KQL database into our data warehouse. The next step is to prep the dimension tables.



## Table of Contents

1. [](#1-download-the-notebook)

## 1. Create the dimension and fact tables

In our data warehouse, run the following SQL to create our fact and dimension tables. As in the previous step, you can run this ad-hoc or create a SQL query to save the query for future use.

```sql
-- Dimensions and Facts (dbo)
CREATE TABLE dbo.fact_Stocks_Daily_Prices
(
   StocksDailyPrice_SK INT NOT NULL
   ,Symbol_SK INT NOT NULL
   ,PriceDateKey DATE NOT NULL
   ,MinPrice FLOAT NOT NULL
   ,MaxPrice FLOAT NOT NULL
   ,ClosePrice FLOAT NOT NULL
)
GO

CREATE TABLE dbo.dim_Symbol
(
    Symbol_SK INT NOT NULL
    ,Symbol VARCHAR(5) NOT NULL
    ,Name VARCHAR(25)
    ,Market VARCHAR(15)
)
GO

CREATE TABLE dbo.dim_Date
(
    DateKey DATE NOT NULL
    ,DayOfMonth VARCHAR(2)
    ,MonthName VARCHAR(20)
    ,Year VARCHAR(4)    
)
GO
```

## 2. Load the date dimension



```sql
CREATE PROC [ETL].[sp_Dim_Date_Load]
@BeginDate DATE  = NULL
,@EndDate DATE = NULL
AS
BEGIN
SELECT @BeginDate  = ISNULL(@BeginDate, DATEADD ( DAY , 1 , EOMONTH ( GETDATE ( ) , - 2 ) ))
SELECT @EndDate = ISNULL(@EndDate,EOMONTH ( GETDATE ( ) , 1 ))
DECLARE @NumberOfDates INT = Datediff(day,@BeginDate, @EndDate)
--select @NumberOfDates

WHILE @NumberOfDates > 0 
BEGIN
    INSERT INTO [dbo].[dim_Date]
    SELECT DateKey
    ,Datepart(dd,DateKey) as DayOfMonth
    ,FORMAT(DateKey, 'MMMM') as MonthName
    ,Year(DateKey) as [Year]
    FROM 
    (SELECT DateKey = dateadd(d,@NumberOfDates, @BeginDate)
    ) Dates

    SET @NumberOfDates = @NumberOfDates - 1
END
END
GO
```

From a new query window, load the date dimension table by running the following script:

```sql
Exec ETL.sp_Dim_Date_Load
```

## 3. Create the symbol dimension procedure

Create the procedure that will load the stock symbol dimension:

```sql
CREATE PROC [ETL].[sp_Dim_Symbol_Load]
AS
BEGIN

DECLARE @MaxSK INT = (SELECT ISNULL(MAX(Symbol_SK),0) + 1 FROM [dbo].[dim_Symbol])

INSERT [dbo].[dim_Symbol]
SELECT  
    Symbol_SK = @MaxSK + ROW_NUMBER() OVER(ORDER BY Symbol)  
    , Symbol
    , Name
    ,Market
FROM 
    (SELECT DISTINCT
    sdp.Symbol 
    , Name  = 'Stock ' + sdp.Symbol 
    , Market = CASE SUBSTRING(Symbol,1,1)
                    WHEN 'B' THEN 'NASDAQ'
                    WHEN 'W' THEN 'NASDAQ'
                    WHEN 'I' THEN 'DOJ'
                    WHEN 'T' THEN 'SP500'
                    ELSE 'No Market'
                END
    FROM 
        [stg].[vw_StocksDailyPrices] sdp
    WHERE 
        sdp.Symbol NOT IN (SELECT Symbol FROM [dbo].[dim_Symbol])
    ) stg

END
GO
```

## 4. Create the views

Create the views:

```sql
CREATE VIEW [stg].[vw_StocksDailyPrices] 
AS 
SELECT 
    Symbol = symbol
    ,PriceDate = datestamp
    ,MIN(price) as MinPrice
    ,MAX(price) as MaxPrice
    ,(SELECT TOP 1 price FROM [stg].[StocksPrices] sub
    WHERE sub.symbol = prices.symbol and sub.datestamp = prices.datestamp
    ORDER BY sub.timestamp DESC
    ) as ClosePrice
FROM 
    [stg].[StocksPrices] prices
GROUP BY
    symbol, datestamp
GO
/**************************************/
CREATE VIEW stg.vw_StocksDailyPricesEX
AS
SELECT
    ds.[Symbol_SK]
    ,dd.DateKey as PriceDateKey
    ,MinPrice
    ,MaxPrice
    ,ClosePrice
FROM 
    [stg].[vw_StocksDailyPrices] sdp
INNER JOIN [dbo].[dim_Date] dd
    ON dd.DateKey = sdp.PriceDate
INNER JOIN [dbo].[dim_Symbol] ds
    ON ds.Symbol = sdp.Symbol
GO
```

## 5. Add a new activity to the pipeline to load symbols

In the pipeline, add a new Stored Procedure activity that executes the procedure that loads the stock symbols.
* Name: Populate Symbols Dimension
* Settings: 
 * Stored procedure name: ETL.sp_Dim_Symbol_Load.sql

IMAGE OF SYMBOLS IN PIPELINE 1:30



## :thinking: Additional Learning

* [Data Warehousing in Fabric](https://learn.microsoft.com/en-us/fabric/data-warehouse/data-warehousing)


