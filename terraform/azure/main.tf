# terraform/azure/main.tf
resource "azurerm_kubernetes_cluster" "ai_noc" {
  name                = "ai-noc-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "ai-noc"
  kubernetes_version  = "1.27.7"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}
