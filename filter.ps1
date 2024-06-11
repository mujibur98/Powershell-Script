# Set the security protocol to TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Define the URL of the Excel file on GitHub
$excelUrl = "https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/filterdriver.xlsx"

# Use Invoke-WebRequest to download the Excel file
try {
    Invoke-WebRequest -Uri $excelUrl -OutFile "filterdriver.xlsx"
    Write-Host "Excel file downloaded successfully."
} catch {
    Write-Host "Error downloading file: $_"
    exit
}

# Prompt for input
$searchTerm = Read-Host -Prompt "Enter the driver name"

# Load the Excel file using Import-Excel cmdlet (requires ImportExcel module)
$excelPath = ".\filterdriver.xlsx"
try {
    $excelData = Import-Excel -Path $excelPath
} catch {
    Write-Host "Error loading Excel file: $_"
    exit
}

# Search for the driver name in the Excel data
$companyName = $excelData | Where-Object { $_.Minifilter -match $searchTerm } | Select-Object -ExpandProperty Company

# Output the company name
if ($companyName) {
    Write-Host "Company Name: $companyName"
} else {
    Write-Host "No matching company name found."
}
