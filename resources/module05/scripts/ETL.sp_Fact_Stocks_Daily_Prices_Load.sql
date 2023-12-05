
/*******************************************************/
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