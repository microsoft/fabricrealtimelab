# Module 00 - Lab Environment Setup

**[Home](../README.md)** - [Next Module >](./module01.md)

## :stopwatch: Estimated Duration

20 minutes

## :thinking: Prerequisites

* An [Azure account](https://azure.microsoft.com/free) with an active subscription.
* Owner permissions within a Resource Group to create resources and manage role assignments.

## :loudspeaker: Introduction

In order to follow along with the lab exercises, we need to provision a set of resources. These steps will walk you through the process of deploying an ARM template that will create an Event Hub namespace, Event Hub, and Azure Container Instance that will generate the mock data.

There are two ways to deploy these resources. [The first method](#1-auto-deploy-template) will deploy the template by using the link that loads the template in the Azure portal. This is the fastest way to deploy. [The second method](#2-manually-deploy-template-via-cli) will have you download the template files, upload them with the CLI, and use the CLI to create the resources. While this method takes longer, it offers you the opportunity to get familiar with the CLI. Pick whichever method you prefer.

## Table of Contents

1. [Auto-Deploy Template](#1-auto-deploy-template)

## 1. Auto-deploy template

To auto-deploy the resources, use these steps below. 

1. `Right-click` or `Ctrl + click` the button below to open the Azure Portal in a new window.

    [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbhitney%2Ffabricrealtimelab%2Fmain%2Fresources%2Ffabricrealtimeworkshop_armtemplate.json)

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

4. After the deployment has completed, open the resource group and verify the Event Hub namespace and ACI machine is deployed. You can skip directly to the [summary](#tada-summary).

## :tada: Summary

With the container generating data and Event Hub created, we're ready to start!

## :white_check_mark: Results

Azure Resources

- [x] 1 x Resource Group
- [x] 1 x Event Hub Namespace
- [x] 1 x Event Hub
- [x] 1 x ACI container instance

[Continue >](./module01.md)
