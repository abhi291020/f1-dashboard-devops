# Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "f1-dashboard-rg"
  location = "East US"
}

# Azure Container Registry (existing - do NOT recreate)
# You have already imported this resource, so Terraform now manages it.
resource "azurerm_container_registry" "acr" {
  name                = "f1dashboardacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "f1-dashboard-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "f1dashboardaks"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_B2s"
    type                = "VirtualMachineScaleSets"
    scale_down_mode     = "Delete"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
    outbound_type     = "loadBalancer"
  }

  depends_on = [azurerm_container_registry.acr]
}

# Allow AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
