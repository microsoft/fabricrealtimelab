# Module Ex-01 - KQL Queryset Improvements

[< Previous Module](../modules/moduleex00.md) - **[Home](../README.md)** - [Next Module >](./moduleex02.md)

## :stopwatch: Estimated Duration

20 minutes

## :thinking: Prerequisites

- [x] Lab environment deployed from [setup](../modules/module00.md)
- [x] Completed [Module 01](../modules/module01.md)
- [x] Completed [Module 02](../modules/module02.md)
- [x] Completed [Module 03](../modules/module03.md)

## :loudspeaker: Introduction

This module explores additional KQL concepts.

## Table of Contents

1. [Examine the original query](#1-examine-the-original-query)
2. [Using the scan operator](#2-using-the-scan-operator)
3. [Adding bin to the mix](#3-adding-bin-to-the-mix)

## 1. Examine the original query

Recall the original StockByTime query:

```text
StockPrice
| where timestamp > ago(75m)
| project symbol, price, timestamp
| partition by symbol
(
    order by timestamp asc
    | extend prev_price = prev(price, 1)
    | extend prev_price_10min = prev(price, 600)
)
| where timestamp > ago(60m)
| order by timestamp asc, symbol asc
| extend pricedifference_10min = round(price - prev_price_10min, 2)
| extend percentdifference_10min = round(round(price - prev_price_10min, 2) / prev_price_10min, 4)
| order by timestamp asc, symbol asc
```

This query takes advantage of both partitioning and previous functions. The data is partitioned to ensure that the previous function only considers rows matching the same symbol. Experiment running parts of the query to see how they work.

## 2. Using the scan operator

Many of the queries we'd like to use need additional information in the form of aggregations or previous values. In SQL (if you happen to know SQL well), you might recall that aggregations are often done via *group by*, and lookups can be done via a *correlated subquery*. KQL doesn't have correlated subqueries directly, but fortunately can handle this several ways, and the most flexible in this case is using a combination of the [partition statement](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/partitionoperator) and the [scan operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/scan-operator). 

The partition operator, as we've seen, creates subtables based on the specified key, while the scan operator matches records according to specified predicates. While we only need a very simple rule (match the previous row for each symbol), the scan operator can be very powerful as these steps and predicates can be chained. 

Consider the following KQL query, which will give similar results as our previous KQL query:

```text
StockPrice
| where timestamp > ago(60m)
| project timestamp, price, symbol
 ,previousprice = 0.00
 ,pricedifference = 0.00
 ,percentdifference = 0.00
| partition hint.strategy=native by symbol
  (
    order by timestamp asc 
    | scan with (step s: true => previousprice = s.price;)
  )
| project timestamp, symbol, price, previousprice
    ,pricedifference = round((price-previousprice),2)
    ,percentdifference = round((price-previousprice)/previousprice,4)
| order by timestamp asc, symbol asc
```

The top part of the query (before the partition statement) retrieves the last 5 minutes of data, and sets up the three variables (previousprice, pricedifference, and percentdifference). The partition statement creates a subtable for each symbol, and because the subtable is ordered by timestamp, the scan operator only needs a single step (referred to as *s*, but this is arbitrary), matching the most recent price into a variable *previousprice*. We can then project that value with the rest of the data, and calculate the price and percentage change similarly to the original query. While this accomplishes essentially the same thing as a prev(), this can be useful for mining information beyond what a simple windowing function can accomplish.

## 3. Adding bin to the mix

In this step, let's look more closely at a fundamental KQL aggregation statement: [the bin function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/binfunction). The *bin* function allows us to create groups of a given size as specified by the bin parameters. This is especially powerful with *datetime* and *timespan* types, as we can combine this with the *summarize* operator to create broader views of our data. 

For example, our stock data has per-second precision -- useful for our real-time dashboard but too much data for most reports. Suppose we'd like to aggregate this into broader groups, such as days, hours, or even minutes. Further, let's make an assumption that the last price on each day (likely 23:59:59 for our data) will serve as our "closing price." 

To get the closing price for each day, we can build off our previous queries and add a bin, like this:

```text
StockPrice
| summarize arg_max(timestamp,*) by bin(timestamp, 1d), symbol
| project symbol, price, timestamp
,previousprice = 0.00
,pricedifference = 0.00
,percentdifference = 0.00
| partition hint.strategy=native by symbol
  (
    order by timestamp asc 
    | scan with (step s output=all: true => previousprice = s.price;)
  )
| project timestamp, symbol, price, previousprice
    ,pricedifference = round((price-previousprice),2)
    ,percentdifference = round((price-previousprice)/previousprice,4)
| order by timestamp asc, symbol asc
```

This query leverages the *summarize* and *bin* statements to group the data by day and symbol. The result is the closing price for each stock price per day. We can also add min/max/avg prices as needed, and alter the binning time as needed.

## :books: Resources

* [Intro to KQL](https://learn.microsoft.com/en-us/training/modules/write-first-query-kusto-query-language/)
* [Intro to Kusto Scan Operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/scan-operator)
* [KQL prev function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/prevfunction)
* [KQL partition operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/partition-operator) 
* [KQL summarize operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/summarizeoperator)
* [KQL arg_max function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/arg-max-aggregation-function)
* [KQL bin() function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/bin-function)

## :tada: Summary

In this module, you learned about KQL windowing, partition and scan operators, and how to design more resilient queries for real-time data.

## :white_check_mark: Results

- [x] Developed a new KQL query for use in dashboards.

[Continue >](./moduleex02.md)