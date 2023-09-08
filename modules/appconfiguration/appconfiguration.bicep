metadata info = {
  title: 'Application Settings Module'
  description: 'Module for specific Application Settings'
  version: '1.0.0'
  author: 'Maik van der Gaag'
}

@description('The name of the app you want to add the settings to')
param appName string

@description('The app settings you want to add to the app (key:value)')
param appSettings object


@description('The app existing settings you want to add to the app (key:value)')
param existingAppSettings object

resource app 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appName
}

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: app
  name: 'appsettings'
  properties: union(existingAppSettings, appSettings)
}
