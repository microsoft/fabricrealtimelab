# Module 07c - Data Science: Solution in practice

[< Previous Module](./modules/module07b.md) - **[Home](../README.md)** - [Next Module >](./module10.md)

## :stopwatch: Estimated Duration

* 30 minutes for 07c
* 2 hours overall

## :thinking: Prerequisites

- [x] Completed Module 07a
- [x] Completed Module 07b

This module is broken down into 3 sections:
* [Module 07a - Building and storing an ML model](./module07a.md)
* [Module 07b - Using models, saving to the lakehouse, building a report](./module07b.md)
* [Module 07c - Solution in practice](./module07c.md)

## :loudspeaker: Introduction

The first two sections in this module approach data science in a traditional approach. The first section covered the development of the model (exploration, feature engineering, tuning, etc.), building, and then deploying the model. The second section covered the consumption of the model -- essentially, operationlizing the model, which is typically a separate process and may even be done by different teams.

However, in this specific scenario, there is little benefit to creating the model and generating predictions separately. This is because the model we developed is time-based univariate: the predictions the model generates, for a specific time, will not change without retraining the model. 

Most ML models are multivariate: for example, consider a travel time estimator that calculates travel time between two locations. Such a model could have dozens of input variables, but two major variables would certainly include the time of day and weather conditions. Because the weather is changing frequently, we'd pass this data into the model to generate new travel time predicitions (inputs: time of day and weather, output: travel time).

In this case, we should generate our predictions immediately after creating the model; if we want to generate new predictions, we should consider retraining the ML model with the latest available data for improved accuracy. For practical purposes, then, this section shows how we could implement the ML model building and forecasting in a single step. Of course, we could have a separate process for each stock -- but for simplicity, all of the stocks will share the same basic model parameters. (And, in theory, we could store and retrieve model parameters in MLflow.)

## Table of Contents

1. [Methods to retrain](#1-methods-to-retrain)
2. [Open and explore the notebook](#2-open-and-explore-the-notebook)
3. [Run the notebook](#3-run-the-notebook)
4. [Examine the results](#4-examine-the-results)
5. [Additional challenges](#5-additional-challenges)

## 1. Methods to retrain

Recently, Prophet incorporated the ability to warm-start the model generation. Read the [Updating Fitted Models section](https://facebook.github.io/prophet/docs/additional_topics.html) of this document for information on how this works. 

The benefit of this approach is time: the model can be loaded (as we've done in the first two sections of this module), and the model is then refit with all the data currently available. Refitting the model in this way is faster than fitting the model from scratch. When testing this approach, this yields about a 60% time savings on the default spark cluster (about 3 minutes to ~1.4 minutes). 

While this sounds promising, there are several drawbacks to warm-starting, and this method is fairly complex to orchestrate. Because Prophet is able to train a model very quickly (indeed, 3 minutes is not long as model training goes), we're better off training the model from scratch than attempting to warm-start.

In this section, we'll rework both the first two notebooks into one simple process, which can be easily scheduled to be run as frequently as needed.

## 2. Open and explore the notebook

Open the DS 3 - Build and Predict notebook. For reference, the three notebooks used throughout this module are listed below. More details on importing these are in module 07a.

* [Download the DS 1 - Build Model Notebook](<../resources/module07/DS 1 - Build Model.ipynb>)
* [Download the DS 2 - Predict Stock Prices Notebook](<../resources/module07/DS 2 - Predict Stock Prices.ipynb>)
* [Download the DS 3 - Build and Predict Notebook](<../resources/module07/DS 3 - Build and Predict.ipynb>)

Take some time exploring the notebook, and notice a few key things:

* There is no logging to or using MLflow. Data scientists can still use MLflow for developing models, logging metrics, and collaborating. 
* The ML models are built, then predicitions are made immediately and saved to the predictions table. There is no persistence of the model.
* There is no cross validation or other steps performed in 07a. While these steps are useful for the data scientist, it's not needed here.

## 3. Run the notebook

Run this notebook either entirely or step-by-step. You may wish to alter the way symbols are loaded to reduce run time. The *get_symbols* method in the notebook has 3 options for how symbols are loaded:

* They can be hard-coded in an array, specifying the symbol or symbols. For example, to manually specify all symbols, we can use the following code:

```python
symbol_df = spark.createDataFrame( \
    [['BCUZ'], ['IDGD'], ['IDK'], ['TDY'], ['TMRW'], ['WHAT'], ['WHO'], ['WHY']],['Symbol'])
```

This creates a dataframe that looks like so:

|Symbol|
|------|
|BCUZ|
|IDGD|
|IDK|
|TDY|
|TMRW|
|WHAT|
|WHO|
|WHY|

To limit the processing to only the *WHO* stock, we can create the dataframe like this:

```python
symbol_df = spark.createDataFrame( \
    [['WHO']],['Symbol'])
```

Finally, if want to dynamically select all the symbols in the dataset, we can grab all of the distinct symbols from the data:

```python
# df contains all of the stock data
if not df.rdd.isEmpty():
    symbol_df = df.select('symbol').distinct().sort('symbol')
```

If you are running this in a time constrained lab environment, you may wish to specify one or two stocks to save time. Running the entire notebook across all symbols will take about 25 minutes.

## 4. Examine the results

Use the last cell of the notebook (frozen by default) to query the stock predictions table to verify results are being written to the table. If you reload the report created in the previous section, you should see considerably more data in the reports.

## 5. Additional Challenges

This notebook can be scheduled as needed (perhaps once per evening or weekly). Also, instead of loading data from the CSV files, the data should be loaded from the raw_stock_data table. 

For even more, if you completed the Lakehouse module, check out the [Predicition vs Actual Reporting](../modules/module10c.md) bonus module.

## :tada: Summary

In this module, we further refined the process to build a model and generate predictions in a single step.

## :white_check_mark: Results

- [x] Loaded a notebook into your Fabric environment that focuses on building an ML model and generating predictions.

