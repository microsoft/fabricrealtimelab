/* 5 - ETL.sp_Fact_Stocks_Daily_Prices_Load.sql */

CREATE PROCEDURE [ETL].[sp_Fact_Stocks_Daily_Prices_Load]
AS
BEGIN
BEGIN TRANSACTION

    UPDATE fact
    SET 
        fact.MinPrice = CASE 
                        WHEN fact.MinPrice IS NULL THEN stage.MinPrice
                        ELSE CASE WHEN fact.MinPrice < stage.MinPrice THEN fact.MinPrice ELSE stage.MinPrice END
                    END
        ,fact.MaxPrice = CASE 
                        WHEN fact.MaxPrice IS NULL THEN stage.MaxPrice
                        ELSE CASE WHEN fact.MaxPrice > stage.MaxPrice THEN fact.MaxPrice ELSE stage.MaxPrice END
                    END
        ,fact.ClosePrice = CASE 
                        WHEN fact.ClosePrice IS NULL THEN stage.ClosePrice
                        WHEN stage.ClosePrice IS NULL THEN fact.ClosePrice
                        ELSE stage.ClosePrice
                    END 
    FROM [dbo].[fact_Stocks_Daily_Prices] fact  
    INNER JOIN [stg].[vw_StocksDailyPricesEX] stage
        ON fact.PriceDateKey = stage.PriceDateKey
        AND fact.Symbol_SK = stage.Symbol_SK

    INSERT INTO [dbo].[fact_Stocks_Daily_Prices]  
        (Symbol_SK, PriceDateKey, MinPrice, MaxPrice, ClosePrice)
    SELECT
        Symbol_SK, PriceDateKey, MinPrice, MaxPrice, ClosePrice
    FROM 
        [stg].[vw_StocksDailyPricesEX] stage
    WHERE NOT EXISTS (
        SELECT * FROM [dbo].[fact_Stocks_Daily_Prices] fact
        WHERE fact.PriceDateKey = stage.PriceDateKey
            AND fact.Symbol_SK = stage.Symbol_SK
    )

COMMIT

END
GO