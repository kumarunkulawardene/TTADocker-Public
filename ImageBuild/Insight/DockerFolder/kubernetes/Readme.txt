How to create k8s cluster in azure

PASSWORD_WIN="<REDACTED_WINDOWS_ADMIN_PASSWORD>"
RESOURCE_GROUP="Kofax"
CLUSTER_NAME="insight-cluster"
CONTAINER_REGISTRY="insight-registry"
WIN_NODEPOOL_NAME="npwin"

#container registry
az acr create -n $CONTAINER_REGISTRY -g $RESOURCE_GROUP --sku Basic --admin-enabled true
az acr credential show -n $CONTAINER_REGISTRY

#push image to azure container registry (your local machine)
docker login <CONTAINER_REGISTRY>.azurecr.io -u <CONTAINER_REGISTRY> --password <registry password>
docker tag insight-web <CONTAINER_REGISTRY>.azurecr.io/insight-web:v1
docker tag insight-scheduler <CONTAINER_REGISTRY>.azurecr.io/insight-scheduler:v1
docker push <CONTAINER_REGISTRY>.azurecr.io/insight-web:v1
docker push <CONTAINER_REGISTRY>.azurecr.io/insight-scheduler:v1

#Creating k8s cluster

az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --windows-admin-password $PASSWORD_WIN \
    --windows-admin-username azureuser \
    --vm-set-type VirtualMachineScaleSets \
    --network-plugin azure


#Creating windows node pool 

az aks nodepool add \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --os-type Windows \
    --name $WIN_NODEPOOL_NAME \
    --node-count 1


#Saving the cluster credentials to the curent bash session profile

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME


#Login to container registry

kubectl create secret docker-registry regcred --docker-server=<CONTAINER_REGISTRY>.azurecr.io --docker-username=<CONTAINER_REGISTRY> --docker-password=<REGISTRY_PASSWORD>

#Creating shared storage for InsightData

kubectl apply -f insight-data-azure-file-sc.yaml
kubectl apply -f insight-data-azure-file-pvc.yaml
kubectl get pvc


#Upload insight license file to PVC using azure portal (Home\Storage accounts\<name that contains your cluster name>\File shares\)


#Creating insight deployments
kubectl apply -f insight-k8s-deployment.yml


#Get pods state
kubectl get pod


#Delete cluster
az aks delete --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME


#Optional steps - Enable claster autoscaler 

#Node pools autoscaler 

az aks nodepool update \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 5 \
  --resource-group $RESOURCE_GROUP \
  --name WIN_NODEPOOL_NAME \
  --cluster-name $CLUSTER_NAME


#Pods autoscaler
kubectl autoscale deployment insight-web --cpu-percent=50 --min=1 --max=10
kubectl autoscale deployment insight-scheduler --cpu-percent=50 --min=1 --max=10

#Getting autoscaler logs

kubectl get configmap -n kube-system cluster-autoscaler-status -o yaml
