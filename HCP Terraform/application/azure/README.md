# Application – Azure

This configuration deploys a simple web server (Apache on Ubuntu) into the
subnet created by the **networking/azure** configuration. It depends on the
networking outputs for the subnet, resource group, and region.

## Resources created

- `azurerm_network_security_group` – allows inbound HTTP (port 80)
- `azurerm_public_ip` – static public IP for the VM
- `azurerm_network_interface` – NIC attached to the provided subnet
- `azurerm_network_interface_security_group_association` – associates the NSG with the NIC
- `azurerm_linux_virtual_machine` – the web server, bootstrapped via `custom_data`

## Inputs

| Variable              | Description                                            | Default        |
| --------------------- | ------------------------------------------------------ | -------------- |
| `subnet_id`           | Subnet ID from the networking configuration (required) | –              |
| `resource_group_name` | Resource group name from the networking config (required) | –           |
| `location`            | Azure region to deploy into                            | `eastus2`      |
| `vm_size`             | Size of the virtual machine                            | `Standard_B1s` |
| `admin_username`      | Admin username for the VM                              | `azureuser`    |
| `admin_password`      | Admin password for the VM (required, sensitive)        | –              |
| `common_tags`         | Tags applied to all resources                          | `{}`           |

## Authenticating with the Azure CLI

This configuration uses the same Azure CLI authentication as the networking
configuration:

```bash
az login
az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
```

```powershell
# Windows PowerShell
$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)
```

```bash
# macOS / Linux
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

## Deploying

Deploy the **networking/azure** configuration first, then pass its outputs in
here. You also need an admin password for the VM. The password must meet Azure's
complexity requirements (12–72 characters with a mix of upper case, lower case,
digits, and symbols). Avoid committing it to source control — pass it at the
command line or via the `TF_VAR_admin_password` environment variable:

```bash
terraform init
terraform apply \
  -var="subnet_id=$(cd ../../networking/azure && terraform output -raw subnet_id)" \
  -var="resource_group_name=$(cd ../../networking/azure && terraform output -raw resource_group_name)" \
  -var="location=$(cd ../../networking/azure && terraform output -raw location)" \
  -var="admin_password=<YOUR_SECURE_PASSWORD>"
```

When the apply finishes, browse to the instance's public IP:

```bash
terraform output -raw instance_public_ip
```
