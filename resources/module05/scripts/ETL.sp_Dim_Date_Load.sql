/*******************************************************/
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