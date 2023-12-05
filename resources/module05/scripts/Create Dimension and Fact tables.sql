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
