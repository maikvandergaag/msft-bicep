# Define the base directory to search for Bicep files
$baseDir = "D:\src\github\msft-bicep"

# Find all Bicep files in the base directory
$files = Get-ChildItem -Path $baseDir -Recurse -Filter *.bicep | Select-Object -ExpandProperty FullName

$report = @()
$report += "## Bicep Linting Report :rocket:"
$createSarif = $true
$combinedSarif = @()

if ($files.Count -eq 0) {
    $report += "No bicep files found in the commit"
}
else {
    foreach ($file in $files) {
        Write-Output "- Linting $file"
        $sarif = bicep lint $file --diagnostics-format sarif | ConvertFrom-Json

        foreach ($run in $sarif.runs) {
            $report += "**$($file)**"

            foreach ($result in $run.results) {

                if ($null -eq $combinedSarif.runs -and $createSarif) {
                    $combinedSarif = $sarif
                }else {
                    if ($createSarif) {
                        $combinedSarif.runs[0].results += $result
                    }
                    
                    $level = switch ($result.level) {
                        "error" { ":triangular_flag_on_post:" }
                        "warning" { ":warning:" }
                        default { ":information_source:" }
                    }
                    foreach ($location in $result.locations) {
                        $report += "* $($level) - **Line:** $($location.physicalLocation.region.startLine) - $($result.message.text)"
                    }
                }                
            }
        }
    }
}

if ($combinedSarif -and $createSarif) {
    Write-Output "Creating SARIF file"
    $combinedSarif | ConvertTo-Json -Depth 100 | Out-File -FilePath "bicep-lint.sarif"
}

$report | Out-File -FilePath "bicep-lint-report.md"