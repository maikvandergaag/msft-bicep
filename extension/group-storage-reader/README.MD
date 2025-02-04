# Application with Certificate

To deploy:

CLI

```sh
az deployment group create --resource-group 'rg-bicep-graph' --template-file .\main.bicep --parameter .\main.bicepparam --verbose
```

Azure PowerShell

```powershell
New-AzResourceGroupDeployment -ResourceGroupName 'rg-bicep-graph' -TemplateFile .\main.bicep -TemplateParameterFile .\main.bicepparam -Verbose
```
