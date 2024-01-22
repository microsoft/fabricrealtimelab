# Module 03 - Reporting

[< Previous Module](./module02.md) - **[Home](../README.md)** - [Next Module >](./module04.md)

## :stopwatch: Estimated Duration

20 minutes

## :thinking: Prerequisites

- [x] Lab environment deployed from [setup](../modules/module00.md)
- [x] Completed [Module 01](../modules/module01.md)
- [x] Completed [Module 02](../modules/module02.md)

## :loudspeaker: Introduction

With the data loaded in the database and our initial KQL Queryset complete, we can begin to craft visualizations for real-time dashboards.

## Table of Contents

1. [Configure Refresh Rate](#1-configure-refresh-rate)
2. [Create a basic Power BI report](#2-create-a-basic-power-bi-report)
3. [Create a second visual for percent change](#3-create-a-second-visual-for-percent-change)
4. [Configure the report to auto-refresh](#4-configure-the-report-to-auto-refresh)

## 1. Configure Refresh Rate

Our Power BI tenant needs to be configured to allow for real time updating. To configure this setting, navigate to the Power BI admin portal by clicking on the *Settings* icon in the upper right of the Fabric portal. 

![Power BI Admin Portal](../images/module03/pbiadminportal.png)

Select *Capacity settings* on the left, and select the Fabric capacity that matches your current environment: this will be *Trial* if using a trial environment, or the capacity name configured earlier if using a new Fabric capacity. If you are using your organization's capacity, you may not have sufficient permissions to modify these settings, which means some functionality will be limited if the organization has limited the max refresh rate.

![Power BI Capacity Settings](../images/module03/fabriccapacitysettings.png)

On the following screen, scroll down to the *Power BI workloads* section, and under *Semantic Models* (recently renamed from *Datasets*), configure *Automatic page refresh* to *On*, with a minimum refresh interval of 1 second. Click *Apply*. Note: depending on your administrative permissions, this setting may not be available. Note that this change may take several minutes to complete.

> :bulb: **Did you know?**
> Power BI Datasets have recently been renamed to Semantic Models. In some cases, labels may not have been updated. The terms can be used interchangeably. Read more about this change [on the Power BI Blog](https://powerbi.microsoft.com/en-us/blog/datasets-renamed-to-semantic-models/).

![Power BI Refresh Interval](../images/module03/pbiautorefresh.png)

## 2. Create a basic Power BI report

From the *StockByTime* Queryset in the Fabric portal, click the *Build Power BI report* button above the query window.

![Create Power BI Report](../images/module03/buildpbireport.png)

On the report page that opens, we can configure our initial chart. Add a line chart to the design surface, and configure the report as follows:

* Legend: Symbol
* X-axis: Timestamp
* Y-axis: Price

> :bulb: **Sum, or average?**
> You may notice the default aggregation is *sum*, such as *Sum of price*. In the event there are multiple prices for a given symbol at the same point in time, this aggregation sets the behavior. *Sum* would, of course, add all prices, whereas *avg* would take the mean for all prices for that symbol at that point in time. However, in theory, we should only have a single price for a symbol at a given point in time, so there should be no visible difference. Average would be more visually correct for our purposes. 

![Configure Initial Report](../images/module03/pbiinitialreport.png)

Click File > Save, and name the report RealTimeStocks, and be sure to add it to the RealTimeWorkspace. It may take a few moments for the report to save and appear in the workspace.

Open the report from the RealTimeStocks workspace. While this is a promising start, let's make sure the chart only shows data for the last minute. Click the edit button to open the report editor, and select the line chart on the report. Configure the Timestamp filter to display data for the last 1 minute.

![Configure Timestamp Filter](../images/module03/pbitimestampfilter.png)

## 3. Create a second visual for percent change

Repeating the steps above, create a second line chart either beside or below the existing line chart. Instead of plotting the current stock price, select the percent changed value, which is a positive or negative value based on the previous price. Use these values for the chart:

* Legend: Stock Symbol
* X-axis: Timestamp
* Y-axis: Percent Changed

Similarly, configure the visual filter to show data only for the last minute. When complete, your visuals should look similar to the image below:

![Both Visuals on Report](../images/module03/bothreports.png)

## 4. Configure the report to auto-refresh

Deselect the chart. On the *Visualizations* settings, enable *Page refresh* to automatically refresh every second.

![Configure Report Refresh](../images/module03/pbipagerefresh.png)

## :tada: Summary

In this module, you modified the Power BI admin settings to allow for frequent page refreshes. Next, you created a Power BI report that leveraged the KQL Queryset created in the previous module. The line charts were configured to filtered the data for the last minute, and the page was configured to update every 1 second.

## :white_check_mark: Results

- [x] Created a Power BI real-time report.

[Continue >](./module04.md)