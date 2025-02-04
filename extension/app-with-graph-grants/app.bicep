extension microsoftGraphV1


param displayName string
param filteredScopes array

var graphAppId = '00000003-0000-0000-c000-000000000000'

resource myApp 'Microsoft.Graph/applications@v1.0' = {
  displayName: displayName
  uniqueName: displayName
  requiredResourceAccess: [
    {
      resourceAppId: graphAppId
      resourceAccess: [ for (scope, i) in filteredScopes: {
          id: filteredScopes[i].id
          type: 'Scope'
        }
      ]
    }
  ]
}
