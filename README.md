# Docker Gource Azure Repos

Clone all repos in all projects for organisation in Azure Repos and create a combined log file for use with Gource.  
Ready to be deployed as an Azure Container Instance.  
You can use Azure CLI CloudShell or setup WSL2 and Docker.

## Docker Locally

```bash
docker build --rm -f "Dockerfile" -t gource-azure-repos:latest "."

touch commits.log

docker run --rm --debug \
-e ORG="asos" \
-v $(pwd)/commits.log:/mnt/gource-azure-repos/commits.log \
gource-azure-repos:latest
```

```bash
az login
```

## Provision

```bash
az account set -s "Visual Studio Enterprise"
az group create -l northeurope -n gourcerg
az storage account create -n gourcestracc -g gourcerg -l northeurope --sku Standard_LRS
az storage share create -n gourceshare --account-name gourcestracc
az acr create -n gourceacr -g gourcerg --admin-enabled true --sku Basic
```

Assumed Azure File Share directory:

```bash
├── gource-azure-repos
│   ├── commits.log
```

## Build

```bash
az acr login -n gourceacr
az acr build -f "Dockerfile" -t gource-azure-repos:latest -r gourceacr "."
```

## Deploy

```bash
az container create -g gourcerg -n gource-azure-repos --image gourceacr.azurecr.io/gource-azure-repos \
--restart-policy Never \
--azure-file-volume-share-name gourceshare --azure-file-volume-account-name gourcestracc \
--azure-file-volume-account-key $(az storage account keys list --resource-group gourcerg --account-name gourcestracc --query "[0].value" --output tsv) \
--azure-file-volume-mount-path /mnt \
--registry-username gourceacr --registry-password "00000000000000000000000000000000"
```

```bash
az container attach --name gource-azure-repos --resource-group gourcerg
```
