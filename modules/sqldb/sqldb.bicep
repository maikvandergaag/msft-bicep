metadata info = {
  title: 'SQL Server Database Module'
  description: 'Module for creating a SQL Server database in an existing SQL Server instance.'
  version: '0.0.1'
  author: 'Maik van der Gaag'
}

@description('The name for the SQL Server database.')
param name string

@description('The name of the SQL Server')
param sqlServerName string

@description('The location for the SQL Server database.')
param location string = resourceGroup().location

@allowed([
  'tst'
  'acc'
  'prd'
  'dev'
])
@description('The environment were the service is beign deployed to (tst, acc, prd, dev)')
param environment string

@description('The database tier (Basic, Standard, Premium)')
param tier string = 'Standard'


resource sqlServer 'Microsoft.Sql/servers@2022-11-01-preview' existing = {
  name: sqlServerName
}

resource sqldb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: 'azsqldb-${name}-${environment}'
  location: location
  sku: {
    name: tier
    tier: tier
  }
}

output sqlServer string = sqlServer.properties.fullyQualifiedDomainName
output sqldbName string = sqldb.name
