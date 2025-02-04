extension microsoftGraphV1

@description('Provide a friendly display name for the app')
param displayName string = 'app-bicep-graph'

@description('Provide an array of Microsoft Graph scopes like "User.Read"')
param appScopes array = ['profile','User.Read']

param setscopes bool = true

var graphAppId = '00000003-0000-0000-c000-000000000000'

var graphScopes = msGraphSP.oauth2PermissionScopes

var filteredScopes = filter(graphScopes, scope => contains(appScopes, scope.value))

resource msGraphSP 'Microsoft.Graph/servicePrincipals@v1.0' existing = {
  appId: graphAppId
}

module appCreateRraModule './app.bicep' = if (setscopes == true){
  name: 'appRraDeploy'
  params: {
    filteredScopes: filteredScopes
    displayName: displayName
  }
}

module appCreateGrantScopesModule './grant.bicep' = if(setscopes == false){
  name: 'appScopeGrantDeploy'
  params: {
    filteredScopes: filteredScopes
    displayName: displayName
    graphSpId: msGraphSP.id
  }
}
