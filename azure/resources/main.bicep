param config object
param location string = resourceGroup().location

module AKS './main-modules/AKS/main.bicep' = if(contains(config, 'AKS')){
  name: aks.name
  params: {
    location: location
    config: config
   }
}
