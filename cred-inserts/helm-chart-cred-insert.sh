#!/bin/bash
#This script uses the yq command-line tool to update the YAML files based on user input. The yq tool is a YAML processor that allows you to read, edit, and write YAML files from the command line. It is available for macOS, Linux, and Windows and can be installed using pip.
#The script prompts the user for the access ID, access key, and account information using the read command, and then uses yq to update the appropriate fields in the YAML files. The sed command is then used to add indentation to the output YAML files, since yq does not preserve indentation by default.
#Finally, the script uses the mv command to overwrite the original YAML files with the updated versions.
#Note that you will need to have yq installed on your system in order to use this script. You can install yq using pip by running:
# pip install yq

# Define the input parameters
read -p "Enter Access ID: " access_id
read -p "Enter Access Key: " access_key
read -p "Enter Account: " account

# Update the argus values file
yq -Y --arg access_id "$access_id" --arg access_key "$access_key" --arg account "$account" '.accessID = $access_id | .accessKey = $access_key | .account = $account' argus-configuration.yaml | sed 's/^/  /' > argus-configuration.yaml.new
mv argus-configuration.yaml.new argus-configuration.yaml

# Update the collectorset-controller values file
yq -Y --arg access_id "$access_id" --arg access_key "$access_key" --arg account "$account" '.accessID = $access_id | .accessKey = $access_key | .account = $account' collectorset-controller-configuration.yaml | sed 's/^/  /' > collectorset-controller-configuration.yaml.new
mv collectorset-controller-configuration.yaml.new collectorset-controller-configuration.yaml