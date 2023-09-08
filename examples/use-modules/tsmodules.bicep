metadata info = {
  title: 'Example file for showing ts modules in Bicep'
  description: 'Bicep template to use ts modules'
  version: '0.0.1'
  author: 'Maik van der Gaag'
}

@description('Name for the storage account')
param name string

@description('Location for the storage account')
param location string = resourceGroup().location

module moduleTemplateSpec 'ts/specs:az-tempspec-certifiedstorage:0.1' ={
  name: 'moduleTemplateSpec'
  params:{
    storageName: name
    location: location
  }
}
