extension microsoftGraphV1
param displayName string
param filteredScopes array
param graphSpId string

var scopeArray = [for (scopeItem,i) in filteredScopes: filteredScopes[i].value]
var scopeString = join(scopeArray, ' ')

resource myApp 'Microsoft.Graph/applications@v1.0' = {
  displayName: displayName
  uniqueName: displayName
}

resource mySP 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: myApp.appId
}

resource graphScopesAssignment 'Microsoft.Graph/oauth2PermissionGrants@v1.0' =  {
  scope: scopeString
  clientId: mySP.id
    resourceId: graphSpId
    consentType: 'AllPrincipals'
}
