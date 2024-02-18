# Module 02 - Exploring the Data

[< Previous Module](./module01.md) - **[Home](../README.md)** - [Next Module >](./module03.md)

## :stopwatch: Estimated Duration

20 minutes

## :thinking: Prerequisites

- [x] Lab environment deployed from [setup](../modules/module00.md)
- [x] Completed [Module 01](../modules/module01.md)

## :loudspeaker: Introduction

Now that our data is streaming into our KQL database, we can begin to query and explore the data, leveraging KQL to gain insights into the data. A KQL Queryset is used to run queries, view, and transform data from a KQL database. Like other artifacts, a KQL Queryset exists within the context of a workspace. A queryset can contain multiple queries, each stored in a tab.

In this module, we'll create several KQL queries of increasing complexity to support different business uses.

Prefer video content? These videos illustrate the content in this module:
* [Getting Started with Real-time Analytics in Microsoft Fabric](https://youtu.be/wGox1lf0ve0)

## Table of Contents

1. [Create KQL Queryset: StockQueryset](#1-create-kql-queryset-stockqueryset)
2. [New Query: StockByTime](#2-new-query-stockbytime)
3. [New Query: StockAggregate](#3-new-query-stockaggregate)
4. [New Query: StockBinned](#4-new-query-stockbinned)

## 1. Create KQL Queryset: StockQueryset

A KQL Queryset is used to run queries, view, and transform data from a KQL database. Like other artifacts, a KQL Queryset exists within the context of a workspace.

From your workspace, click *New* > *KQL Queryset*, and enter *StockQueryset* as the name. Select the *StockDB* from the list of available databases. The KQL query window will open, allowing us to query the data.

![KQL Queryset](../images/module02/kqlqueryset-create.png)

The default query code will look similar to the code below, and contains 3 distinct KQL queries. You may see *YOUR_TABLE_HERE* instead of the *StockPrice* table -- to try this query, replace the table name if necessary. We'll also add a semicolon at the end of each statement; this allows us to run multiple queries in one request:

```text
// Use "take" to view a sample number of records in the table and check the data.
StockPrice
| take 100;

// See how many records are in the table.
StockPrice
| count;

// This query returns the number of ingestions per hour in the given table.
StockPrice
| summarize IngestionCount = count() by bin(ingestion_time(), 1h);
```

To run a single query when there are multiple queries in the editor, you can highlight the query text or place your cursor so the cursor is in the context of the query (for example, at the beginning or end of the query) -- the current query should highlight in blue. To run the query, click *Run* in the toolbar. If you'd like to run all 3 to display the results in 3 different tables, each query will need to have a semicolon (;) after the statement, as shown below. Select all of the text, and click *Run*:  

![KQL Queryset](../images/module02/kqlqueryset-runmultiple.png)

## 2. New Query: StockByTime

Create a new tab within the queryset by clicking the *+* icon near the top of the window. Rename this tab to *StockByTime*.

![KQL Queryset](../images/module02/kqlqueryset-newtab.png)

We can begin to add our own calculations, such as calculating the change over time. For example, the [prev()](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/prevfunction) function, a type of windowing function, allows us to look at values from previous rows; we can use this to calculate the change in price. In addition, because the previous price values are stock symbol specific, we can [partition](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/partition-operator) the data when making calculations.

Try the following query and observe the results.

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

In this KQL query, the results are first limited to the most recent 75 minutes. While we ultimately limit the rows to the last 60 minutes, our initial dataset needs enough data to lookup previous values. The data is then partitioned to group the data by symbol, and we look at the previous price (from 1 second ago) as well as the previous price from 10 minutes ago. Note that this query assumes data is generated at 1 second intervals. For the purposes of our data, subtle fluctuations are acceptable. However, if you need precision in these calculations (such as exactly 10 minutes ago and not 9:59 or 10:01), you'd need to approach this differently.

> :bulb: **Are some columns empty?**
> If you're a fast user, you might get to this query before enough data has been collected to calculate 10 minute averages. As you scroll through the query, you should see more data being populated once enough data has been collected.

## 3. New Query: StockAggregate

Create another new tab within the queryset by clicking the *+* icon near the top of the window. Rename this tab to *StockAggregate*.

This query will find the biggest price gains over a 10 minute period for each stock, and the time it occurred. This query uses the [summarize](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/summarizeoperator) operator, which produces a table that aggregates the input table into groups based on the specified parameters (in this case, *symbol*), while [arg_max](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/arg-max-aggregation-function) returns the greatest value.

If you just started the lab, consider rerunning this query later to observe the changes. 

```text
StockPrice
| project symbol, price, timestamp
| partition by symbol
(
    order by timestamp asc
    | extend prev_price = prev(price, 1)
    | extend prev_price_10min = prev(price, 600)
)
| order by timestamp asc, symbol asc
| extend pricedifference_10min = round(price - prev_price_10min, 2)
| extend percentdifference_10min = round(round(price - prev_price_10min, 2) / prev_price_10min, 4)
| order by timestamp asc, symbol asc
| summarize arg_max(pricedifference_10min, *) by symbol
```

## 4. New Query: StockBinned

Create another new tab within the queryset by clicking the *+* icon near the top of the window. Rename this tab to *StockBinned*.

KQL also has a [bin() function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/bin-function), which can be used to bucket results based on the bin parameter -- in this case, by specifying a timestamp of 1 hour, the result is aggregated for each hour. The time period can be set to minute, hour, day, and so on. 

```text
StockPrice
| summarize avg(price), min(price), max(price) by bin(timestamp, 1h), symbol
| sort by timestamp asc, symbol asc
```

This is particularly useful when creating reports that aggregate real-time data over a longer time period.

## :thinking: Tips

* Too much data? Consider adding a row limit filter, like 'take 1000', to limit the number of rows returned. Be sure to always limit to 500,000 rows if querying a large dataset, as that is the max rowcount for a KQL query.

## :thinking: Additional Learning

* [KQL prev function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/prevfunction)
* [KQL partition operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/partition-operator) 
* [KQL summarize operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/summarizeoperator)
* [KQL arg_max function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/arg-max-aggregation-function)
* [KQL bin() function](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/bin-function)
* [MS Learn: Query data in a KQL queryset](https://learn.microsoft.com/en-us/fabric/real-time-analytics/kusto-query-set)

Interested in going deeper with KQL? We will explore concepts in [the Extras](../modules/moduleex00.md) content. 

## :tada: Summary

In this exercise, you created several KQL queries to explore the data. Moreover, these queries will serve as filters and transformations of the data to feed into the reports we will create in the next module.

## :white_check_mark: Results

- [x] Queried the data using KQL

[Continue >](./module03.md)
