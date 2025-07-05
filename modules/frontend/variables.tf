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

# ストレージアカウント設定
variable "storage_account_name" {
  description = "ストレージアカウントの名前"
  type        = string
}

variable "storage_account_tier" {
  description = "ストレージアカウントのティア"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "ストレージアカウントのレプリケーションタイプ"
  type        = string
  default     = "LRS"
}

variable "static_website_index_document" {
  description = "静的Webサイトのインデックスドキュメント"
  type        = string
  default     = "index.html"
}

variable "static_website_error_document" {
  description = "静的Webサイトのエラードキュメント"
  type        = string
  default     = "index.html"
}

# Front Door設定
variable "front_door_accepted_protocols" {
  description = "Front Doorで受け入れるプロトコル"
  type        = list(string)
  default     = ["Http", "Https"]
}

variable "front_door_frontend_patterns" {
  description = "フロントエンド用のパターンマッチ"
  type        = list(string)
  default     = ["/*"]
}

variable "front_door_backend_patterns" {
  description = "バックエンド用のパターンマッチ"
  type        = list(string)
  default     = ["/api/*"]
}

variable "front_door_forwarding_protocol" {
  description = "Front Doorの転送プロトコル"
  type        = string
  default     = "MatchRequest"
}

variable "front_door_session_affinity_enabled" {
  description = "Front Doorのセッションアフィニティの有効化"
  type        = bool
  default     = true
}

variable "front_door_session_affinity_ttl_seconds" {
  description = "Front DoorのセッションアフィニティTTL（秒）"
  type        = number
  default     = 300
}

# バックエンド設定
variable "backend_host_header" {
  description = "バックエンドのホストヘッダー"
  type        = string
}

variable "backend_address" {
  description = "バックエンドのアドレス"
  type        = string
} 