terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# -------------------------
# Resource Group
# -------------------------

resource "azurerm_resource_group" "main" {
  name     = "rg-aks-static-webapp"
  location = "South Africa North"

  tags = {
    Owner      = "Thato"
    CostCenter = "DevOps"
  }
}

# -------------------------
# Azure Container Registry
# -------------------------

resource "azurerm_container_registry" "acr" {
  name                = "aksstaticwebappacr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    Owner      = "Thato"
    CostCenter = "DevOps"
  }
}

# -------------------------
# AKS Cluster
# -------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-static-webapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-static-webapp"

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_D2s_v6"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Owner      = "Thato"
    CostCenter = "DevOps"
  }
}

# -------------------------
# Allow AKS to pull images
# -------------------------

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}