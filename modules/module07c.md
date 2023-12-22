# Module 06 - Data Science

[< Previous Module](../modules/module07b.md) - **[Home](../README.md)** - [Next Module >](./module10.md)

## :stopwatch: Estimated Duration

* 30 minutes for 07c
* 2 hours overall

## :thinking: Prerequisites

- [x] Completed Module 07a
- [x] Completed Module 07b

This module is broken down into 3 submodules.
* [Module 07a - Building and storing an ML model]
* [Module 07b - Using models, saving to Lakehouse, building a report]
* [Module 07c - Solution in practice]

## :loudspeaker: Introduction

The first two sections in this module approach data science in a traditional approach: the development of the model (exploration, feature engineering, tuning, etc.), building and saving the model. Consumption of the model is typically a separate process, and may even be done by different teams. 

However, in this scenario, there is little benefit to creating the model and generating predictions separately. This is because the model we developed is univariate: the predictions the model generates will not change without first retraining the model. This is because the model is based solely on fitting the data to time without consideration of other variables. (Prophet can incoporate holidays and other regressors, but these are built into the model.)

Most models are multivariate: for example, travel time between two locations would likely have 2 large variables: the time of day, and weather conditions. Because the weather is changing frequently, we'd pass this data into the model to generate new forecasts (input: time of day and weather, output: travel time).

In this case, we should generate our predictions immediately after creating the model; if we want to generate new predictions, we should retrain the model with the latest data.

## Table of Contents

1. [Download the Notebook](#1-download-the-notebook)
2. [Prepare the Environment](#2-prepare-the-environment)
3. [Import the Notebook](#3-import-the-notebook)
4. [Explore the Notebook](#4-explore-the-notebook)
5. [Run the notebook](#5-run-the-notebook)
6. [Examine the model and runs](#6-examine-the-model-and-runs)

## 1. Methods to retrain

Prophet has the capability to warm-start a model. Read the the [Updating Fitted Models section](https://facebook.github.io/prophet/docs/additional_topics.html) section of this document for information on how this works. 

The benefit of this approach is time: the model can be loaded (as we've done in the first two sections), and the model refitted with all the data currently available to refit the model. Refitting the model in this way is faster than fitting the model from scratch. With our data, this yields about a 60% time savings when fitting the model (about 3 minutes to ~1.4 minutes).

However, there are several drawbacks, and this method is fairly complex: it essentially combines all of the steps in both section 1 and 2 into one notebook. Although time time savings are significant, there's extra time in logging/loading models, reducing the time savings benefit.

One of Prophet's greatest strength is it's ability to train quickly, so we're better off training the model and generating predictions in one step.

## 1. Open and explore the notebook

Open the DS 3- Build and Predict notebook. For reference, the three notebooks used throughout this module are listed below. More details on importing these are in module 07a.

* [Download the DS 1 - Build Model Notebook](<../resources/module07/DS 1 - Build Model.ipynb>)
* [Download the DS 2 - Predict Stock Prices Notebook](<../resources/module07/DS 2 - Predict Stock Prices.ipynb>)
* [Download the DS 3 - Build and Predict Notebook](<../resources/module07/DS 3 - Build and Predict.ipynb>)

Take some time exploring the notebook.

Notice a few key things:

* There is no logging to MLflow. Data scientists can still use MLflow for developing models and finding ideal parameters. 
* Models are build, and predictions are made immediately and saved to the predictions table. There is no persistence of the model.

## 2. Run the notebook

Run this notebook either entirely or step-by-step. You may wish to alter the way symbols are loaded to reduce run time. The *get_symbols* method in the notebook has 3 options for how symbols are loaded:

* They can be hard-coded in an array, specifying the symbol or symbols. For example, to manually specify all symbols, we can use the following code:

```python
symbol_df = spark.createDataFrame( \
    [['BCUZ'], ['IDGD'], ['IDK'], ['TDY'], ['TMRW'], ['WHAT'], ['WHO'], ['WHY']],['Symbol'])
```

If we'd like to limit the processing to only the *WHO* stock, we can create the dataframe like so:

```python
symbol_df = spark.createDataFrame( \
    [['WHO']],['Symbol'])
```

Finally, if want to dynamically select all the symbols in the dataset, we can grab all of the distinct symbols from the data:

```python
if not df.rdd.isEmpty():
    symbol_df = df.select('symbol').distinct().sort('symbol')
```

Running the entire notebook will take about 20 minutes.

## 2. Examine the results

Using the last cell of the notebook (that are frozen by default) query the stock predictions table to very results are being written to the table.

## 3. Additional Challenges

This notebook can be scheduled as needed (perhaps once per evening). 

Additional Challenge ideas:

* Consider trimming previous predictions if they are no longer needed. Create a cell that deletes predictions older than a certain value, such as older than 1 year.
* Create a new report that includes past predictions AND actual values, to show model accuracy.

## :tada: Summary

In this module, 

## :white_check_mark: Results

- [x] Loaded a notebook into your Fabric environment, created an ML model and stored it in MLflow, and evaluated the model performance.

