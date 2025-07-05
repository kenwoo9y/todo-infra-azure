variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
}

variable "location" {
  description = "Azureリージョン"
  type        = string
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
}

# Container Registry設定
variable "acr_name" {
  description = "Azure Container Registryの名前"
  type        = string
}

variable "acr_sku" {
  description = "Container RegistryのSKU"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Container Registryの管理者アクセスの有効化"
  type        = bool
  default     = true
}

# ネットワーク設定
variable "vnet_address_space" {
  description = "仮想ネットワークのアドレス空間"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "container_apps_subnet_address_prefixes" {
  description = "Container Appsサブネットのアドレスプレフィックス"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Container App設定
variable "container_app_revision_mode" {
  description = "Container Appのリビジョンモード"
  type        = string
  default     = "Single"
}

variable "container_app_image_name" {
  description = "Container Appのイメージ名"
  type        = string
  default     = "backend"
}

variable "container_app_image_tag" {
  description = "Container Appのイメージタグ"
  type        = string
  default     = "latest"
}

variable "container_app_cpu" {
  description = "Container AppのCPU割り当て"
  type        = number
  default     = 0.25
}

variable "container_app_memory" {
  description = "Container Appのメモリ割り当て"
  type        = string
  default     = "0.5Gi"
}

variable "container_app_environment_variables" {
  description = "Container Appの環境変数"
  type        = map(string)
  default     = {}
}

variable "container_app_allow_insecure_connections" {
  description = "Container Appの非セキュア接続の許可"
  type        = bool
  default     = false
}

variable "container_app_external_enabled" {
  description = "Container Appの外部アクセスの有効化"
  type        = bool
  default     = true
}

variable "container_app_target_port" {
  description = "Container Appのターゲットポート"
  type        = number
  default     = 8080
} 