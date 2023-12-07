# Microsoft Fabric Real-Time Analytics Workshop

Analytics on real-time data presents unique challenges compared to traditional batch and near real-time scenarios. With real-time analytics, potentially large volumes of data need continuous ingestion, transformation, and visualization. 

In Microsoft Fabric, Real-Time Analytics is a fully managed big data analytics platform optimized for streaming, and time-series data. It utilizes a query language and engine with exceptional performance for searching structured, semi-structured, and unstructured data. Real-Time Analytics is fully integrated with the entire suite of Fabric products, for both data loading, data transformation, and advanced visualization scenarios.

An example of a real-time analytics architecture in Microsoft Fabric is illustrated below. 

![Data Lakehouse with Azure Synapse Analytics](./images/readme/ArchitectureSlide1.png)

In this workshop, participants will get hands-on with a ficticious financial company "AbboCost." AbboCost would like to set up a stock monitoring platform to monitor price fluctuations and report on historical data. 

To complete the solution, an Azure Container Instance (ACI) is deployed that generates ficticious stock data. A Microsoft Fabric environment will be provisioned (if needed), data will be ingested into a new database, and Power BI reports will be created. 

## :thinking: Prerequisites

* An [Azure account](https://azure.microsoft.com/free/) with an active subscription.
  * If you are working through this content as part of a proctored workshop, your proctor may be able to provide you with an Azure Pass or other lab environment.
  * If you are a [Visual Studio subscriber](https://azure.microsoft.com/en-us/pricing/member-offers/credit-for-visual-studio-subscribers/), you may leverage this benefit to host the data in your account.
  * If you don't have access to an Azure subscription, you may be able to sign up for a [free account](https://www.azure.com/free).
* You must have the necessary privileges within your Azure subscription to create resources, create Microsoft Fabric capacity, register resource providers (if required), etc. Note that some organizational accounts may have administrative restrictions on Power BI features, which may limit functionality. 

## :books: Learning Modules

Foundational Modules

0. [Environment Setup](./modules/module00.md)
1. [Fabric Setup and Configuration](./modules/module01.md)
2. [Exploring the Data](./modules/module02.md)
3. [Reporting in Power BI](./modules/module03.md)
4. [(Optional) Data Activator](./modules/module04.md)
5. [Data Warehousing](./modules/module05a.md)
6. [Coming Soon - Data Lakehouse](./modules/module06.md)
7. [(Optional) Data Science](./modules/module07.md)

Continued Learning & Additional Modules

10. [(Optional) Advanced KQL, Dashboards, Troubleshooting](./modules/module10.md)
   * 10a: [KQL Queryset Improvements](./modules/module10a.md)
   * 10b: [Additional Real-time Dashboard](./modules/module10b.md)


<div align="right"><a href="#fabric-real-time-workshop">↥ back to top</a></div>

