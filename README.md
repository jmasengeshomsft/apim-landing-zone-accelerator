
# Enterprise-Scale-APIM Lite (Fork)

This repo is a fork of [Enterprise-Scale-APIM](https://github.com/Azure/apim-landing-zone-accelerator). Checkout the original repository for a complete enterprise deployment reference. This fork focuses on demonstrating how to successfully provision an internal APIM instance in an existing dev environment (spoke). 

## What was ommitted: 
- Application Gateway
- Jumpbox and Build Agent VMs
- Backend workload : Azure Functions
- CI/CD sections that utilizes [Azure API Management DevOps Resource Kit](https://github.com/Azure/azure-api-management-devops-resource-kit)

## What was added:

- An additional Private DNS Zone **configuration.azure-api.net** to support Self-Hosted Gateways
- Ability to deploy into an existing Virtual Network (WIP)

## How to deploy in your environment

1. ### AZ CLI
   
   Clone the repository
   
         
         #clone the repository
         git clone https://github.com/jmasengeshomsft/apim-landing-zone-accelerator-lite.git
   
   From the home directory, run the following:

    ```azcli
    cd reference-implementations/AppGW-IAPIM-Func/bicep
    
    #azure location
    location="your azure region"
    
    #name of the deployment
    name="apim"
    
    #prefix to be used in naming resources
    workloadName="up to 8 letters prefix"
    
    #environment, used in naming resources
    environment="dev"
    
    # run the bicep deploy commant at the subscription level 
    az deployment sub create --location $location --name $name --template-file main.bicep --parameters workloadName=$workloadName environment=$environment CICDAgentType=none

4. ### Pipeline with GitHub Actions

   To deploy resources in an Azure Subscription, we will use the pipeline under .github/workflows/es-apim.yaml

         
         #clone or fork the repository
         git clone https://github.com/jmasengeshomsft/apim-landing-zone-accelerator-lite.git



     Navigate to the Bicep folder by running the following script from the repo home directory

         
         cd reference-implementations/AppGW-IAPIM-Func/bicep

     **Deployment Parameters**
     
      Update **config.yaml** with your variables:

         
         AZURE_LOCATION: 'your azure region'
         RESOURCE_NAME_PREFIX: 'up to 8 letters prefix'
         ENVIRONMENT_TAG: 'dev'
         CICD_AGENT_TYPE: 'none'

     **AZ Login With a Service Principal**

     [The original repository](https://github.com/jmasengeshomsft/apim-landing-zone-accelerator-lite/tree/main/docs#2-authentication-from-github-to-azure) uses OpenID Connect (OIDC) with a Azure service principal using a Federated Identity Credential. For simplicity in this fork, we will use a service principal with secret. We will only need to set up one action secret wit four pieces information in a json object. If you prefer Federated authentication, follow the documentation in the [original repo](https://github.com/jmasengeshomsft/apim-landing-zone-accelerator-lite/tree/main/docs#2-authentication-from-github-to-azure) and adjust the pipeline accordingly. 

     - Create a Service Principal and assign it Contributor role to the Subscription where APIM will be deployed
     - Create and obtain the value of secret for the created Service Principal. 
     - Note the Subscription ID, Tenant ID, Client ID and the Secret values
     - Create a json object that looks like the following

         ```azcli 
          {
             "clientId": "value",
             "clientSecret": "value",
             "subscriptionId": "value",
             "tenantId": "value"
          }

      - In your GitHub repository Settings, create an Action secret named "**AZURE_CREDENTIALS**" and populate it with the json object above. This is used in the pipeline for **azure/lgoin@1**
         ```azcli
           - uses: azure/login@v1
           with:
             creds: '${{ secrets.AZURE_CREDENTIALS }}'

      - Create another Action secret to hold the subscription Id. Name it **AZURE_SUBSCRIPTION_ID** 

   That's it. If everything is wired correctly, you are ready to run the pipeline. 


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



