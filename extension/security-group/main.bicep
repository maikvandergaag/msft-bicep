targetScope = 'tenant'

extension microsoftGraphV1

param users array = []

param owners array = []

param name string = 'default'

var groupName = 'sg-${name}'

resource userList 'Microsoft.Graph/users@v1.0' existing = [for upn in users: {
  userPrincipalName: upn
}]

resource ownerList 'Microsoft.Graph/users@v1.0' existing = [for upn in owners: {
  userPrincipalName: upn
}]

// create security group and add user list as members
resource group 'Microsoft.Graph/groups@v1.0' = {
  displayName: groupName
  mailEnabled: false
  mailNickname: uniqueString(groupName)
  securityEnabled: true
  uniqueName: groupName
  owners: [for i in range(0, length(owners)): ownerList[i].id]
  members: [for i in range(0, length(users)): userList[i].id]
}

output groupName string = group.displayName
output groupId string = group.id
