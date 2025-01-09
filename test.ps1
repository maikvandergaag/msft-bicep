$report = ""

$lintResult = bicep lint "D:\src\github\msft-bicep\modules\storageaccount\storageaccount.bicep" --diagnostics-format sarif | ConvertFrom-Json
              if ($lintResult -ne "") {
                foreach ($run in $lintResult.runs) {
                    $report += "### $file"
                    foreach ($result in $run.results) {
                        $message = $result.message.text
                        $level = $result.level

                        if($level -eq "error") {
                            $hasErrors = $true
                        }
                        foreach ($location in $result.locations) {
                            $lineNumber = $location.physicalLocation.region.startLine
                        }
                        $report += "$($level) - $($message) - Line: $($lineNumber)"
                    }
                }
              }

              Write-Host $report