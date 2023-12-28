# Module 00 - Lab Environment Setup

**[Home](../README.md)** - [Next Module >](./module01.md)

## :stopwatch: Estimated Duration

30 minutes

[All SQL Queries](../resources/module05/scripts/sqlscripts.zip)

[test](./raw/main/resources/module05/scripts/sqlscripts.zip)
[test](../raw/main/resources/module05/scripts/sqlscripts.zip)
[test](/raw/main/resources/module05/scripts/sqlscripts.zip)

[test](raw/main/resources/module05/scripts/sqlscripts.zip)

## :thinking: Prerequisites

* Access to a Microsoft Fabric environment, or ability to create a Microsoft Fabric trial.

Depending on the deployment method, you may also need: 
* An [Azure account](https://azure.microsoft.com/free) with an active subscription.
* Owner permissions within a Resource Group to create resources and manage role assignments.

## :loudspeaker: Introduction

In order to follow along with the workshop exercises, we need to provision a set of resources. At the heart of the scenario is our real-time stock price generator script that generates a continuous stream of stock prices that we'll use throughout the workshop. There are two ways to deploy this application:

* Option 1 - Deploy the app via Jupyter notebook
* Option 2 - Deploy the app via Azure Container Instance

Both options yield the same data and is simply a matter of preference. For those using a Fabric free trial, we recommend using the Jupyter notebook (option 1) as it keeps the costs at zero and is 100% within the Fabric portal. The notebook must be kept running for the data to be generated. However, if you anticipate diving deeply into the lakehouse and data science modules, you may wish to go with the container (option 2) to help avoid resource contention when running multiple notebooks. See the [additional learning section](#thinking-additional-learning) for references that discuss sizing and cluster configuration; running the app in a container will avoid these potential issues.

For those who have an existing environment (not a trial, and/or in a large organization) you may wish to go the container route (option 2) because running the script inside a container is more efficient than using a Spark cluster that the Jupyter notebook will use. (The pay-as-you-go cost for running the container and event hub is roughly $1.70/day, but please verify costs using the [Azure Price Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) -- the ARM template deploys a basic Event Hub and smallest possible 1 vCPU ACI container.) When deploying via a container, the container starts automatically and begins creating data immediately. 

You always have the option to revisit this option later, should you wish to make a change.

We'll begin by creating our Fabric workspace, and then deploy the app using one of the methods mentioned above.

## Table of Contents

1. [Create Fabric Capacity and Workspace](#1-create-fabric-capacity-and-workspace)
2. [Option 1 - Deploy and run the app via Jupyter notebook](#2-option-1---deploy-the-app-via-jupyter-notebook)
3. [Option 2 - Deploy the app via Azure Container Instance](#3-option-2---deploy-the-app-via-azure-container-instance)

## 1. Create Fabric Capacity and Workspace

Microsoft Fabric is deployed to an Azure Active Directory tenant. Within each Fabric tenant, Fabric capacities can be created to group resources for various purposes -- this might be done organizationally (sales, marketing, development), geographically, or other logical grouping. 

If a Fabric Trial is available, we recommend taking advantage of that opportunity to try Microsoft Fabric for a period of time (currently 60 days) with no commitment.

To create a Fabric capacity outside of a trial environment, create a new resource from the Azure portal, and search for Fabric. 

![Create Fabric Capacity](../images/module00/fabricmarketplace.png)

On the Create Fabric capacity page, assign the capacity to a resource group in a region that is available to you or recommended by your proctor, and change the size to the smallest size to minimize costs.

![Create Fabric Capacity](../images/module00/fabriccapacity.png)

To learn more about Fabric capacities, visit this page:
[https://learn.microsoft.com/en-us/fabric/enterprise/licenses](https://learn.microsoft.com/en-us/fabric/enterprise/licenses)

Next, we'll create the Workspace within our Fabric capacity. Workspaces are assigned to capacities and serve as logical groupings for collaboration. We'll create a workspace within Fabric to house all of the artifacts for this workshop. 

In the [Fabric portal](https://app.fabric.microsoft.com/), click on Workspaces in the left nav and create a new workspace called RealTimeWorkspace.

![Create Fabric Workspace](../images/module00/createworkspace.png)

Be sure to assign the workspace to the capacity created above. To do this, expand the advanced settings and ensure Fabric capacity is selected as the licensing mode, with the capacity created above selected.

![Fabric Advanced Settings](../images/module00/createworkspacesettings.png)

## 2. Option 1 - Deploy the app via Jupyter Notebook

This option deploys as a Jupyter notebook, generating our stock prices and publishing to an Eventstream within Fabric.

1. To begin, download the following notebook to a convenient location:

* [Download the Stock Generator notebook](../resources/module00/StockGeneratorNotebook.ipynb)

2. In your Fabric workspace, switch to the Real-Time Analytics persona (bottom left) and create a new Eventstream. Name the Eventstream StockEventStream.

![Create Eventstream](../images/module00/setupeventstream.png)

3. On the Eventstream, configure a new source and select Custom App:

![Create Custom App](../images/module00/setupcustomapp.png)

4. On the 'Keys' tab of the Custom App, reveal the first connection string and copy it to your clipboard:

![Copy Connection String](../images/module00/copyappconnstring.png)

5. Switch to the Data Science persona. On the home page for the persona, click 'Import Notebook' and upload the notebook you downloaded earlier:

![Import Notebook](../images/module00/importnotebook.png)

6. In the notebook, paste the connection string from above in the single quotes of the 'ConnectionString' variable of the first cell. It should look similar to the below:

![Paste Connection String](../images/module00/pasteconnstring.png)

7. With the connection string in place, click 'Run All' in the top toolbar. The first few cells may take a few moments to start the Spark session and import the required libraries. After a few moments, switch back to the Eventstream to observe a preview of the events generated by the notebook:

![Eventstream Preview](../images/module00/eventstreampreview.png)

With this step completed, we're ready to move on -- you can skip Option 2.

## 3. Option 2 - Deploy the app via Azure Container Instance

This option deploys the stock generator app to an Azure Container Instance using an ARM template. The app will generate stock data that publishes the data to an Azure Event Hub, which is also configured during the deployment of the ARM template. 

To auto-deploy the resources, use these steps below. 

1. `Right-click` or `Ctrl + click` the button below to open the Azure Portal in a new window.

    [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmicrosoft%2Ffabricrealtimelab%2Fmain%2Fresources%2Fmodule00%2Ffabricrealtimeworkshop_armtemplate.json)

2. Beneath the **Resource group** field, click **Create new** and provide a unique name (e.g. `realtimeworkshop`), select a valid location, and then click **Review + create**.

    Suggested Locations:

     * Australia East
     * Canada Central
     * Central India
     * Central US
     * East Asia
     * East US
     * East US 2
     * Germany West Central
     * Japan East
     * Korea Central
     * North Central US
     * Norway East
     * South Central US
     * Switzerland North
     * UAE North
     * West US
     * West US 3

3. Once the validation has passed, click **Create**.

> :bulb: **Problems deploying?**
> If you have issues deploying, here are a couple of things to check: you subscription might have limitations on regions or resources, or a region may have capacity constraints. Try a different region, but if the problem persists please ask a proctor for assistance or file an issue with the project.

4. After the deployment has completed, open the resource group and verify the Event Hub namespace and ACI machine is deployed: 

![Azure Deployment](../images/module00/azuredeployment.png)

5. Open the EventHubNamespace, which will have a name similar to ehns-123456-fabricrealtime. On the Settings > Shared access policies page, take note of this event hub namespace name (such as ehns-123456-fabricrealtime), the event hub name (by default, fwtheventhub), the name of the SAS key (by default, RootManagedSharedAccessKey), and copy the primary key to your clipboard or safe location.

![Azure SAS Key](../images/module00/azuresaskey.png)

6. In your Fabric workspace, switch to the Real-Time Analytics persona (bottom left) and create a new Eventstream. Name the Eventstream StockEventStream.

![Create Eventstream](../images/module00/setupeventstream.png)

7. On the Eventstream, configure a new source and select Event Hub:

![Create Custom App](../images/module00/eventstream-eventhub.png)

8. On the Azure Event Hubs configuration page, add a new connection and using the values from EventHub you noted earlier, specifying the $Default consumer group: 

![Configure Event Hub](../images/module00/eventstream-hubconnection.png)

## :thinking: Additional Learning

* [Spark Concurrency in Microsoft Fabric](https://learn.microsoft.com/en-us/fabric/data-engineering/spark-job-concurrency-and-queueing)
* [Advancing Analytics - Fabric Notebook Concurrency Explained](https://www.advancinganalytics.co.uk/blog/2023/12/13/fabric-notebook-concurrency-explained)

## :tada: Summary

With the notebook or container generating data and ingesting into our Eventstream, we're ready to continue! 

## :white_check_mark: Results

- [x] Configured Fabric environment
- [x] Set up the stock generator app (notebook or ACI)
- [x] Data getting ingested into Fabric Eventstream

[Continue >](./module01.md)
