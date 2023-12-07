# Module 05c - Data Warehousing

[< Previous Module](../modules/module05b.md) - **[Home](../README.md)** - [Next Module >](./module05d.md)

## :stopwatch: Estimated Duration

30 minutes

## :thinking: Prerequisites

- [x] Completed [Module 05a](../modules/module05a.md)
- [x] Completed [Module 05b](../modules/module05b.md)

## :loudspeaker: Introduction

With the completion of Module 05a and Module 05b, we are one step closer to finishing our pipeline.

The next step...

## Table of Contents

1. [](#1-download-the-notebook)

## 1. Create the procedure to load daily prices


```sql
CREATE PROCEDURE [ETL].[sp_Fact_Stocks_Daily_Prices_Load]
AS
BEGIN
BEGIN TRANSACTION

    CREATE TABLE [dbo].[fact_StocksDailyPrices_OLD]  
    AS 
    (SELECT * FROM dbo.fact_Stocks_Daily_Prices)

    DROP TABLE [dbo].[fact_Stocks_Daily_Prices]

    CREATE TABLE [dbo].[fact_Stocks_Daily_Prices]
    AS 
    (SELECT
        ROW_NUMBER() Over (ORDER BY ISNULL(newf.Symbol_SK, oldf.Symbol_SK)) as StocksDailyPrice_SK
        ,ISNULL(newf.Symbol_SK, oldf.Symbol_SK) as Symbol_SK
        ,ISNULL(newf.PriceDateKey, oldf.PriceDateKey) as PriceDateKey
        ,MinPrice = CASE 
                        WHEN newf.MinPrice IS NULL THEN oldf.MinPrice
                        WHEN oldf.MinPrice IS NULL THEN newf.MinPrice
                        ELSE CASE WHEN newf.MinPrice < oldf.MinPrice THEN newf.MinPrice ELSE oldf.MinPrice END
                    END
        ,MaxPrice = CASE 
                        WHEN newf.MaxPrice IS NULL THEN oldf.MaxPrice
                        WHEN oldf.MaxPrice IS NULL THEN newf.MaxPrice
                        ELSE CASE WHEN newf.MaxPrice > oldf.MaxPrice THEN newf.MaxPrice ELSE oldf.MaxPrice END
                    END
         ,ClosePrice = CASE 
                        WHEN newf.ClosePrice IS NULL THEN oldf.ClosePrice
                        WHEN oldf.ClosePrice IS NULL THEN newf.ClosePrice
                        ELSE newf.ClosePrice
                    END
    FROM 
        [stg].[vw_StocksDailyPricesEX] newf
    FULL OUTER JOIN
        [dbo].[fact_StocksDailyPrices_OLD] oldf
        ON oldf.Symbol_SK = newf.Symbol_SK
        AND oldf.PriceDateKey = newf.PriceDateKey
    )

    DROP TABLE [dbo].[fact_StocksDailyPrices_OLD]
COMMIT

END
GO
```

## 2. Add activity to the pipeline to load daily stock prices

Add a stored procedure activity to the pipeline named Populate Fact Stocks Daily Prices that loads the stocks prices from staging into the fact table. Connect the success output of the Populate Symbols Dimension to the new Populate Fact Stocks Daily Prices activity.

IMAGE OF PIPELINE AROUND 1444

## 3. Run the pipeline

Run the pipeline and verify the pipeline runs and fact and dimension tables are being loaded. 

IMAGE 1:50

## 4. Schedule the pipeline

Next, schedule the pipeline to run periodically. This will vary by business case, but this could be run frequently (every few minutes) or once or twice per day.

## 5. Create the data model of the stock prices

On our model, we can hide the non-essential tables for reporting, and create relationships between the fact and dimension tables.

Click on the model tab to open the model view. Hide every table except the fact and dimension tables. To create relationships between the fact and dimension tables, drag the key from the fact table to the corresponding key in the dimension table. This should create a 1:many relationship between the two tables, and look similar to the below image.

* Fact:PriceDateKey -> dim_Date:DateKey
* Fact:Symbol_SK -> dim_Symbol:Symbol_SK

IMAGE 201

## 6. Create a simple report



## :thinking: Additional Learning

* [Data Warehousing in Fabric](https://learn.microsoft.com/en-us/fabric/data-warehouse/data-warehousing)


