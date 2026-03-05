Clear-Host

Write-Host "========================================"
Write-Host " Azure Local SBE Upgrade Path Checker"
Write-Host "========================================"
Write-Host ""

############################################
# STEP 1 - GET CLUSTER NODE LIST
############################################

$nodes = Get-ClusterNode | Select-Object -ExpandProperty Name

Write-Host "Cluster Node Version Information:`n" -ForegroundColor Cyan

$nodeInfo = foreach ($node in $nodes) {

    Invoke-Command -ComputerName $node {

        $envInfo = Get-SolutionUpdateEnvironment

        [PSCustomObject]@{
            NodeName        = $env:COMPUTERNAME
            SolutionVersion = $envInfo.CurrentVersion
            SBEVersion      = $envInfo.CurrentSbeVersion
            HardwareModel   = $envInfo.HardwareModel
        }
    }
}

$nodeInfo | Format-Table NodeName,SolutionVersion,SBEVersion,HardwareModel -AutoSize
Write-Host ""

############################################
# STEP 2 - VERIFY VERSIONS MATCH
############################################

$solutionVersions = $nodeInfo.SolutionVersion | Select-Object -Unique
$sbeVersions      = $nodeInfo.SBEVersion | Select-Object -Unique

if ($solutionVersions.Count -gt 1) {

    Write-Host "ERROR: Solution Version mismatch across cluster!" -ForegroundColor Red
}

if ($sbeVersions.Count -gt 1) {

    Write-Host "ERROR: SBE Version mismatch across cluster!" -ForegroundColor Red
}

if ($solutionVersions.Count -eq 1 -and $sbeVersions.Count -eq 1) {

    Write-Host "Cluster versions are consistent." -ForegroundColor Green
}

############################################
# STEP 3 - CURRENT CLUSTER BASELINE
############################################

$currentSolution = $nodeInfo[0].SolutionVersion.ToString()
$currentSBE      = $nodeInfo[0].SBEVersion
$hardware        = $nodeInfo[0].HardwareModel

Write-Host ""
Write-Host "Current Cluster Baseline"
Write-Host "Solution Version : $currentSolution"
Write-Host "SBE Version      : $currentSBE"
Write-Host "Hardware Family  : $hardware"
Write-Host ""

############################################
# STEP 4 - DOWNLOAD DELL SBE MANIFEST
############################################

Write-Host "Downloading Dell SBE compatibility manifest..." -ForegroundColor Yellow

$url = "https://aka.ms/AzureStackSBEUpdate/DellEMC"
$tempFile = "$env:TEMP\dell_sbe_manifest.xml"

Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $tempFile

############################################
# STEP 5 - PARSE MANIFEST
############################################

[xml]$xml = Get-Content $tempFile

$updates = $xml.SBEUpdatesManifest.ApplicableUpdate | ForEach-Object {

    $reqSBE = ($_.validatedconfigurations.requiredpackages.package |
        Where-Object Type -eq "SBE").version -join ","

    $reqSolution = ($_.validatedconfigurations.requiredpackages.package |
        Where-Object Type -eq "Solution").version -join ","

    [PSCustomObject]@{

        Version          = $_.version
        Family           = $_.family
        RequiredSBE      = $reqSBE
        RequiredSolution = $reqSolution
    }
}

############################################
# STEP 6 - FIND POSSIBLE UPGRADE PATH
############################################

Write-Host "Possible SBE upgrades from current version:`n" -ForegroundColor Cyan

$possibleUpgrade = $updates | Where-Object {

    $_.RequiredSBE -match $currentSBE
}

if (!$possibleUpgrade) {

    Write-Host "No upgrade path found for current SBE version." -ForegroundColor Yellow
}
else {

    $possibleUpgrade |
    Sort-Object Version |
    Format-Table Version,Family,RequiredSBE,RequiredSolution -AutoSize
}

############################################
# FINISH
############################################

Write-Host ""
Write-Host "========================================"
Write-Host " SBE Compatibility Check Completed"
Write-Host "========================================"