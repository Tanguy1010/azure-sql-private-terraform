# azure-sql-private-terraform

## Introduction

This repository is an example of how to deploy an Azure sql database in a private network using Terraform. This example can not be use as is, it needs to be adapted to you needs. 

## Requirements

- Terraform v1.7.3
- Azurerm provider v3.106.1
- betr-io/mssql provider v0.3.1

## Usage

```bash
terraform init
terraform plan
terraform apply
```

> [!NOTE]
> the sql database module needs to have access to the private network, therefore it can not be deploy in the first apply. You can first deploy the Hub and then connect to the Network gateway before deploying the sql database.

## Overview

This repository deploys the network infrastructure in a Hub/Spoke topology. A SQL server is deployed with public access disabled, and a private endpoint is created in a Spoke VNet. Then a SQL database is deployed with this SQL server.

## Modules

### Hub

This module creates a VNet where all the Spoke VNets can connect. It has a subnet for a Network Gateway and another for a DNS resolver. The Network Gateway can be used to access the private network and to connect to the SQL server. In this example, the P2S configuration is not included, but it can be configured with OpenVPN or with Azure Active Directory. The DNS resolver is needed to resolve private DNS, which is necessary to connect to the SQL server using DNS instead of the private IP address.

### Spoke

This module creates a VNet that is peered to the Hub VNet with Gateway transit enabled to allow the Virtual Network Gateway to connect to the SQL server. It has a subnet for the private endpoint that is used to privately connect to the SQL server.

### SQL Server

This module creates a SQL server with public access disabled. It also creates a private endpoint in the Spoke VNet to connect to the SQL server. The IP address is added to the Azure private DNS record to resolve the SQL server domain name. Azure handles the DNS resolution in the background, so the SQL server domain name is used to access the server instead of the private IP address.

### SQL Database

This module creates a SQL database in the SQL server. Because public access is disabled, it is only accessible via the Network Gateway. Additionally, the module uses the provider [betr-io/mssql](https://github.com/betr-io/terraform-provider-mssql) to manage database access. This provider connects to the database and therefore needs access for each plan and apply operation.

While this is not always necessary and can be removed, if your implementation requires it, you will need to connect to the Network Gateway. This can be achieved by executing the plan and apply operations locally with a connection to the Network Gateway or by using a self-hosted agent in a CI/CD pipeline. Alternatively, you can connect the hosted agent to the Network Gateway.