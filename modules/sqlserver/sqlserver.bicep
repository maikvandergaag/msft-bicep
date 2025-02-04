metadata info = {
  title: 'SQL Server Module'
  description: 'Module for creating a SQL Server instance'
  version: '0.0.1'
  author: 'Maik van der Gaag'
}

@allowed([
  'tst'
  'acc'
  'prd'
  'dev'
])
@description('The environment were the service is beign deployed to (tst, acc, prd, dev)')
param environment string

@description('The location of the resource (e.g. westeurope, northeurope, etc.)')
param location string = resourceGroup().location

@description('The name of the resource (e.g. my-resource)')
param name string

@description('The owner of the resource (e.g. support@3fifty.eu)')
param owner string

@description('The purpose of the resource (e.g. my-resource)')
param purpose string

@description('The id of the group that will be added as an administrator to the SQL Server instance')
param groupId string

@description('Allow access to Azure services (e.g. true, false)')
param allowAzureServices bool = true

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' ={
  name: 'azsql-${name}-${environment}'
  location: location
  tags: {
    environment: environment
    purpose: purpose
    owner: owner
  }
  properties: {
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'AADGroup'
      sid: groupId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
  }
}

resource allowAccessToAzureServices 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = if(allowAzureServices) {
  name: 'allow-access-to-azure-services'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

@description('The name of the SQL Server instance')
output sqlServerName string = sqlServer.name
