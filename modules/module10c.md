# Module 010c - Predicted vs Actual Reporting

[< Previous Module](../modules/module10b.md) - **[Home](../README.md)** 

## :stopwatch: Estimated Duration

30 minutes

## :thinking: Prerequisites

- [x] Lab environment deployed from [setup](../modules/module00.md)
- [x] Completed [Module 01](../modules/module01.md)
- [x] Completed [Module 02](../modules/module02.md)
- [x] Completed [Module 03](../modules/module03.md)
- [x] Completed [Module 06 - Data Lakehouse](../modules/module06.md)
- [x] Completed [Module 07 - Data Science](../modules/module07a.md)

## :loudspeaker: Introduction

In this module, you'll create a simple report that shows actual vs predicted values for diagnostic purposes. To do so, we'll leverage the lakehouse and predicitions table, while also creating a semantic model to take advantage of query caching and creating views in the lakehouse.

## Table of Contents

1. [](#1-)
1. [](#1-)
1. [](#1-)
1. [](#1-)


## 1. Mashing up the data

Creating a visual report that shows predicted vs actual is a bit more tricky than it might first appear. While the predicitions table has all of the predicitions made to date, the actual data exists in these two places:

* (Bronze) raw_stocks_data: the raw, per second feed of every stock symbol
* (Gold) fact_stocks_daily_prices: a daily look at the high/low/close prices

The problem with the fact table, despite being highly curated data, is that tha data is a little *too curated* to evaluate the model performance, as it only contains summarized daily data. The raw_stocks_data is *not curated enough* -- containing data points for every second is too much data. 

There are two ways to accomplish this task. One method is to build additional curated tables that store the data at the needed depth. This is an ideal approach, and indeed, is one of the reasons medallion architecture is so popular: it offers the flexibility to model the data in many different ways to suit changing busines requirements. 

```mermaid
flowchart LR
    A[Event Hub] --> B{EventStream}
    B --> C[(Bronze (raw))]
    C --> D[(Silver (curated))]
    D --> E[(Gold (modeled))]
```


Another way to tackle this problem is to leverage 





```sql
CREATE VIEW [dbo].[vwPredictionsWithActual] AS
(
select sp.symbol, yhat, predict_time, avg(raw.price) as avgprice, 
min(raw.price) as minprice, max(raw.price) as maxprice
from stock_predictions sp
inner join raw_stock_data raw
on cast(sp.predict_time as date) = cast(raw.timestamp as date)
    and DATEPART(hh, raw.timestamp) = DATEPART(hh, sp.predict_time)
    and DATEPART(n, raw.timestamp) = DATEPART(n, sp.predict_time)
    and sp.symbol = raw.symbol
-- where sp.predict_time >= '2023-12-01' and sp.predict_time < '2023-12-01 04:00:00'
-- and raw.timestamp >= '2023-12-01' and raw.timestamp < '2023-12-01 04:00:00'
group by sp.symbol, yhat, predict_time
)
GO
```

## :books: Resources

* [Intro to KQL](https://learn.microsoft.com/en-us/training/modules/write-first-query-kusto-query-language/)
* [Intro to Kusto Scan Operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/scan-operator)
* [KQL Partition](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/partitionoperator)

## :tada: Summary

In this module, you learned about KQL windowing, partition and scan operators, and how to design more resilient queries for real-time data.

## :white_check_mark: Results

- [x] Developed a new KQL query for use in dashboards.
