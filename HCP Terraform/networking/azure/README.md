# Networking – Azure

This configuration builds the network foundation that the Azure application
configuration deploys into. It creates a resource group, a virtual network, and
a single public subnet.

## Resources created

- `azurerm_resource_group` – container for all resources
- `azurerm_virtual_network` – the virtual network (`vnet_cidr`)
- `azurerm_subnet` – the public subnet (`subnet_cidr`)

## Outputs

| Output                 | Description                                          |
| ---------------------- | ---------------------------------------------------- |
| `resource_group_name`  | Name of the resource group (consumed by application) |
| `location`             | Region the resources were deployed into              |
| `virtual_network_name` | Name of the virtual network                          |
| `subnet_id`            | ID of the public subnet (consumed by application)    |

## Authenticating with the Azure CLI

The `azurerm` provider authenticates using your Azure CLI session.

1. Install the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli).
2. Sign in:

   ```bash
   az login
   ```

3. Select the subscription you want to deploy into:

   ```bash
   az account list --output table
   az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
   ```

4. The `azurerm` v4 provider requires the subscription ID to be set explicitly.
   Export it into the environment so Terraform can pick it up automatically:

   ```bash
   # macOS / Linux
   export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
   ```

   ```powershell
   # Windows PowerShell
   $env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)
   ```

## Deploying

```bash
terraform init
terraform apply \
  -var="vnet_cidr=10.0.0.0/16" \
  -var="subnet_cidr=10.0.1.0/24"
```

After the apply completes, capture the `subnet_id`, `resource_group_name`, and
`location` outputs — the application configuration needs them.

```bash
terraform output -raw subnet_id
terraform output -raw resource_group_name
terraform output -raw location
```
