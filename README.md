# Getting Started
This lab will create a serverless (`EC2`-less) `AWS EKS` Kubernetes cluster on `AWS Fargate`. You will also install the Logicmonitor monitoring applications to collect cluster metrics. You will also migrate to the unified `LM Container` helm chart for monitoring.

## Requirements
- Must have the `AWS CLI` installed <br>
-- See https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Must have `AWS CLI` credentials and run `aws configure` <br>
-- See https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config
- Must have `eksctl` installed <br>
-- See https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
- Must have `kubectl` installed <br>
-- See https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
- Must have `helm` installed <br>
-- See https://docs.aws.amazon.com/eks/latest/userguide/helm.html
- You will also need your LogicMonitor `account` name and an API `Access ID` and `Access Key` <br>
-- See https://www.logicmonitor.com/support/settings/users-and-roles/api-tokens/#h-creating-lmv1-tokens <br>
-- See https://github.com/CosmoSimio/eksfargatek8slab/tree/master/cred-inserts
- You should also clone this Github repo to a local directory <br>
-- See https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository?tool=cli <br>
-- As long as are working within your local repo directory, you can run all of the commands in this `README` in order.

# Create the `AWS EKS on Fargate` Kubernetes cluster
This first section assumes that you have completed the initial `Requirements` and that you have a working `AWS CLI` with the adequate permissions for launching the `EKS` cluster.
### 1. Launch the cluster config file
```
eksctl create cluster -f eksfargateclusterconfig.yaml
```

### 2. By default, Amazon `EKS` clusters are configured to run `CoreDNS` on Amazon `EC2` infrastructure
Run the following command to remove the '`eks.amazonaws.com/compute-type : ec2`' annotation from the `CoreDNS` pods:
```
kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
```

### 3. Delete and re-create any existing `CoreDNS` pods so that they are scheduled on `Fargate`. 
The following command triggers a rollout of the `CoreDNS` deployment:
```
kubectl rollout restart -n kube-system deployment coredns
```
# Install LogicMonitor `Argus` and `Collectorset Controller`

### 1. Create a `logicmonitor` namespace
```
kubectl create ns logicmonitor
```

### 2. Import the `logicMonitor` helm repo
```
helm repo add logicmonitor "https://logicmonitor.github.io/k8s-helm-charts"
```
> <b>Note</b>: Before proceeding with steps 3 and 4, you must ensure that you have updated the `collector-controller-configuration.yaml` and `argus-configuration.yaml` with <u>your own</u> LogicMonitor API credentials.<br>
You can update each yaml file manually or you can use one of the three scripted methods in the '`cred-inserts`' sub-directory of this repository. <br>
-- See https://github.com/CosmoSimio/eksfargatek8slab/tree/master/cred-inserts

### 3. Install the `collectorset-controller`
```
helm upgrade --install --debug --wait --namespace="logicmonitor" -f collectorset-controller-configuration.yaml collectorset-controller logicmonitor/collectorset-controller
```
### 4. Install the LogicMonitor `argus` cluster monitoring application
```
helm upgrade --install --debug --wait --namespace="logicmonitor" -f argus-configuration.yaml argus logicmonitor/argus
```

### (Optional) You can view the logs for the `collectorset-controller`
```
kubectl logs -f $(kubectl get pods --namespace=logicmonitor -l app=collectorset-controller -o name) -c collectorset-controller -n logicmonitor
```
### (Optional) You can view the logs for `argus`
```
kubectl logs -f $(kubectl get pods --namespace=logicmonitor -l app=argus -o name) -c argus -n logicmonitor
```
# Migrating to the unified `LM Container` helm chart

### 1. Install the `lmc` helm plugin
```
helm plugin install https://github.com/logicmonitor/lmc
```

### 2. Back up your `collectorset-controller-configuration.yaml`
```
helm get values collectorset-controller -n logicmonitor > collectorset-controller-configuration.yaml.bkp
```

### 3. Back up your `argus-configuration.yaml`
```
helm get values argus -n logicmonitor > argus-configuration.yaml.bkp
```

### 4. Migrate your existing `argus` and `collectorset-controller` helm configs
```
helm lmc config migrate -n logicmonitor
```
- This will create and migrate your existing configs in a new file called `lm-container-configuration.yaml` in your `logicmonitor` namespace.

### 5. Delete the old `argus`
```
helm delete argus -n logicmonitor
```

### 6. Delete the old `collectorset-controller`
```
helm delete collectorset-controller -n logicmonitor
```

### 7. Delete the old `collectorset-controller` `Custom Resource Definition (CRD)`
```
kubectl delete crd collectorsets.logicmonitor.com
```

### 8. Delete the client-cached `ConfigMaps`
```
kubectl delete configmaps -l argus=cache
```
# Installing the unified `LM Container` helm charts

### 1. Import the `LM Container` helm chart repository
```
helm repo add logicmonitor https://logicmonitor.github.io/helm-charts
```
### 2. Load and select the `LM Container` helm chart
```
helm repo update
```

### 3. Install/upgrade to the `LM Container` helm chart
```
helm upgrade --install --debug --wait --namespace="logicmonitor" --create-namespace -f ./lm-container-configuration.yaml lm-container --version "3" logicmonitor/lm-container
```
- The above command is using the `LM Container` chart `--version "3"` as this is the latest chart version as of the writing of this `README`.
- Check https://github.com/logicmonitor/helm-charts/tree/main/charts/lm-container for latest version.