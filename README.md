
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

## How to deploy in your environment

1. AZ CLI
   From the home directory run the following:

    ```azcli
    cd reference-implementations/AppGW-IAPIM-Func/bicep
    
    #azure location
    location="centralus"
    
    #name of the deployment
    name="am"
    
    #prefix to be used in naming resources
    workloadName="am"
    
    #environment, used in naming resources
    environment="dev"
    
    # run the bicep deploy commant at the subscription level 
    az deployment sub create --location $location --name $name --template-file main.bicep --parameters workloadName=$workloadName environment=$environment CICDAgentType=none

4. Pipeline with GitHub Actions

   To deploy resources in an Azure Subscription, we will use the pipeline under .github/workflows/es-apim.yaml

      ```azcli
      #clone the repository
      git clone https://github.com/jmasengeshomsft/apim-landing-zone-accelerator-lite.git

  ## Set parameters

  Navigate to the Bicep folder by running the following script from the repo home directory
   
     ```azcli
       cd reference-implementations/AppGW-IAPIM-Func/bicep
   
   Update **config.yaml** with your variables:
   
     ```azcli
      AZURE_LOCATION: 'centralus'
      RESOURCE_NAME_PREFIX: 'myapim'
      ENVIRONMENT_TAG: 'dev'
      CICD_AGENT_TYPE: 'none'
   
  ## AZ Login With a Service Principal

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



