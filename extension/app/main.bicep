extension microsoftGraphV1

@description('Specifies the name of the key vault.')
param name string

@description('Specifies the unique name for the client application')
var clientAppName = 'app-${name}'


resource clientApp 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: clientAppName
  displayName: 'Example Client Application'
}

resource clientSp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: clientApp.appId
}

output clientAppId string = clientApp.appId
