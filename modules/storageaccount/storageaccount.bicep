metadata info = {
  title: 'Storage Account Module'
  description: 'Module for creating a storage account'
  version: '1.0.0'
  author: 'Maik van der Gaag'
}

@description('The name of the storageaccount will be in the format azstr[name][environment]')
param name string

@description('The location of the storageaccount')
param location string = resourceGroup().location

@description('The SKU of the storage account')
param storageSKU string = 'Standard_LRS'
@allowed([
  'tst'
  'acc'
  'p'
  'd'
])
@description('The environment were the service is beign deployed to (tst, acc, prd, dev)')
param environment string

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'azstr${name}${environment}'
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource storage1 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'azstr${name}${environment}'
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

output name string = storage.name
