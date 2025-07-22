# Terraform for TiDB Cluster on AWS

## 前提条件

- AWS CLIがインストールされ、設定済みであること
- Terraformがインストールされていること
- AWS上で必要なIAM権限があること（EC2、VPC、Security Groupの管理など）

## 使用方法

1. terraform.tfvarsファイルを作成
```bash
cp terraform.tfvars.template terraform.tfvars
```

2. terraform.tfvarsを編集
- `ssh_public_key_path`: SSH公開鍵のパスを指定
- `ami_id`: 使用するAMI IDを指定（デフォルトは東京リージョンのUbuntu 22.04）
- そのほかの変数は必要に応じて調整

3. SSH鍵ペアの作成（まだ作成していない場合）
```bash
ssh-keygen -f ~/.ssh/tidb-aws
```

4. Terraformの実行
```bash
terraform init
terraform plan
terraform apply
```

5. 出力された踏み台サーバのIPアドレスを確認
```bash
terraform output bastion_public_ip
```

## インフラ構成

- VPC: 192.168.0.0/16
- パブリックサブネット: 192.168.1.0/24
  - 踏み台サーバ
- プライベートサブネット: 192.168.100.0/24
  - TiDBサーバ: 192.168.100.11〜
  - TiKVサーバ: 192.168.100.21〜
  - モニタリングサーバ: 192.168.100.8

## セキュリティグループ

- 踏み台サーバ: SSH (22) のみ外部から許可
- クラスターサーバ: 踏み台サーバからのSSHと、クラスター内通信のみ許可

## クリーンアップ

```bash
terraform destroy
```