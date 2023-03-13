import yaml

# Define the input parameters
access_id = input("Enter Access ID: ")
access_key = input("Enter Access Key: ")
account = input("Enter Account: ")

# Update the argus values file
with open("argus-configuration.yaml", "r") as f:
    values = yaml.safe_load(f)
    values["accessID"] = access_id
    values["accessKey"] = access_key
    values["account"] = account

with open("argus/values.yaml", "w") as f:
    yaml.dump(values, f)

# Update the collectorset-controller values file
with open("collectorset-controller-configuration.yaml", "r") as f:
    values = yaml.safe_load(f)
    values["accessID"] = access_id
    values["accessKey"] = access_key
    values["account"] = account

with open("collectorset-controller/values.yaml", "w") as f:
    yaml.dump(values, f)