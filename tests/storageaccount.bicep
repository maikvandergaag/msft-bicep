  metadata info = {
    title: 'Storage Account'
    description: 'Module for creating a storage account'
    version: '1.0.0'
    author: 'Maik van der Gaag'
  }

  import { getLocationAbbreviation } from '../functions/naming.bicep'

  @description('The name of the storageaccount will be in the format st[name][environment]')
  param name string

  @description('The location of the storageaccount')
  param location string = resourceGroup().location

  @description('The SKU of the storage account')
  param storageSKU string = 'Standard_LRS'

  @allowed([
    'tst'
    'acc'
    'prd'
    'dev'
  ])
  @description('The environment were the service is beign deployed to (tst, acc, prd, dev)')
  param environment string

  var storageName  = 'st${name}${environment}${abbrev}'

//Test
  param expectedAbbreviation string = ''
  var abbrev = getLocationAbbreviation(location)

  assert nameHyphen = !contains(storageName, '-')
  assert containsEnv = contains(storageName, environment)
  assert checkAbbreviation = abbrev == expectedAbbreviation

  resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
    name: storageName
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

  output storageAccountName string = storage.name
