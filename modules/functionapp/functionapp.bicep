metadata info = {
  title: 'Function app module'
  description: 'Module for a Azure Function App'
  version: '1.0.1'
  author: 'Maik van der Gaag'
}

@description('The name of the function app')
param name string

@allowed([
  'tst'
  'prd'
  'dev'
  'acc'
])
@description('The environment were the service is beign deployed to (tst, acc, prd, dev)')
param env string

@description('The location of the function app')
param location string = resourceGroup().location

@description('Additional app settings')
param appSettings object = {}

var functionname = 'azfunc-${name}-${env}'

resource azhst 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'azhst-${name}-${env}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functionapp'
}

resource functionapp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionname
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: azhst.id
    clientAffinityEnabled: true
    siteConfig: {
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: true
      alwaysOn: false
      netFrameworkVersion: 'v6.0'
      minTlsVersion: '1.2'
    }
  }
}

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionapp
  name: 'appsettings'
  properties: union({
    AzureWebJobsStorage:'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
    WEBSITE_CONTENTSHARE: toLower(functionname)
  }, appSettings)
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'azstr${name}${env}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

output functionAppName string = functionapp.name
output hostingId string = azhst.id
output functionStorageName string = storageAccount.name
output functionAppIdentityId string = functionapp.identity.principalId
output customDomainVerificationId string = functionapp.properties.customDomainVerificationId
