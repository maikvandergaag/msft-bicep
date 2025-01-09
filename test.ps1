# Define the base directory to search for Bicep files
$baseDir = "D:\src\github\msft-bicep"

# Find all Bicep files in the base directory
$bicepFiles = Get-ChildItem -Path $baseDir -Recurse -Filter *.bicep

# Initialize an array to store the combined SARIF results
$combinedSarif = @()

# Iterate through each Bicep file and run the bicep lint command
foreach ($file in $bicepFiles) {
    $lintResult = bicep lint $file.FullName --diagnostics-format sarif | ConvertFrom-Json
    if ($lintResult -ne "") {

        if($combinedSarif){
            foreach($result in $lintResult.runs[0].results){
                $combinedSarif.runs[0].results += $result
            }
        }else{
            $combinedSarif = $lintResult
        }
    }
}

$combinedSarif