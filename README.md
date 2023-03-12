# Getting Started

## Requirements
- Must have `AWS CLI` installed
- Must have `AWS CLI` credentials and run `aws configure`
- Must have `eksctl` installed
- Must have `kubectl` installed
- Must have `helm` installed
- You will also need you LogicMonitor `account` name and an API `Access ID` and `Access Key`

# Create the AWS EKS Fargate kubernetes cluster

## 1. Launch the cluster config file
```
eksctl create cluster -f eksfargateclusterconfig.yaml
```

### 2. By default, Amazon EKS clusters are configured to run CoreDNS on Amazon EC2 infrastructure
Run the following command to remove the '`eks.amazonaws.com/compute-type : ec2`' annotation from the CoreDNS pods:
```
kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
```

## 3. Delete and re-create any existing CoreDNS pods so that they are scheduled on Fargate. 
The following command triggers a rollout of the CoreDNS deployment:
```
kubectl rollout restart -n kube-system deployment coredns
```
# Install LogicMonitor Argus and Collectorset Controller

## 1. Import the LogicMonitor helm repo
```
helm repo add logicmonitor "https://logicmonitor.github.io/k8s-helm-charts"
```

## 2. Create `logicmonitor` namespace
```
kubectl create ns logicmonitor
```

## 3. Install `collectorset-controller`
```
helm upgrade --install --debug --wait --namespace="logicmonitor" -f collectorset-controller-configuration.yaml collectorset-controller logicmonitor/collectorset-controller
```

## 4. Install `argus`
```
helm upgrade --install --debug --wait --namespace="logicmonitor" -f argus-configuration.yaml argus logicmonitor/argus
```

## (Optional) You can view the logs for the `collectorset-controller`
```
kubectl logs -f $(kubectl get pods --namespace=logicmonitor -l app=collectorset-controller -o name) -c collectorset-controller -n logicmonitor
```

## (Optional) You can view the logs for `argus`
```
kubectl logs -f $(kubectl get pods --namespace=logicmonitor -l app=argus -o name) -c argus -n logicmonitor
```

# Migrating to unified LM Container helm chart

## 1. Install `LMC` helm plugin
```
helm plugin install https://github.com/logicmonitor/lmc
```

## 2. Migrate existing `argus` and `collectorset-controller` helm configs
```
helm lmc config migrate -n logicmonitor
```
- This will create and migrate the existing configs in a new file called `lm-container-configuration.yaml` in your `logicmonitor` namespace.

## 3. Delete old `argus`
```
helm delete argus -n logicmonitor
```

## 4. Delete old `collectorset-controller`
```
helm delete collectorset-controller -n logicmonitor
```

## 5. Delete old `collectorset-controller` Custom Resource Definition (CRD)
```
kubectl delete crd collectorsets.logicmonitor.com
```

## 6. Delete client-cached ConfigMaps
```
kubectl delete configmaps -l argus=cache
```
# Installing unified LM Container helm charts

## 1. Import the LM Container chart repository
```
helm repo add logicmonitor https://logicmonitor.github.io/helm-charts
```
## 2. Load and select the LM Container helm chart
```
helm repo update
```

## 3. Install/upgrade LM Container helm chart
```
helm upgrade --install --debug --wait --namespace="logicmonitor" --create-namespace -f ./lm-container-configuration.yaml lm-container --version "3" logicmonitor/lm-container
```
- Above command is using LM Container chart `--version "3"` as this is the latest LM Container helm chart version as of the writing of this `README`.
- Check https://github.com/logicmonitor/helm-charts/tree/main/charts/lm-container for latest version.