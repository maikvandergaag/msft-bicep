@export()
func getLocationAbbreviation(location string) string => getAbbreviationLocation()[location]

func getAbbreviationLocation() object => {
  northeurope: 'ne'
  westeurope: 'we'
  uksouth: 'uks'
}
