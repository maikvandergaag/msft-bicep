<#
.SYNOPSIS
    Script to calculate the next template spec version

.DESCRIPTION
    Based on the existing version a new version number will be calculated
    Author: Maik van der Gaag
    Date: 22-06-2021


.PARAMETER TemplateSpecName
    The name of the template spec

.PARAMETER ResourceGroupName
    The name of the resource group for the specs


.EXAMPLE
    .\Get-TemplateSpecVersion.ps1 -TemplateSpecName "tempspec" -ResourceGroupName "rg-test"
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [String]$TemplateSpecName,
    [Parameter(Mandatory = $true)]
    [String]$ResourceGroupName,
    [Switch]$ADO
)

process {
    $version = (Get-AzTemplateSpec -Name "$TemplateSpecName" -ResourceGroupName "$ResourceGroupName" -ErrorAction SilentlyContinue).Versions
    if ($version) {
        $version = $version[$version.length - 1].Name
        $version = [string]$version
        $minor = [int]$version.Split('.')[1]
        $major =
        [int]$version.Split('.')[0]
        $minor = $minor + 1
        if ($minor -eq 9) {
            $major = $major + 1
            $minor = 0
        }
        $versionNumber = "$($major).$($minor)"
    }
    else {
        $versionNumber = "0.1"
    }

    Write-Output "New versionnumber will be: $($versionNumber)"
    if ($ADO) {
        Write-Host "##vso[task.setvariable variable=versionnumber]$versionNumber"
    }
    else {
        echo "::set-output name=versionnumber::$versionNumber"
    }
}