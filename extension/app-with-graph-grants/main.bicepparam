using './main.bicep'

param displayName = 'app-bicep-graoh-scope'
param setscopes = true
param appScopes = [
  'profile'
  'User.Read'
  'AdministrativeUnit.Read.All'
]

