@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = 'westeurope'

targetScope = 'subscription'
param resourcePrefix string = 'aksbicep1'
var resourceGroupName = '${resourcePrefix}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}
module aksC 'modules/aks-cluster.bicep' =  [for aks in config.aks: {
  name: '${resourcePrefix}cluster'
  scope: rg
  params: {
    location: location
    clusterName: resourcePrefix
  }
}
]
