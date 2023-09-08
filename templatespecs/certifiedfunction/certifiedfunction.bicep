metadata info = {
  title: 'Certified Function App'
  description: 'Bicep template to deploy a function app with log analytics and application insights'
  version: '0.0.1'
  author: 'Maik van der Gaag'
}

@description('The name for the function')
param name string

@allowed([
  'tst'
  'acc'
  'prd'
  'dev'
])
@description('The environment were the service is beign deployed to (tst, acc, prd, dev)')
param environment string

module function 'br/myregistry:functionapp:0.0.1' ={
  name: 'functionapp'
  params:{
    environment: environment
    name: name
    location: 'westeurope'
  }
}

module loganalytics 'br/myregistry:loganalytics:0.0.1' ={
  name: 'loganalytics'
  params: {
    name: name
    environment: environment
  }
}

module appInsights 'br/myregistry:applicationinsights:0.0.1' ={
  name: 'applicationinsights'
  params: {
    name: name
    environment: environment
    logAnalyticsWorkspaceId: loganalytics.outputs.workspaceId
  }
}

module appConfig 'br/myregistry:appconfiguration:1.0.0' = {
  name: 'appconfig'
  params: {
    appName: function.outputs.functionAppName
    existingAppSettings: list(resourceId('Microsoft.Web/sites/config', 'azfunc-${name}-${environment}', 'appsettings'), '2022-03-01').properties
    appSettings:{
      APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.outputs.InstrumentationKey
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.outputs.ConnectionString
    }
  }
}