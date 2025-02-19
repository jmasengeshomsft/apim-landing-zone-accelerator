targetScope='subscription'

// Parameters
@description('A short name for the workload being deployed alphanumberic only')
@maxLength(8)
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param CICDAgentType string = 'none'

@description('A flag to indicate whether to deploy AKS in the backend resource group. Defaults to false.')
param deployAks bool = false

param vnetName string 
param vnetResourceGroupName string
param location string = deployment().location

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
//var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'

//var apimCSVNetName = 'jm-hub-vnet' //'vnet-apim-cs-${workloadName}-${environment}-${location}'
var aksClusterName = 'aks-${workloadName}-${location}-001' //'aks-${workloadName}-${environment}-${location}'
//var vnetResourceGroupName = 'jm-networking-rg'

var backendResourceGroupName = 'rg-backend-${resourceSuffix}'

var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

// Resource Names
var apimName = 'apim-${resourceSuffix}'
//var appGatewayName = 'appgw-${resourceSuffix}'


// resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
//   name: networkingResourceGroupName
//   location: location
// }

resource backendRG 'Microsoft.Resources/resourceGroups@2021-04-01' = if (deployAks == true) {
  name: backendResourceGroupName
  location: location
}

resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}

resource apimRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: apimResourceGroupName
  location: location
}

module networking './networking/networking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(vnetResourceGroupName)
  params: {
    workloadName: workloadName
    apimCSVNetName: vnetName
    deploymentEnvironment: environment
    location: location
  }
}

// module backend './backend/backend.bicep' = {
//   name: 'backendresources'
//   scope: resourceGroup(backendRG.name)
//   params: {
//     workloadName: workloadName
//     environment: environment
//     location: location    
//     vnetName: networking.outputs.apimCSVNetName
//     vnetRG: networkingRG.name
//     backendSubnetId: networking.outputs.backEndSubnetid
//     privateEndpointSubnetid: networking.outputs.privateEndpointSubnetid
//   }
// }

//var jumpboxSubnetId= networking.outputs.jumpBoxSubnetid
//var CICDAgentSubnetId = networking.outputs.privateEndpointSubnetid

module shared './shared/shared.bicep' = {
  dependsOn: [
    networking
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    //accountName: accountName
    CICDAgentSubnetId: ''
    PrivateLinkSubnetId: networking.outputs.privateEndpointSubnetid
    CICDAgentType: CICDAgentType
    environment: environment
    //jumpboxSubnetId: jumpboxSubnetId
    location: location
    //personalAccessToken: personalAccessToken
    resourceGroupName: sharedRG.name
    resourceSuffix: resourceSuffix
    //vmPassword: vmPassword
    //vmUsername: vmUsername
  }
}

module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    apimName: apimName
    apimSubnetId: networking.outputs.apimSubnetid
    location: location
    appInsightsName: shared.outputs.appInsightsName
    appInsightsId: shared.outputs.appInsightsId
    appInsightsInstrumentationKey: shared.outputs.appInsightsInstrumentationKey
  }
}

//Creation of private DNS zones
module dnsZoneModule 'shared/dnszone.bicep'  = {
  name: 'apimDnsZoneDeploy'
  scope: resourceGroup(sharedRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    vnetName: networking.outputs.apimCSVNetName
    vnetRG: vnetResourceGroupName
    apimName: apimName
    apimRG: apimRG.name
    keyVaultName: shared.outputs.keyVaultName
  }
}

//deploy Private AKS in the Backend RG if the user chooses to deploy AKS
module aksModule 'private-aks/privateaks.bicep' = if (deployAks == true) {
  name: 'aksDeploy'
  scope: resourceGroup(backendRG.name)
  params: {
    clusterName: aksClusterName
    location: location
    logworkspaceid: shared.outputs.logAnalyticsWorkspaceId
    subnetId: networking.outputs.backEndSubnetid
    networkPlugin: 'kubenet'
  }
}
