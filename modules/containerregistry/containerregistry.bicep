metadata info = {
  title: 'Container Registry Module'
  description: 'Module for creating a new container registry, this module will also create a lock on the resource group.'
  version: '0.0.2'
  author: 'Maik van der Gaag'
}
@description('The name for the Azure Container Registry.')
param name string
@allowed([
  'tst'
  'acc'
  'prd'
  'dev'
])
@description('The environment were the service is beign deployed to (tst, acc, prd, dev)')
param environment string
@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' = {
  name: 'azcr${name}${environment}'
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: '${name}-lock'
  properties: {
    level: 'CanNotDelete'
    notes: 'Please do not delete this resource group.'
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
