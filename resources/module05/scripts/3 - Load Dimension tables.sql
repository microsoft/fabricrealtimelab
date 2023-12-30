/* 3 - Load Dimension tables.sql */

CREATE PROC [ETL].[sp_Dim_Date_Load]
@BeginDate DATE = NULL
,@EndDate DATE = NULL
AS
BEGIN

SET @BeginDate = ISNULL(@BeginDate, '2022-01-01')
SET @EndDate = ISNULL(@EndDate, DATEADD(year, 2, GETDATE()))

DECLARE @N AS INT = 0
DECLARE @NumberOfDates INT = DATEDIFF(day,@BeginDate, @EndDate)
DECLARE @SQL AS NVARCHAR(MAX)
DECLARE @STR AS VARCHAR(MAX) = ''

WHILE @N <= @NumberOfDates
    BEGIN
    SET @STR = @STR + CAST(DATEADD(day,@N,@BeginDate) AS VARCHAR(10)) 
    
    IF @N < @NumberOfDates
        BEGIN
            SET @STR = @STR + ','
        END

    SET @N = @N + 1;
    END

SET @SQL = 'INSERT INTO dbo.dim_Date ([DateKey]) SELECT CAST([value] AS DATE) FROM STRING_SPLIT(@STR, '','')';

EXEC sys.sp_executesql @SQL, N'@STR NVARCHAR(MAX)', @STR;

UPDATE dbo.dim_Date
SET 
    [DayOfMonth] = DATEPART(day,DateKey)
    ,[DayOfWeeK] = DATEPART(dw,DateKey)
    ,[DayOfWeekName] = DATENAME(weekday, DateKey)
    ,[Year] = DATEPART(yyyy,DateKey)
    ,[Month] = DATEPART(month,DateKey)
    ,[MonthName] = DATENAME(month, DateKey)
    ,[Quarter] = DATEPART(quarter,DateKey)
    ,[QuarterName] = CONCAT('Q',DATEPART(quarter,DateKey))

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