test storageTest 'storageaccount.bicep' = {
  params: {
    name: 'StorageV2'
    location: 'uksouth'
    environment: 'prd'
    expectedAbbreviation: 'uks'
  }
}

test failStorage 'storageaccount.bicep' = {
  params: {
    name: 'BlobS-torage'
    location: 'northeurope'
    environment: 'prd'
    expectedAbbreviation: 'we'
  }
}
