param name string
param ownerOnResourceGroup bool
param location string = resourceGroup().location

module managedIdentity 'modules/managed-identity.bicep' = {
  name: name
  params: {
    name: name
    location: location
    ownerOnResourceGroup: ownerOnResourceGroup
  }
}
