<#
.SYNOPSIS
    Script for adding and updating Wiki pages

.DESCRIPTION
    With this PowerShell script markdown files can be added to the Wiki.
    Author: Maik van der Gaag
    Date: 27-03-2023

.PARAMETER WikiUri
    The Url of the wiki to update

.PARAMETER DevOpsPat
    The Azure DevOps Personal Access Token

.PARAMETER MarkDownFolder
    The folder with the markdown files to add to the wiki

.PARAMETER ParentPage
    The filename of the parent page that should be used in the Wiki

.PARAMETER Path
    Reference to an existing path

.EXAMPLE
    .\New-WikiPages.ps1 -WikiUri "https://dev.azure.com/Organization/Cloud Governance/_apis/wiki/wikis/Azure-Governance.wiki/" -DevOpsPat "jhfadkjhfakjhfkjasdfhuvinak" -MarkDownFolder "D:\temp\"

.NOTES
    Version:        1.0.0;
    Author:         3fifty;
    Creation Date:  26-01-2023;
    Purpose/Change: Initial script development;
#>

[CmdletBinding()]

Param (
    [Parameter(Mandatory = $true, Position = 0)][string]$WikiUri,
    [Parameter(Mandatory = $false, Position = 1)][string]$DevOpsPat,
    [Parameter(Mandatory = $true, Position = 2)][string]$MarkDownFolder,
    [Parameter(Mandatory = $false, Position = 3)][string]$ParentPage,
    [Parameter(Mandatory = $false, Position = 4)][string]$Path,
    [Parameter(Mandatory = $false, Position = 5)][bool]$SystemAccessToken = $false
)

BEGIN {
    Write-Host ("Start updating Wiki with new documentation")
    Write-Host ("# Wiki Uri: $($WikiUri)")
    Write-Host ("# Markdown folder: $($MarkDownFolder)")
    Write-Host ("# Parent page: $($ParentPage)")
    Write-Host ("# Path: $($Path)")
    Write-Host ("# SystemAccessToken: $($SystemAccessToken)")
    Write-Host ("# DevOpsPat: $($DevOpsPat)")

    function Get-WikiPageRef {
        Param(
            [Parameter(Mandatory = $true, Position = 0)][string]$WikiUri,
            [Parameter(Mandatory = $true, Position = 1)][hashtable]$RequestHeader,
            [Parameter(Mandatory = $true, Position = 2)][string]$Name,
            [Parameter(Mandatory = $false, Position = 3)][string]$TopItem,
            [Parameter(Mandatory = $false, Position = 4)][string]$Path
        )
    
        BEGIN {
            if ($Path) { $uripath = ("$($Path)/") }
            if ($TopItem) { $uripath += $TopItem.Replace(".md", "") + "/" + $Name } else { $uripath += $Name }
            $uri = $WikiUri + "/pages?path=/$($uripath)&api-version=5.1"
            $params = @{uri = "$($uri)";
                Method      = 'Get';
                Headers     = $RequestHeader
                ContentType = "application/json";
                Body        = $data;
            }
        }
        PROCESS {
            try {
                $response = Invoke-WebRequest @params
                if ($response) {
                    $etag = $response.Headers.ETag[0]
                }
                return $etag
            }
            catch {
                Write-Information "Wiki page does not exist $($Name)."
                return $null;
            }
        }
        END {
            Write-Information ("Done getting reference page.")
        }
    }
    
    function Update-WikiPage {
        Param(
            [Parameter(Mandatory = $true, Position = 0)][string]$WikiUri,
            [Parameter(Mandatory = $true, Position = 1)][hashtable]$RequestHeader,
            [Parameter(Mandatory = $true, Position = 2)][string]$Content,
            [Parameter(Mandatory = $true, Position = 3)][string]$Name,
            [Parameter(Mandatory = $false, Position = 4)][string]$TopItem,
            [Parameter(Mandatory = $false, Position = 5)][string]$Path
        )
    
        BEGIN {
            Write-Host ("Trying to add Wiki page: $($Name)")
        }
        PROCESS {
            if ($Path) { $uripath = $Path + "/" }
            if ($TopItem) { $uripath += $TopItem.Replace(".md", "") + "/" + $Name } else { $uripath += $Name }
            $uri = $WikiUri + "/pages?path=/$($uripath)&api-version=5.1"
    
            $params = @{uri = "$($uri)";
                Method      = 'PUT';
                Headers     = $RequestHeader
                ContentType = "application/json";
                Body        = $Content;
            }
    
            $response = Invoke-WebRequest @params
            if ($response.StatusCode -eq "200" -or $response.StatusCode -eq "201") {
                Write-Host "Successfully added page $($file.BaseName)"
            }
        }
        END {
            Write-Host ("Done adding Wiki page: $($Name)")
        }
    }
    if ($SystemAccessToken) {
        Write-Host ("Using SystemAccessToken to authenticate to Azure DevOps")
        $AzureDevOpsAuthenicationHeader = @{Authorization = 'Bearer ' + $env:SYSTEM_ACCESSTOKEN }
    }
    else {
        Write-Host ("Using Personal Access Token to authenticate to Azure DevOps")
        $AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($DevOpsPat)")) }
    }
}
PROCESS {
    if ($ParentPage) {
        $markdown = Get-Childitem $MarkDownFolder -Filter $ParentPage
        $content = Get-Content $markdown.FullName;

        $markdownName = $ParentPage.Replace(".md", "").Replace(" ", "-")
        
        $ref = Get-WikiPageRef -WikiUri $WikiUri -RequestHeader $AzureDevOpsAuthenicationHeader -Name $markdownName -Path $Path

        if ($ref) { $AzureDevOpsAuthenicationHeader.Add("If-Match", $ref); }

        $markdownBody = ""
        foreach ($line in $content) {
            $markdownBody += $line + "\n"
        }

        $data = @{content = "$markdownBody"; } | ConvertTo-Json;
        $data = $data.Replace("\\n", "\n")

        Update-WikiPage -Name $markdownName -WikiUri $WikiUri -RequestHeader $AzureDevOpsAuthenicationHeader -Content $data -Path $Path
    }

    $markdown = Get-Childitem $MarkDownFolder -Filter "*.md"
    foreach ($file in $markdown) {
        if ($SystemAccessToken) {
            Write-Host ("Using SystemAccessToken to authenticate to Azure DevOps")
            $AzureDevOpsAuthenicationHeader = @{Authorization = 'Bearer ' + $env:SYSTEM_ACCESSTOKEN }
        }
        else {
            Write-Host ("Using Personal Access Token to authenticate to Azure DevOps")
            $AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($DevOpsPat)")) }
        }
        
        if (!($file.Name -eq $ParentPage)) {

            $ref = Get-WikiPageRef -WikiUri $WikiUri -RequestHeader $AzureDevOpsAuthenicationHeader -Name $file.BaseName -TopItem $markdownName -Path $Path

            if ($ref) { $AzureDevOpsAuthenicationHeader.Add("If-Match", $ref); }

            $content = Get-Content $file.FullName;

            $markdownBody = ""
            foreach ($line in $content) {
                $markdownBody += $line + "\n"
            }

            $data = @{content = "$markdownBody"; } | ConvertTo-Json;
            $data = $data.Replace("\\n", "\n")

            Update-WikiPage -Name $file.BaseName -WikiUri $WikiUri -RequestHeader $AzureDevOpsAuthenicationHeader -Content $data -TopItem $markdownName -Path $Path
        }
    }
}
END {
    Write-Host ("Done processing Wiki pages.")
}