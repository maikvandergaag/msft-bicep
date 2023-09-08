metadata info = {
  title: 'Example file for showing br modules in Bicep'
  description: 'Bicep template to use BR modules'
  version: '0.0.1'
  author: 'Maik van der Gaag'
}

@description('Name for the storage account')
param name string

@description('Location for the storage account')
param location string = resourceGroup().location

module moduleTemplateSpec 'br/myregistry:storageaccount:0.0.1' ={
  name: 'moduleTemplateSpecMinimal'
  params:{
    name: name
    environment: 'prd'
    location: location
  }
}

module moduleTemplateSpecFull 'br:azcrbicepregistryiacprd.azurecr.io/modules/storageaccount:0.0.1' ={
  name: 'moduleTemplateSpecFull'
  params:{
    name: name
    environment: 'prd'
    location: location
  }
}
