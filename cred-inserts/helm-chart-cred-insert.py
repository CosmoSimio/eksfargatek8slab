# To use this python script, you must ensure that the ruamel.yaml module is installed.
# You can use command 'pip install ruamel.yaml' to install
import ruamel.yaml

# Define the input parameters
access_id = input("Enter Access ID: ")
access_key = input("Enter Access Key: ")
account = input("Enter Account: ")

# Update the argus values file
with open("argus-configuration.yaml", "r") as f:
    values = ruamel.yaml.safe_load(f)
    values["accessID"] = access_id
    values["accessKey"] = access_key
    values["account"] = account

with open("argus-configuration.yaml", "w") as f:
    ruamel.yaml.dump(values, f, Dumper=ruamel.yaml.RoundTripDumper)

# Update the collectorset-controller values file
with open("collectorset-controller-configuration.yaml", "r") as f:
    values = ruamel.yaml.safe_load(f)
    values["accessID"] = access_id
    values["accessKey"] = access_key
    values["account"] = account

with open("collectorset-controller-configuration.yaml", "w") as f:
    ruamel.yaml.dump(values, f, Dumper=ruamel.yaml.RoundTripDumper)