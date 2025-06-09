# SakuraCloudのAPIアクセス‐トークン
variable "sakuracloud_access_token" {
  description = "SakuraCloud API access token"
  type        = string
}

# SakuraCloudのAPIアクセスシークレット
variable "sakuracloud_access_token_secret" {
  description = "SakuraCloud API access token secret"
  type        = string
}

# デプロイ先のSakuraCloudゾーン
variable "sakuracloud_zone" {
  description = "SakuraCloud zone to deploy resources into"
  type        = string
}

# SSH公開鍵ファイルのパス
variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

# 作成サーバの名称プレフィックス
variable "server_name_prefix" {
  description = "Prefix for the names of created servers"
  type        = string
}

# サーバ初期ユーザのパスワード
variable "server_local_password" {
  description = "Initial password for the server’s local user"
  type        = string
}
# TiDBサーバの個数
variable "num_tidb_servers" {
  description = "Number of TiDB servers"
  type        = number
  default     = 1
}

# TiKV & PD サーバの個数
variable "num_tikv_servers" {
  description = "Number of TiKV and PD servers"
  type        = number
  default     = 3
}
# ルーターのIPアドレス
variable "gateway_ip" {
  description = "IP address of the router"
  type        = string
}

# bastionホストのIPアドレス
variable "bastion_ip" {
  description = "IP address of the bastion host"
  type        = string
}

# TiDBサーバのIPアドレスプレフィックス
variable "tidb_server_ip_prefix" {
  description = "IP address prefix for TiDB servers"
  type        = string
}

# TiKV & PD サーバのIPアドレスプレフィックス
variable "tikv_server_ip_prefix" {
  description = "IP address prefix for TiKV and PD servers"
  type        = string
}

# monitorのIPアドレス
variable "monitor_server_ip" {
  description = "IP address of the monitor server"
  type        = string
}