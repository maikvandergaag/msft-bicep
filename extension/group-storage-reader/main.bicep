extension microsoftGraphV1

param location string = resourceGroup().location

param owners array = []

param name string = 'default'

@description('Specify the storage blob reader role definition ID')
param readerRoleDefinitionId string = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

var roleAssignmentName = guid(resourceGroup().id, groupName, storageName)

var groupName = 'sg-${name}'

var storageName = 'stgraphtest${name}'

var identityName = 'id-${name}'

resource ownerList 'Microsoft.Graph/users@v1.0' existing = [for upn in owners: {
  userPrincipalName: upn
}]

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties:{
    minimumTlsVersion: 'TLS1_2'
  }
}

resource readerGroup 'Microsoft.Graph/groups@v1.0' = {
  displayName: groupName
  mailEnabled: false
  mailNickname: uniqueString(groupName)
  securityEnabled: true
  uniqueName: groupName
  owners: [for i in range(0, length(owners)): ownerList[i].id]
  members:[webIdentity.properties.principalId]
}

resource webIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

resource readersRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: roleAssignmentName
  properties: {
    principalId: readerGroup.id
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', readerRoleDefinitionId)
  }
}
