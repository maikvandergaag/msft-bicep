<#
.SYNOPSIS
    Script for generating Markdown documentation based on Bicep files

.DESCRIPTION
    With this PowerShell script Markdown documentation is automatically generated from bicep files

.PARAMETER TemplateFolder
    The folder that contains the Bicep files

.PARAMETER OutputFolder
    The folder were to safe the markdown files

.PARAMETER IndexFileName
    The name for the files that contains the index of all Templates.

.NOTES
    Version:        1.0.0;
    Author:         3fifty
    Creation Date:  23-01-2023;
    Purpose/Change: Initial script development;

.EXAMPLE
    .\New-BicepDocs.ps1 -TemplateFolder "C:\scripts\" -OutputFolder "C:\markdown\" -IndexFileName "Template Documentation"
#>
[CmdletBinding()]

Param (
    [Parameter(Mandatory = $true, Position = 0)][string]$TemplateFolder,
    [Parameter(Mandatory = $true, Position = 1)][string]$OutputFolder,
    [Parameter(Mandatory = $true, Position = 1)][string]$IndexFileName
)


BEGIN {

    Write-Host "Starting documentation generation"
    Write-Output ("TemplateFolder       : $($TemplateFolder)")
    Write-Output ("OutputFolder         : $($OutputFolder)")
    Write-Output ("IndexFileName        : $($IndexFileName)")

    #Setting the output folder
    $outdir = $TemplateFolder + '/temp'
    if (Test-Path -Path $outdir) {
        Write-Verbose "Tempory output folder already exists"
    }
    else {
        New-Item -ItemType Directory -Force -Path $outdir | Out-Null
    }
}
PROCESS {
    $fileName = ""
    try {
        Write-Verbose ("Staring documentation generation for folder $($TemplateFolder)")

        $templateNameSuffix = ".md"

        if (!(Test-Path $OutputFolder)) {
            Write-Verbose ("Output path does not exists creating the folder: $($OutputFolder)")
            New-Item -ItemType Directory -Force -Path $OutputFolder
        }

        $indexfile = ("$($OutputFolder)$($IndexFileName)$($templateNameSuffix)")

        # Index header
        "[[_TOC_]] `r`n" | Out-File -FilePath $indexfile

        # Get the scripts from the folder
        $templates = Get-Childitem $TemplateFolder -Filter "*.bicep" -Recurse
        foreach ($template in $templates) {
            Write-Host ("Documenting file: $($template.FullName)")
            $bicepFile = $template.FullName
        
            # Compile the bicep file
            bicep build $bicepFile --outdir $outdir

            $fileName = $outdir + '/' + $template.BaseName + '.json'

            # Test if arm template content is readable
            $templateContent = Get-Content $fileName -Raw -ErrorAction Stop
            # Convert the ARM template to an Object
            $templateObject = ConvertFrom-Json $templateContent -ErrorAction Stop

            if (!$templateObject) {
                Write-Error -Message ("Template file is not a valid one, please review the template.")
            }
            else {
                $outputFile = ("$($OutputFolder)$($template.BaseName)$($templateNameSuffix)")
                ("## $($template.BaseName)") | Out-File -FilePath $indexfile -Append

                # add index to the file
                ("[[_TOC_]] `r`n") | Out-File -FilePath $outputFile
              
                # process the metadata of the file
                if ((($templateObject | get-member).name) -match "metadata") {
                    $metadataProperties = $templateObject.metadata | Get-Member | Where-Object { $_.Name -eq "info" }          

                    if ($metadataProperties) {

                        $templateObject.metadata.info.PSObject.Properties | Where-Object { $_.Name -eq "title" } | ForEach-Object {
                            Write-Verbose ("title found. Adding to parent page and top of the template specific page")
                            (" ") | Out-File -FilePath $outputFile -Append
                            ("# $($_.Value)") | Out-File -FilePath $outputFile -Append
                        }     

                        $templateObject.metadata.info.PSObject.Properties | Where-Object { $_.Name -eq "description" } | ForEach-Object {
                            Write-Verbose ("Description found. Adding to parent page and top of the template specific page")
                            $_.Value | Out-File -FilePath $indexfile -Append
                            $_.Value | Out-File -FilePath $outputFile -Append
                        }       

                        $templateObject.metadata.info.PSObject.Properties | Where-Object { $_.Name -ne "description" -and $_.Name -ne "title" } | ForEach-Object {
                            Write-Verbose ("Metdata found. Adding to the template specific page")
                            (" ") | Out-File -FilePath $outputFile -Append
                            ("### $($_.Name) ") | Out-File -FilePath $outputFile -Append
                            $_.Value | Out-File -FilePath $outputFile -Append
                        }

                    }
                    else {
                        Write-Verbose ("No metadata properties object found with the name 'info'")
                    }
                }

                ("## Parameters") | Out-File -FilePath $outputFile -Append
                # Create a Parameter List Table
                $parameterHeader = "| Name | Type | Description | Default value | Allowed values | Required |"
                $parameterHeaderDivider = "| --- | --- | --- | --- | --- | --- |"
                $parameterRow = " | {0}| {1} | {2} | {3} | {4} | {5} |"

                $StringBuilderParameter = @()
                $StringBuilderParameter += $parameterHeader
                $StringBuilderParameter += $parameterHeaderDivider

                $StringBuilderParameter += $templateObject.parameters | get-member -MemberType NoteProperty | ForEach-Object { $parameterRow -f $_.Name , $templateObject.parameters.($_.Name).type , $templateObject.parameters.($_.Name).metadata.description, $templateObject.parameters.($_.Name).defaultValue , (($templateObject.parameters.($_.Name).allowedValues) -join ',' ), $(if ($templateObject.parameters.($_.Name).defaultValue) {"https://img.shields.io/badge/parameter-optional-green?style=flat-square"} Else {"https://img.shields.io/badge/parameter-required-orange?style=flat-square"}) }
                $StringBuilderParameter | Out-File -FilePath $outputFile -Append

                ("## Resources") | Out-File -FilePath $outputFile -Append
                # Create a Resource List Table
                $resourceHeader = "| Name | Type | "
                $resourceHeaderDivider = "| --- | --- | "
                $resourceRow = " | {0}| {1} | "

                $StringBuilderResource = @()
                $StringBuilderResource += $resourceHeader
                $StringBuilderResource += $resourceHeaderDivider

                $StringBuilderResource += $templateObject.resources | ForEach-Object { $resourceRow -f $_.Name, $_.Type }
                $StringBuilderResource | Out-File -FilePath $outputFile -Append


                if ((($templateObject | get-member).name) -match "outputs") {
                    write-verbose ("Output objects found.")
                    if (Get-Member -InputObject $templateObject.outputs -MemberType 'NoteProperty') {
                        ("## Outputs") | Out-File -FilePath $outputFile -Append
                        # Create an Output List Table
                        $outputHeader = "| Name | Type | Value | Description"
                        $outputHeaderDivider = "| --- | --- | --- | --- | "
                        $outputRow = " | {0}| {1} | {2} | {3} |"

                        $StringBuilderOutput = @()
                        $StringBuilderOutput += $outputHeader
                        $StringBuilderOutput += $outputHeaderDivider

                        $StringBuilderOutput += $templateObject.outputs | get-member -MemberType NoteProperty | ForEach-Object { $outputRow -f $_.Name , $templateObject.outputs.($_.Name).type , $templateObject.outputs.($_.Name).value, $templateObject.outputs.($_.Name).metadata.description }
                        $StringBuilderOutput | Out-File -FilePath $outputFile -Append
                    }
                }
                else {
                    write-verbose ("This file does not contain outputs")
                }

                (" ") | Out-File -FilePath $indexfile -Append
            }
        }
    }
    catch {
        if ($fileName) {
            Write-Error ("$($fileName) : $($_)")
        }
        else {
            Write-Error ("$($_)")
        }
    }
}
END {
    #Remove the temporary output folder
    $outdir = $TemplateFolder + '/temp'
    if (Test-Path -Path $outdir) {
        Remove-Item -Recurse -Force -Path $outdir | Out-Null
    }
    else {
        Write-Verbose ("$($outdir) does not exist")
    }

    Write-Host ("Documentation generated in $($OutputFolder)")
}
