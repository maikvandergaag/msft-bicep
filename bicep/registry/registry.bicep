targetScope = 'subscription'

metadata info = {
  title: 'Container Registry deployment'
  description: 'Bicep template for deploying a container registry'
  version: '0.0.1'
  author: '3fifty'
}

param location string = deployment().location
param owner string = 'support@3fifty.eu'
@allowed([
  'tst'
  'acc'
  'prd'
  'dev'
])
param environment string
param name string
param purpose string
param category string


resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'gaag-rg-${name}-${environment}'
  location: location
  tags:{
    environment: environment
    owner: owner
    usage:purpose
    clean: 'false'
    category: category
  }
}

module registry '../../modules/containerregistry/containerregistry.bicep'={
  name: 'containerregistry'
  params:{
    name: 'bicepregistry${name}'
    environment: environment
    location: location
  }
  scope:rg
}
