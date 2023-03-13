# This script uses the PSYaml module to read and write YAML files from PowerShell. The PSYaml module is available for download from the PowerShell Gallery, and can be installed by running the following command:
# Install-Module -Name PSYaml
# The script prompts the user for the access ID, access key, and account information using the Read-Host cmdlet, and then uses the Get-Content, ConvertFrom-Yaml, Set-Content, and ConvertTo-Yaml cmdlets to update the appropriate fields in the YAML files.
# The PSYaml module is designed to preserve the order of the fields in a YAML file, so when you use the ConvertFrom-Yaml cmdlet to read in the YAML data and the ConvertTo-Yaml cmdlet to write out the updated data, the order of the fields should be preserved.
# The Get-Content cmdlet is used to read the YAML file into memory, and the ConvertFrom-Yaml cmdlet is used to convert the YAML data into a PowerShell object. The script then updates the appropriate fields in the PowerShell object, and uses the ConvertTo-Yaml cmdlet to convert the updated object back into YAML data. The Set-Content cmdlet is then used to write the updated YAML data back to the file.
# Note that the -Depth parameter is used with the ConvertTo-Yaml cmdlet to specify the maximum depth of the object hierarchy that should be included in the YAML output. By default, PowerShell will only include up to 2 levels of nesting in the output YAML, which may result in incomplete or truncated YAML output. Setting the -Depth parameter to a high value (such as 100) ensures that all levels of the object hierarchy are included in the output YAML.

# Import the PSYaml module
Import-Module -Name PSYaml

# Define the input parameters
$access_id = Read-Host "Enter Access ID"
$access_key = Read-Host "Enter Access Key"
$account = Read-Host "Enter Account"

# Update the argus values file
$values = Get-Content -Path "../argus-configuration.yaml" -Raw | ConvertFrom-Yaml
$values.accessID = $access_id
$values.accessKey = $access_key
$values.account = $account
Set-Content -Path "../argus-configuration.yaml" -Value ($values | ConvertTo-Yaml -Depth 100)

# Update the collectorset-controller values file
$values = Get-Content -Path "../collectorset-controller-configuration.yaml" -Raw | ConvertFrom-Yaml
$values.accessID = $access_id
$values.accessKey = $access_key
$values.account = $account
Set-Content -Path "../collectorset-controller-configuration.yaml" -Value ($values | ConvertTo-Yaml -Depth 100)
