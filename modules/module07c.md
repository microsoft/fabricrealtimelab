# Module 07c - Data Science: Solution in practice

[< Previous Module](./modules/module07b.md) - **[Home](../README.md)** - [Next Module >](./module10.md)

## :stopwatch: Estimated Duration

* 30 minutes for 07c
* 2 hours overall

## :thinking: Prerequisites

- [x] Completed Module 07a
- [x] Completed Module 07b

This module is broken down into 3 sections:
* [Module 07a - Building and storing an ML model](./module07b.md)
* [Module 07b - Using models, saving to the lakehouse, building a report](./module07b.md)
* [Module 07c - Solution in practice](./module07c.md)

## :loudspeaker: Introduction

The first two sections in this module approach data science in a traditional approach: the development of the model (exploration, feature engineering, tuning, etc.), building, and then deploying the model was completed in the first section. Consumption of the model, in the second section, is typically a separate process and may even be done by different teams.

However, in this specific scenario, there is little benefit to creating the model and generating predictions separately. This is because the model we developed is univariate: the predictions the model generates will not change without retraining the model. 

Most ML models are multivariate: for example, consider a travel time estimator that calculates travel time between two locations. Such a model could have many input variables, but two major variables would certainly include the time of day and weather conditions. Because the weather is changing frequently, we'd pass this data into the model to generate new travel time predicitions (inputs: time of day and weather, output: travel time).

In this case, we should generate our predictions immediately after creating the model; if we want to generate new predictions, we should consider retraining the ML model with the latest available data for improved accuracy. For practical purposes, then, this section shows how we could implement the ML model building and forecasting in a single step. Of course, we could have a separate process for each stock if we wanted -- but for simplicity, all of the stocks will share the same basic model parameters.

## Table of Contents

1. [Methods to retrain](#1-methods-to-retrain)

2. [Prepare the Environment](#2-prepare-the-environment)
3. [Import the Notebook](#3-import-the-notebook)
4. [Explore the Notebook](#4-explore-the-notebook)
5. [Run the notebook](#5-run-the-notebook)
6. [Examine the model and runs](#6-examine-the-model-and-runs)

## 1. Methods to retrain

Prophet has the capability to warm-start a model. Read the the [Updating Fitted Models section](https://facebook.github.io/prophet/docs/additional_topics.html) section of this document for information on how this works. 

The benefit of this approach is time: the model can be loaded (as we've done in the first two sections), and the model is then refit with all the data currently available. Refitting the model in this way is faster than fitting the model from scratch. When testing this approach, this yields about a 60% time savings on our small cluster (about 3 minutes to ~1.4 minutes). 

However, there are several drawbacks to warm-starting; and this method is fairly complex to orchestrate, reducing the time savings benefit. Because Prophet is able to train a model very quickly, we're better off training the model from scratch than attempting to warm-start.

## 1. Open and explore the notebook

Open the DS 3 - Build and Predict notebook. For reference, the three notebooks used throughout this module are listed below. More details on importing these are in module 07a.

* [Download the DS 1 - Build Model Notebook](<../resources/module07/DS 1 - Build Model.ipynb>)
* [Download the DS 2 - Predict Stock Prices Notebook](<../resources/module07/DS 2 - Predict Stock Prices.ipynb>)
* [Download the DS 3 - Build and Predict Notebook](<../resources/module07/DS 3 - Build and Predict.ipynb>)

Take some time exploring the notebook. Notice a few key things:

* There is no logging to MLflow. Data scientists can still use MLflow for developing models, logging metrics, and collaborating. 
* The ML models are built, and then predicitions made immediately and saved to the predictions table. There is no persistence of the model.
* There is no cross validation or other steps performed in 07a. While that is useful for the data scientist, it's not needed here.

## 2. Run the notebook

Run this notebook either entirely or step-by-step. You may wish to alter the way symbols are loaded to reduce run time. The *get_symbols* method in the notebook has 3 options for how symbols are loaded:

* They can be hard-coded in an array, specifying the symbol or symbols. For example, to manually specify all symbols, we can use the following code:

```python
symbol_df = spark.createDataFrame( \
    [['BCUZ'], ['IDGD'], ['IDK'], ['TDY'], ['TMRW'], ['WHAT'], ['WHO'], ['WHY']],['Symbol'])
```

To limit the processing to only the *WHO* stock, we can create the dataframe like so:

```python
symbol_df = spark.createDataFrame( \
    [['WHO']],['Symbol'])
```

Finally, if want to dynamically select all the symbols in the dataset, we can grab all of the distinct symbols from the data:

```python
if not df.rdd.isEmpty():
    symbol_df = df.select('symbol').distinct().sort('symbol')
```

Running the entire notebook across all symbols will take about 25 minutes.

## 2. Examine the results

Use the last cell of the notebook (frozen by default) to query the stock predictions table to verify results are being written to the table.

## 3. Additional Challenges

This notebook can be scheduled as needed (perhaps once per evening or weekly). 


Additional Challenge ideas:

* Consider trimming previous predictions if they are no longer needed. Create a cell that deletes predictions older than a certain value, such as older than 1 year.
* Create a new report that includes past predictions AND actual values, to show model accuracy.

## :tada: Summary

In this module, 

## :white_check_mark: Results

- [x] Loaded a notebook into your Fabric environment, created an ML model and stored it in MLflow, and evaluated the model performance.

