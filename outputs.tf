output "lab_plans" {
  description = "Map (same keys as var.lab_plans) of the created azurerm_lab_service_plan resources."
  value       = azurerm_lab_service_plan.this
}

output "labs" {
  description = "Map (same keys as var.labs) of the created azurerm_lab_service_lab resources."
  value       = azurerm_lab_service_lab.this
}
