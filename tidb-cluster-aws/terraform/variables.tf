# AWSリージョン
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-1"
}

# アベイラビリティゾーン
variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

# プロジェクト名（リソースの命名に使用）
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "tidb-cluster"
}

# SSH公開鍵ファイルのパス
variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
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

# EC2インスタンスタイプ
variable "bastion_instance_type" {
  description = "Instance type for bastion server"
  type        = string
  default     = "t3.small"
}

variable "tidb_instance_type" {
  description = "Instance type for TiDB servers"
  type        = string
  default     = "t3.xlarge"
}

variable "tikv_instance_type" {
  description = "Instance type for TiKV servers"
  type        = string
  default     = "t3.xlarge"
}

variable "monitor_instance_type" {
  description = "Instance type for monitor server"
  type        = string
  default     = "t3.medium"
}

# VPC CIDR
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# サブネットCIDR
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# AMI ID (Ubuntu 22.04 LTS)
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "" # terraform.tfvarsで指定
}