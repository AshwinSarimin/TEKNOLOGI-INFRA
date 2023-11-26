// ================ //
// Parameters       //
// ================ //

@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = [for (account, index) in config.automationAccounts: if(contains(config.automationAccounts[index], 'managedIdentity')) {
  name: account.managedIdentity.name
  scope: contains(account.managedIdentity, 'resourceGroup') ? resourceGroup(account.managedIdentity.resourceGroup) : resourceGroup()
}]

module automationAccount 'modules/automation-account.bicep' = [for (account, index) in config.automationAccounts: {
  name: account.name
  params: {
    name: account.name
    location: location
    managedIdentityId: managedIdentity[index].id
    sku: account.sku
  }
  dependsOn:[
    managedIdentity
  ]
}]

module runBook 'modules/runbook.bicep' =  [for (account, index) in config.automationAccounts: {
  name: account.runbook.name
  params: {
    name: account.runbook.name
    automationAccountName: account.name
    location: location
    storageAccountName: account.runbook.storageAccountName
    containerName: account.runbook.containerName
    script: account.runbook.script
    scriptType: account.runbook.scriptType
  }
  dependsOn:[
    automationAccount
  ]
}]
module schedule 'modules/schedule.bicep' =  [for (account, index) in config.automationAccounts: {
  name: '${account.runbook.name}-schedule'
  params: {
    name: account.runbook.schedule.name
    automationAccountName: account.name
    frequency: account.runbook.schedule.frequency
  }
  dependsOn:[
    runBook
  ]
}]


module scheduleJob 'modules/job-schedule.bicep' =  [for (account, index) in config.automationAccounts: {
  name: '${account.runbook.name}-jobSchedule'
  params: {
    runbookName: account.runbook.name
    scheduleName: account.runbook.schedule.name
    automationAccountName: account.name
    parameters: account.runbook.parameters
    principalId: managedIdentity[index].properties.principalId
  }
  dependsOn:[
    schedule
  ]
}]
