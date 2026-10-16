# terraform-azure-compute-labservices

Org-standard Terraform wrapper for **Azure Lab Services** (lab plans + labs).

⚠️ **No AVM module exists for this resource.** Azure Lab Services (`Microsoft.LabServices`) has no published AVM module. The `Azure/terraform-azurerm-avm-res-devtestlab-lab` GitHub repo wraps the older, distinct "DevTest Labs" product and isn't published to the Terraform Registry anyway, so it can't be used here either. This wraps the native `azurerm_lab_service_plan` / `azurerm_lab_service_lab` resources directly and is intentionally conservative in scope. **Validate with `terraform plan` against your provider version before relying on this in production** -- it has had less real-world exercise than the AVM-backed repos in this org's module set. Swap it for an AVM module if/when Microsoft publishes one.

Deploys into an existing resource group -- this module does not create the resource group itself. Compose with [terraform-azure-naming](https://github.com/engryinker/terraform-azure-naming) and [terraform-azure-tags](https://github.com/engryinker/terraform-azure-tags).

## Usage

```hcl
module "labservices" {
  source = "git::https://github.com/engryinker/terraform-azure-compute-labservices.git?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  tags                 = module.tags.tags

  lab_plans = {
    main = { name = "labplan-training" }
  }

  labs = {
    lab1 = {
      name         = "lab-python101"
      lab_plan_key = "main"
      virtual_machine = {
        admin_user = { username = "labadmin", password = "ChangeMe!123" }
        image_reference = { id = "<shared image gallery image id>" }
        sku        = { name = "Standard_DS2_v2" }
        usage_quota = "PT10H"
      }
    }
  }
}
```

See [`examples/basic`](examples/basic) for a minimal (zero-instance) example.

## Inputs

### `lab_plans`

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `name` | `string` | yes | |
| `allowed_regions` | `list(string)` | no | |
| `shared_gallery_id` | `string` | no | |
| `support_info` | `any` | no | `{ email, instructions, phone, url }` |
| `default_auto_shutdown` | `any` | no | `{ disconnect_delay_minutes, idle_delay_minutes, no_connect_delay_minutes, shutdown_on_idle }` |
| `default_connection` | `any` | no | `{ client_rdp_access, client_ssh_access, web_rdp_access, web_ssh_access }` |
| `default_network_subnet_id` | `string` | no | |
| `tags` | `map(string)` | no | |

### `labs`

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `name` | `string` | yes | |
| `lab_plan_key` | `string` | yes | Must reference a key in `var.lab_plans`. |
| `title` / `description` | `string` | no | |
| `virtual_machine` | `any` | **yes** | `{ admin_user, image_reference, sku, usage_quota, ... }` -- see [`azurerm_lab_service_lab` docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lab_service_lab). |
| `security` | `any` | no | Default `{ open_access_enabled = false }`. |
| `connection_setting`, `network`, `auto_shutdown`, `roster` | `any` | no | See upstream docs. |
| `tags` | `map(string)` | no | |

## Outputs

- `lab_plans` -- map of created `azurerm_lab_service_plan` resources.
- `labs` -- map of created `azurerm_lab_service_lab` resources.
