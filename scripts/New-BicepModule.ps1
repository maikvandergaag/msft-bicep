<#
.SYNOPSIS
    Script to deploy a new bicep module based on the version in the metadata.json file

.DESCRIPTION
    Script to deploy a new bicep module based on the version in the metadata.json file
    Author: Maik van der Gaag
    Date: 23-01-2023

.PARAMETER Path
    The path to the folder containing the bicep module

.PARAMETER Registry
    The name of the container registry to deploy the module to

.EXAMPLE
    .\new-bicepmodule.ps1 -Path "C:\temp\mybicepmodule" -Registry "myregistry"
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [String]$Path,
    [Parameter(Mandatory = $true)]
    [String]$Registry
)
BEGIN{
    Write-Host "- Started deployment to registry $($Registry)"
    $baseRepository = "modules"
}
PROCESS {

    $folders = Get-ChildItem -Path $Path -Directory

    foreach($folder in $folders)
    {
        Write-Host "# Processing folder: $($folder.Name)"

        $bicepFile = Get-ChildItem -Path $folder.FullName -File -Filter "*.bicep"

        az bicep build --file $bicepFile
        $fileName = $bicepFile.FullName.Replace(".bicep", ".json")
        $templateContent = Get-Content $fileName -Raw -ErrorAction Stop
        $templateObject = ConvertFrom-Json $templateContent -ErrorAction Stop

        $version = ""
        if (!$templateObject) {
            Write-Error -Message ("Template file is not a valid one, please review the template.")
        }
        else {
            # process the metadata of the file
            if ((($templateObject | get-member).name) -match "metadata") {
                $metadataProperties = $templateObject.metadata | Get-Member | Where-Object { $_.Name -eq "info" }
                if ($metadataProperties) {

                    $version = $templateObject.metadata.info.version
                }
                else {
                    Write-Verbose ("No metadata properties object found with the name 'info'")
                }
            }
        }

        Write-Host "## Working with version: $($version) for module: $($bicepFile.BaseName)";
        $repository = "$($baseRepository)/$($bicepFile.BaseName)"
        $bicepFilePath = "$($bicepFile.FullName)"

        $exists = az acr repository show-tags --name $Registry --repository $repository --detail --top 1 --orderby time_desc | ConvertFrom-Json -Depth 10
        $registryLocation = "br:$($Registry).azurecr.io/$($repository):$($version)"

        $update = $false
        if($exists){
            $tag = $exists.name -eq $version
            if($tag){
                Write-Host "## Version: $($version) already exists for module: $($bicepFile.BaseName)" -ForegroundColor Yellow
            }
            else{
                Write-Host "## Version: $($version) does not exist for module: $($bicepFile.BaseName)"
                $update = $true
            }
        }
        else{
            Write-Host "## Module: $($bicepFile.BaseName) does not exist"
            $update = $true
        }

        if($update){
            #Publish-AzBicepModule -FilePath $bicepFilePath -Target $registryLocation
            az bicep publish --file $bicepFilePath --target $registryLocation
        }
        Write-Host "# Finished processing folder: $($folder.Name)"
    }
}
END{
    Write-Host "- Done with deployment to registry $($Registry)"
}