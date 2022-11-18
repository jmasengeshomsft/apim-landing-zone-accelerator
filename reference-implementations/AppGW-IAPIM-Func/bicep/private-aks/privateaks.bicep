param clusterName string
param logworkspaceid string
param subnetId string
// param identity objectg
// param kubernetesVersion string
param location string = resourceGroup().location

@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string = 'kubenet'
//param appGatewayIdentityResourceId string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-01-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
    // userAssignedIdentities: identity
  }
  properties: {
    // kubernetesVersion: kubernetesVersion
    // nodeResourceGroup: '${clusterName}-aksInfraRG'
    // podIdentityProfile: networkPlugin == 'azure' ?{
    //   enabled: true
    // }:{
    //   enabled: true
    //   allowNetworkPluginKubenet: true
    // }
    dnsPrefix: '${clusterName}aks'
    agentPoolProfiles: [
      {
        enableAutoScaling: true
        name: 'defaultpool'
        availabilityZones: ['1', '2', '3']
        mode: 'System'
        enableEncryptionAtHost: false
        count: 3
        maxPods: 30
        minCount: 1
        maxCount: 3
        vmSize: 'Standard_DS2_v2'
        //osDiskSizeGB: 30
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
      }
    ]
    autoScalerProfile: null
    networkProfile: networkPlugin == 'azure' ? {
      networkPlugin: 'azure'
      //outboundType: 'userDefinedRouting'
      dockerBridgeCidr: '172.16.1.1/30'
      dnsServiceIP: '192.168.100.10'
      serviceCidr: '192.168.100.0/24'
      networkPolicy: 'calico'
    }:{
      networkPlugin: 'kubenet'
      //outboundType: 'userDefinedRouting'
      dockerBridgeCidr: '172.16.1.1/30'
      dnsServiceIP: '192.168.100.10'
      serviceCidr: '192.168.100.0/24'
      networkPolicy: 'calico'
      podCidr: '172.17.0.0/16'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
      //privateDNSZone: privateDNSZoneId
      enablePrivateClusterPublicFQDN: false
    }
    enableRBAC: false
    // aadProfile: {
    //   adminGroupObjectIDs: aadGroupdIds
    //   enableAzureRBAC: true
    //   managed: true
    //   tenantID: subscription().tenantId
    // }
    addonProfiles: {
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logworkspaceid
        }
        enabled: true
      }
      azurepolicy: {
        enabled: true
      }
      // ingressApplicationGateway: {
      //   enabled: true
      //   config: {
      //     applicationGatewayId: appGatewayResourceId
      //     effectiveApplicationGatewayId: appGatewayResourceId
      //   }
      // }
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
    }
  }
}

output kubeletIdentity string = aksCluster.properties.identityProfile.kubeletidentity.objectId
//output ingressIdentity string = aksCluster.properties.addonProfiles.ingressApplicationGateway.identity.objectId
output keyvaultaddonIdentity string = aksCluster.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
