# Module Ex-05 - Delta File Maintenance

[< Previous Module](../modules/moduleex04.md) - **[Home](../README.md)**

## :stopwatch: Estimated Duration

20 minutes

## :thinking: Prerequisites

- [x] Lab environment deployed from [setup](../modules/module00.md)
- [x] Completed [Module 06](../modules/module06.md)

## :loudspeaker: Introduction

When ingesting real-time data into the Lakehouse, Delta tables will tend to be spread over many small Parquet files. Having many small files causes the queries to run slower by introducing a large amount of I/O overhead, casually referred to as the "small file problem." This module looks at optimizing Delta tables. 

## Table of Contents

1. [Small File Compaction](#1-small-file-compaction)

## 1. Small File Compaction

With the Eventstream continually writing data to the lakehouse, thousands of files will be generated daily and impact overall performance when running queries. When running notebooks, you may see a warning from the diagnostics engine indicating a table may benefit from small file compaction, a process that combines many small files into larger files.

Delta Lake makes performing small file compaction very easy and can be executed in either Spark SQL, Python, or Scala. The *raw_stock_data* table is the main table that requires routine maintenance, but all tables should be monitored and optimized as needed. To compact small files using Python, create a new notebook and run the following:

```python
from delta.tables import *

raw_stock_data = DeltaTable.forName(spark, "raw_stock_data")
raw_stock_data.optimize().executeCompaction()
```

Note that *forName* or *forPath* can be used, allowing you to specify a table name or path the table. In Spark SQL, the same command can be issued like so:

```sql
OPTIMIZE raw_stock_data
```

You can also run small file compaction ad-hoc by navigating to the lakehouse in your Fabric workspace, and click the ellipsis to the right of the table name and select *Maintenance*. 

A simple notebook for maintenance might look like:

```python
from delta.tables import *

if spark.catalog.tableExists("dim_date"):
    table = DeltaTable.forName(spark, "dim_date")
    table.optimize().executeCompaction()

if spark.catalog.tableExists("dim_symbol"):
    table = DeltaTable.forName(spark, "dim_symbol")
    table.optimize().executeCompaction()

if spark.catalog.tableExists("fact_stocks_daily_prices"):
    table = DeltaTable.forName(spark, "fact_stocks_daily_prices")
    table.optimize().executeCompaction()

if spark.catalog.tableExists("raw_stock_data"):
    table = DeltaTable.forName(spark, "raw_stock_data")
    table.optimize().executeCompaction()
    table.vacuum()
```

The *raw_stock_data* table will take the most time to optimize, and is also the most important to optimize regularly. Also, notice the use of *vacuum*. The *vacuum* command removes files older than the retention period, which is 7 days by default. While removing old files should have little impact on performance (as they are no longer used), they can increase storage costs and potentially impact jobs that might process those files (backups, etc.)

Refer to the Spark job output log (at the bottom of the notebook cell) for information on the optimization. You may want to break out commands into different cells.

To see the files locally, consider using a tool like [OneLake file explorer](https://learn.microsoft.com/en-us/fabric/onelake/onelake-file-explorer). OneLake file explorer allows you to view all tables and files in OneLake.

## :books: Resources

* [Compact Data Files with OPTIMIZE](https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-table-maintenance)
* [Delta Optimization and V-Order](https://learn.microsoft.com/en-us/fabric/data-engineering/delta-optimization-and-v-order?tabs=sparksql)
* [OPTIMIZE Blog Post](https://delta.io/blog/2023-01-25-delta-lake-small-file-compaction-optimize/)
* [OneLake file explorer](https://learn.microsoft.com/en-us/fabric/onelake/onelake-file-explorer)

## :tada: Summary

In this module, you built a simple notebook that optimizes the Delta tables using compaction.

## :white_check_mark: Results

- [x] Created a maintenance notebook