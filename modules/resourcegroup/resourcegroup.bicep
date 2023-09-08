targetScope = 'subscription'

metadata info = {
  title: 'Resource Group Module'
  description: 'Module for creating a new resource group with specific tags and naming convention'
  version: '0.0.4'
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

@description('The location where the resource group will be created')
param location string = deployment().location

@description('The name of the resource group will be in the format rg-[name]-[environment]')
param name string

@description('The owner of the resource group')
param owner string

@description('The purpose of the resource group')
param purpose string

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${name}-${environment}'
  location: location
  tags:{
    environment: environment
    owner: owner
    purpose: purpose
  }
}

output rgId string = rg.id
output name string = rg.name


