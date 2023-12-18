# Microsoft Fabric Real-Time Analytics Workshop

Welcome to the Microsoft Fabric Real-time Analytics end-to-end workshop!

Analytics on real-time data presents unique challenges compared to traditional batch and near real-time scenarios. With real-time analytics, potentially large volumes of data need continuous ingestion, transformation, and visualization. 

In Microsoft Fabric, Real-Time Analytics is a fully managed big data analytics platform optimized for streaming, and time-series data. It utilizes a query language and engine with exceptional performance for searching structured, semi-structured, and unstructured data. Real-Time Analytics is fully integrated with the entire suite of Fabric products, for both data loading, data transformation, and advanced visualization scenarios.

An example of a real-time analytics architecture in Microsoft Fabric is illustrated below. 

![Data Lakehouse with Azure Synapse Analytics](./images/readme/ArchitectureSlide1.png)

In this workshop, participants will get hands-on with a ficticious financial company "AbboCost." AbboCost would like to set up a stock monitoring platform to monitor price fluctuations and report on historical data. Throughout the workshop, we'll look at how every aspect of Microsoft Fabric can be incorporated as part of a larger solution -- by having everything in an integrated solution, we'll be able to quickly and securely integrate data, build reports, create data warehouses and lakehouses, forecast using ML models, and so on.

## :thinking: Prerequisites

* An [Azure account](https://azure.microsoft.com/free/) with an active subscription.
  * If you are working through this content as part of a proctored workshop, your proctor may be able to provide you with an Azure Pass or other lab environment.
  * If you are a [Visual Studio subscriber](https://azure.microsoft.com/en-us/pricing/member-offers/credit-for-visual-studio-subscribers/), you may leverage this benefit to host the data in your account.
  * If you don't have access to an Azure subscription, you may be able to sign up for a [free account](https://www.azure.com/free).
* You must have the necessary privileges within your Azure subscription to create resources, create Microsoft Fabric capacity, register resource providers (if required), etc. Note that some organizational accounts may have administrative restrictions on Power BI features, which may limit functionality. 

## :books: Learning Modules

Core Modules for real-time analytics:

0. [Environment Setup](./modules/module00.md)
1. [KQL Database Configuration and Ingestion](./modules/module01.md)
2. [Exploring the Data](./modules/module02.md)
3. [Reporting in Power BI](./modules/module03.md)

Additional modules for end-to-end solution:

4. [Data Activator](./modules/module04.md)
5. [Data Warehousing: Synapse Data Warehouse and Data Pipelines](./modules/module05a.md)
6. [Data Lakehouse: Fabric Lakehouse and Notebooks](./modules/module06.md)
7. [Data Science: Using the Lakehouse and Notebooks](./modules/module07.md)

Continued Learning & Additional Modules

10. [(Optional) Advanced KQL, Dashboards, Troubleshooting](./modules/module10.md)
   * 10a: [KQL Queryset Improvements](./modules/module10a.md)
   * 10b: [Additional Real-time Dashboard](./modules/module10b.md)


<div align="right"><a href="#fabric-real-time-workshop">↥ back to top</a></div>

