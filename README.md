
# Enterprise-Scale-APIM Lite (Fork)

This repo is a fork of [Enterprise-Scale-APIM](https://github.com/Azure/apim-landing-zone-accelerator). Checkout the original repository for a complete enterprise deployment reference. This fork focuses on demonstrating how to successfully provision an internal APIM instance in an existing dev environment (spoke vnet). 

## What was ommitted: 
- Application Gateway
- Jumpbox and Build Agent VMs
- Backend workload : Azure Functions
- CI/CD sections that utilizes [Azure API Management DevOps Resource Kit](https://github.com/Azure/azure-api-management-devops-resource-kit)

## What was added:

- An additional Private DNS Zone **configuration.azure-api.net** to support Self-Hosted Gateways
- Ability to deploy into an existing Virtual Network (WIP)

### Reference Implementation 1: App Gateway with internal APIM instance with Azure Functions as backend

Architectural Diagram:
![image](/docs/images/arch.png)


Deployment Details:
| Deployment Methodology| GitHub Action YAML| User Guide|
|--------------|--------------|--------------|
| [Bicep](/reference-implementations/AppGW-IAPIM-Func/bicep) |[es-apim.yml](/.github/workflows/es-apim.yml)| [README](/docs/README.md)
| ARM (Coming soon) ||
| Terraform (Coming soon)||
---

## Generating the ARM Template

## Other Considerations

1. This is a way you can execute bicep deployment:

    ```azcli
    az deployment sub create --location eastus --name am --template-file main.bicep --parameters workloadName=am environment=dev

2. Please leverage issues if you have any feedback or request on how we can improve on this repository

