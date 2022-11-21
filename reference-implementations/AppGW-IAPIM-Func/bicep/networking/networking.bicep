//
//   ***@microsoft.com, 2021
//
// Deploy as
//
// # Script start
//
// $RESOURCE_GROUP = "rgAPIMCSBackend"
// $LOCATION = "westeurope"
// $BICEP_FILE="networking.bicep"
//
// # delete a deployment
//
// az deployment group  delete --name testnetworkingdeployment -g $RESOURCE_GROUP 
// 
// # deploy the bicep file directly
//
// az deployment group create --name testnetworkingdeployment --template-file $BICEP_FILE --parameters parameters.json -g $RESOURCE_GROUP -o json
// 
// # Script end


// Parameters
@description('A short name for the workload being deployed')
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param deploymentEnvironment string
param apimCSVNetName string


param privateEndpointAddressPrefix string = '10.1.1.0/26'
param backEndAddressPrefix string = '10.1.1.64/26'
param apimAddressPrefix string = '10.1.1.128/26'
param location string


// Variables
// var owner = 'APIM Const Set'

var privateEndpointSubnetName = 'snet-prep-${workloadName}-${deploymentEnvironment}-${location}-001'
var backEndSubnetName = 'snet-bcke-${workloadName}-${deploymentEnvironment}-${location}-001'
var apimSubnetName = 'snet-apim-${workloadName}-${deploymentEnvironment}-${location}-001'


var privateEndpointSNNSG = 'nsg-prep-${workloadName}-${deploymentEnvironment}-${location}'
var backEndSNNSG = 'nsg-bcke-${workloadName}-${deploymentEnvironment}-${location}'
var apimSNNSG = 'nsg-apim-${workloadName}-${deploymentEnvironment}-${location}'

var publicIPAddressName = 'pip-apimcs-${workloadName}-${deploymentEnvironment}-${location}' // 'publicIp'



resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: apimCSVNetName
  //scope: resourceGroup('sre-rg')
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  dependsOn: [
    apimSubnet
  ]
  name: privateEndpointSubnetName
  parent: vnet
  properties: {
    addressPrefix: privateEndpointAddressPrefix
    networkSecurityGroup: {
      id: privateEndpointNSG.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: apimSubnetName
  //scope: vnet
  parent: vnet
  properties: {
    addressPrefix: apimAddressPrefix
    networkSecurityGroup: {
      id: apimNSG.id
    }
  }
}

resource backEndSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  dependsOn: [
    privateEndpointSubnet
    apimSubnet
  ]
  name: backEndSubnetName
  //scope: vnet
  parent: vnet
  properties: {
    addressPrefix: backEndAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    networkSecurityGroup: {
      id: backEndNSG.id
    }
  }
}

resource privateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: privateEndpointSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource backEndNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: backEndSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}
resource apimNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: apimSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'apim-mgmt-endpoint-for-portal'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'ApiManagement'
          protocol: 'Tcp'
          destinationPortRange: '3443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'apim-azure-infra-lb'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'AzureLoadBalancer'
          protocol: 'Tcp'
          destinationPortRange: '6390'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'apim-azure-storage'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'apim-azure-sql'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '1433'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'SQL'
        }
      }
      {
        name: 'apim-azure-kv'
        properties: {
          priority: 2020
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
        }
      }
    ]
  }
}

// Public IP 
resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Output section
output apimCSVNetName string = apimCSVNetName
output apimCSVNetId string = vnet.id

 
output privateEndpointSubnetName string = privateEndpointSubnetName  
output backEndSubnetName string = backEndSubnetName  
output apimSubnetName string = apimSubnetName

  
output privateEndpointSubnetid string = '${vnet.id}/subnets/${privateEndpointSubnetName}'  
output backEndSubnetid string = '${vnet.id}/subnets/${backEndSubnetName}'  
output apimSubnetid string = '${vnet.id}/subnets/${apimSubnetName}'  

output publicIp string = pip.id
