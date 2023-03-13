# Scripts for inserting LogicMonitor API Access ID and Access Key
You will  need your LogicMonitor `account` name and an API `Access ID` and `Access Key` <br>
-- See https://www.logicmonitor.com/support/settings/users-and-roles/api-tokens/#h-creating-lmv1-tokens <br>
You can either manually update the `collectorset-controller-configuration.yaml` and the `argus-configuration.yaml`, or you can use either of the following three scripts depending on the command line you are using.

## Python Method
The `helm-chart-cred-insert.py` script uses `ruamel.yaml` to load the input YAML files, update the necessary fields, and then write the updated files back to disk using the `ruamel.yaml.dump` method with the `ruamel.yaml.RoundTripDumper` class. The `RoundTripDumper` class preserves the order of keys in a mapping, so the output YAML files will have the same key order as the input files.

You can install the `ruamel.yaml` module using `pip`
```
pip install ruamel.yaml
```
## Bash script method for Linux/macOS
The `helm-chart-cred-insert.sh` script uses the `yq` command-line tool to update the YAML files based on user input. The `yq` tool is a YAML processor that allows you to read, edit, and write YAML files from the command line.

You will need to have `yq` installed on your system in order to use this script. You can install `yq` using `pip` by running:
```
pip install yq
```
The script prompts the user for the `access ID`, `access key`, and `account` information using the `read` command, and then uses `yq` to update the appropriate fields in the YAML files. The `sed` command is then used to add indentation to the output YAML files, since `yq` does not preserve indentation by default.

Finally, the script uses the `mv` command to overwrite the original YAML files with the updated versions.

## Powershell script method for Windows
The `helm-chart-cred-insert.ps1` script uses the `PSYaml` module to read and write YAML files from PowerShell. The `PSYaml` module is available for download from the PowerShell Gallery, and can be installed by running the following command:
```
Install-Module -Name PSYaml
```
The script prompts the user for the `access ID`, `access key`, and `account` information using the `Read-Host` cmdlet, and then uses the `Get-Content`, `ConvertFrom-Yaml`, `Set-Content`, and `ConvertTo-Yaml` cmdlets to update the appropriate fields in the YAML files.

The `Get-Content` cmdlet is used to read the YAML file into memory, and the `ConvertFrom-Yaml` cmdlet is used to convert the YAML data into a PowerShell object. The script then updates the appropriate fields in the PowerShell object, and uses the `ConvertTo-Yaml` cmdlet to convert the updated object back into YAML data. The `Set-Content` cmdlet is then used to write the updated YAML data back to the file.

The `PSYaml` module is designed to preserve the order of the fields in a YAML file, so when you use the `ConvertFrom-Yaml` cmdlet to read in the YAML data and the `ConvertTo-Yaml` cmdlet to write out the updated data, the order of the fields should be preserved.

Note that the `-Depth` parameter is used with the `ConvertTo-Yaml` cmdlet to specify the maximum depth of the object hierarchy that should be included in the YAML output. By default, PowerShell will only include up to `2` levels of nesting in the output YAML, which may result in incomplete or truncated YAML output. Setting the `-Depth` parameter to a high value (such as `100`) ensures that all levels of the object hierarchy are included in the output YAML.