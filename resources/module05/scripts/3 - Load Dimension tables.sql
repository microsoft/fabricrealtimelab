/* 3 - Load Dimension tables.sql */

CREATE PROC [ETL].[sp_Dim_Date_Load]
@BeginDate DATE  = NULL
,@EndDate DATE = NULL
AS
BEGIN
SELECT @BeginDate  = ISNULL(@BeginDate, DATEADD(DAY, 1, EOMONTH(GETDATE(), -2)))
SELECT @EndDate = ISNULL(@EndDate,EOMONTH(GETDATE(), 2))
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
/**************************************/
CREATE PROC [ETL].[sp_Dim_Symbol_Load]
AS
BEGIN

DECLARE @MaxSK INT = (SELECT ISNULL(MAX(Symbol_SK),0) FROM [dbo].[dim_Symbol])

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
                    WHEN 'I' THEN 'NYSE'
                    WHEN 'T' THEN 'NYSE'
                    ELSE 'No Market'
                END
    FROM 
        [stg].[vw_StocksDailyPrices] sdp
    WHERE 
        sdp.Symbol NOT IN (SELECT Symbol FROM [dbo].[dim_Symbol])
    ) stg

END
GO
/**************************************/
EXEC ETL.sp_Dim_Date_Load