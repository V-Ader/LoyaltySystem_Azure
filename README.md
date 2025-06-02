# Loyalty - Azure


# Environment

## Terraform
1. Execute below commands to install terraform
```bash
sudo apt-get update
sudo apt-get install -y wget gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install terraform
```

2. Check the terraform version

```bash
terraform version
```

## Azure CLI (az version)

1. Install `az` with following:
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
2. Check the installation:
```bash
az version
```

## Azure Functions Core Tools (func)

1. Install the latest LTS version of Node.js:

```bash
nvm install --lts
nvm use --lts
```
2. Verify Node.js and npm versions:
```bash
node -v
npm -v
```
3. Install Azure Functions Core Tools v4:

```bash
npm i -g azure-functions-core-tools@4 --unsafe-perm true
```

4. Verify installations

```bash 
func --version
```

# Deployment

## Prepare variables

Create a file `terraform.tfvars` in /terraform folder with the following variables:

```yaml
subscription_id = ...
location = ... f.e. "northeurope"

github_token = ...
```

## Create the infrastructure
### Run all modules
```bash
cd terraform
terraform init
terraform apply
```
### Set up a public access for the database
Go to the Azure platform | _resource group_ | _pg-azure-db-..._ | Options

- Connect | 
  - Allow to use a public IP address
- Network | 
  - Allow public access to this resource over the Internet using a public IP address


## Set up db
```bash
cd scripts
./setup_db.sh
```


## Publish functions
```bash
cd apps
./publish_functions.sh
```
----
----

# WYMAGANIA

1. projekt musi być zrealizowany w oparciu o architekturę mikroserwisów (min. 3 węzły)
    1. API
    2. Kafka consummer TODO (komunikacja asynchroniczna w przynajmniej jednym miejscu)
    3. Wykorzystanie usług SaaS w ramach dowolnej chmury (np. Azure Cognitive Services)
    ? TODO
 2. Architektura serverless lub w oparciu o kubernetes (lub podobną technologię) jak azure functions\
 3. Minimalny frontend (np. streamlit)
 4. Static page in storage account
 5. Infrastructure as Code (np. Terraform, ARM)
 terraform
 1. CI/CD (np. GitHub Actions, Azure DevOps)
 github Actions -> on mr to main deploy on cloud TODO
 1. Diagram architektury (np. draw.io)