# Terraform for TiDB Cluster on AWS

## 前提条件

- AWS CLIがインストールされ、設定済みであること
- Terraform 1.0以上がインストールされていること
- AWS上でEC2インスタンスを作成する権限があること

## 使用方法

1. terraform.tfvarsファイルを作成
```bash
cp terraform.tfvars.template terraform.tfvars
```

2. terraform.tfvarsを編集
- `ssh_public_key_path`: SSH公開鍵のパスを指定
- `ami_id`: 使用するAMI IDを指定（デフォルトは東京リージョンのUbuntu 22.04）
- その他の変数は必要に応じて調整

3. SSH鍵ペアの作成（まだ作成していない場合）
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/tidb-aws
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

- VPC: 10.0.0.0/16
- パブリックサブネット: 10.0.1.0/24
  - 踏み台サーバ
- プライベートサブネット: 10.0.2.0/24
  - TiDBサーバ: 10.0.2.11〜
  - TiKVサーバ: 10.0.2.21〜
  - モニタリングサーバ: 10.0.2.8

## セキュリティグループ

- 踏み台サーバ: SSH (22) のみ外部から許可
- クラスタサーバ: 踏み台サーバからのSSHと、クラスタ内通信のみ許可

## クリーンアップ

```bash
terraform destroy
```