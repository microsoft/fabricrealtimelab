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

Consider the following KQL query, which will give similar results as our previous KQL query that uses the prev() function:

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

This query is similar in structure to our original query, except instead of using the prev() function to look at the previous row of the partitioned data, the scan operator can scan the previous rows. In this case, it scans the most recent record before the current record, and storing the price as *previousprice*. While this achieves a similar result as using prev(), this can be useful for mining information beyond what a simple windowing function can accomplish, as we'll see in the next example.

## 3. Mining the data with scan

The scan operator may contain any number of steps that scans rows matching the specified predicates. The power comes from the fact that these steps can chain together state learned from previous steps. This allows us to do process mining on the data. 

For example, suppose we'd like to find stock rallies: these occur when there is a continuous increase in the stock price. It could be that the price jumped a high amount over a short period of time, or it might be the price slowly rose over a long period of time. As long as the price keeps increasing, we'd like to examine these rallies. 

Building off the examples above, we first use the prev() function to get the previous stock price. Using the scan operator, the first step (*s1*) looks for an increase from the previous price. This continues as long as the price increases. If the stock decreases, the step *s2* flags the *down* variable, essentially resetting the state and ending the rally:

```text
StockPrice
| project symbol, price, timestamp
| partition by symbol
(
    order by timestamp asc 
    | extend prev_timestamp=prev(timestamp), prev_price=prev(price)
    | extend delta = round(price - prev_price,2)
    | scan with_match_id=m_id declare(down:bool=false, step:string) with 
    (
        // if state of s1 is empty we require price increase, else continue as long as price doesn't decrease 
        step s1: delta >= 0.0 and (delta > 0.0 or isnotnull(s1.delta)) => step = 's1';
        // exit the 'rally' when price decrease, also forcing a single match 
        step s2: delta < 0.0 and s2.down == false => down = true, step = 's2';
    )
)
| where step == 's1' // select only records with price increase
| summarize 
    (start_timestamp, start_price)=arg_min(prev_timestamp, prev_price), 
    (end_timestamp, end_price)=arg_max(timestamp, price),
    run_length=count(), total_delta=round(sum(delta),2) by symbol, m_id
| extend delta_pct = round(total_delta*100.0/start_price,4)
| extend run_duration_s = datetime_diff('second', end_timestamp, start_timestamp)
| summarize arg_max(delta_pct, *) by symbol
| project symbol, start_timestamp, start_price, end_timestamp, end_price,
    total_delta, delta_pct, run_duration_s, run_length
| order by delta_pct
```

This produces a result like so:


The result above looks for the largest percentage gain in a rally, regardless of length. If we'd like to see the largest rally, we can change the summarization:

```text
StockPrice
| project symbol, price, timestamp
| partition by symbol
(
    order by timestamp asc 
    | extend prev_timestamp=prev(timestamp), prev_price=prev(price)
    | extend delta = round(price - prev_price,2)
    | scan with_match_id=m_id declare(down:bool=false, step:string) with 
    (
        // if state of s1 is empty we require price increase, else continue as long as price doesn't decrease 
        step s1: delta >= 0.0 and (delta > 0.0 or isnotnull(s1.delta)) => step = 's1';
        // exit the 'rally' when price decrease, also forcing a single match 
        step s2: delta < 0.0 and s2.down == false => down = true, step = 's2';
    )
)
| where step == 's1' // select only records with price increase
| summarize 
    (start_timestamp, start_price)=arg_min(prev_timestamp, prev_price), 
    (end_timestamp, end_price)=arg_max(timestamp, price),
    run_length=count(), total_delta=round(sum(delta),2) by symbol, m_id
| extend delta_pct = round(total_delta*100.0/start_price,4)
| extend run_duration_s = datetime_diff('second', end_timestamp, start_timestamp)
| summarize arg_max(run_duration_s, *) by symbol
| project symbol, start_timestamp, start_price, end_timestamp, end_price,
    total_delta, delta_pct, run_duration_s, run_length
| order by run_duration_s
```

This example produces a result that shows the longest rallies for each stock, in terms of total seconds:




## 4. Adding bin to the mix

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

## 5. Combining bin and scan

While looking at rallies on a per-second level is great for our short-lived data, it might not be too realistic. We can combine the rally query with the bin to bucketize data into longer periods of time, thus looking for rallies over any interval we'd like. Realistically, this might be on a per-day level, but for the purposes of example, let's look at a per-minute level:

```text
StockPrice
| summarize arg_max(timestamp,*) by bin(timestamp, 1m), symbol
| project symbol, price, timestamp
| partition by symbol
(
    order by timestamp asc 
    | extend prev_timestamp=prev(timestamp), prev_price=prev(price)
    | extend delta = round(price - prev_price,2)
    | scan with_match_id=m_id declare(down:bool=false, step:string) with 
    (
        // if state of s1 is empty we require price increase, else continue as long as price doesn't decrease 
        step s1: delta >= 0.0 and (delta > 0.0 or isnotnull(s1.delta)) => step = 's1';
        // exit the 'rally' when price decrease, also forcing a single match 
        step s2: delta < 0.0 and s2.down == false => down = true, step = 's2';
    )
)
| where step == 's1' // select only records with price increase
| summarize 
    (start_timestamp, start_price)=arg_min(prev_timestamp, prev_price), 
    (end_timestamp, end_price)=arg_max(timestamp, price),
    run_length=count(), total_delta=round(sum(delta),2) by symbol, m_id
| extend delta_pct = round(total_delta*100.0/start_price,4)
| extend run_duration_s = datetime_diff('second', end_timestamp, start_timestamp)
| summarize arg_max(delta_pct, *) by symbol
| project symbol, start_timestamp, start_price, end_timestamp, end_price,
    total_delta, delta_pct, run_duration_s, run_length
| order by delta_pct
```

This produces a result like:

## :books: Resources

* [Intro to KQL](https://learn.microsoft.com/en-us/training/modules/write-first-query-kusto-query-language/)
* [Intro to Kusto Scan Operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/scan-operator)
* [KQL prev function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/prevfunction)
* [KQL partition operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/partition-operator) 
* [KQL summarize operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/summarizeoperator)
* [KQL arg_max function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/arg-max-aggregation-function)
* [KQL bin() function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/bin-function)
* [Process mining with Scan](https://techcommunity.microsoft.com/t5/azure-data-explorer-blog/the-new-scan-operator-process-mining-in-azure-data-explorer/ba-p/2378795)

## :tada: Summary

In this module, you learned about KQL windowing, partition and scan operators, and how they can be used to achieve power data mining results.

## :white_check_mark: Results

- [x] Developed a new KQL query for use in dashboards.

[Continue >](./moduleex02.md)