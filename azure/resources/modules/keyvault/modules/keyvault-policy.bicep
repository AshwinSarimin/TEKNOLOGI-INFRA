param servicePrincipalId string
param keyvaultName string
param permissionsGet object
param permissionsManage object
param permissionsServicePrincipal object
param managedIdentities array = []
param aadObjects array = []

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
}

resource managedIdentitiesArray 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = [for (identity, index) in managedIdentities: {
  name: identity.name
  scope: resourceGroup(identity.ResourceGroupName)
}]

module accessPolicyIdentities 'construct-policy.bicep' = [for (identity, index) in managedIdentities: {
  name: '${keyvault.name}-${identity.name}'
  params: {
    keyVaultName: keyvault.name
    permissions: (identity.permissions == 'get') ? permissionsGet : permissionsManage
    objectId: managedIdentitiesArray[index].properties.principalId
  }
}]


module aadObjectsIdentities 'construct-policy.bicep' = [for identity in aadObjects: {
  name: '${keyvault.name}-${identity.name}'
  params: {
    keyVaultName: keyvault.name
    permissions: (identity.permissions == 'get') ? permissionsGet : permissionsManage
    objectId: identity.objectId
  }
}]

module servicePrincipal 'construct-policy.bicep' = if(!empty(servicePrincipalId)) {
  name: '${keyvault.name}-servicePrincipal'
  params: {
    keyVaultName: keyvault.name
    permissions: permissionsServicePrincipal
    objectId: servicePrincipalId
  }
}
