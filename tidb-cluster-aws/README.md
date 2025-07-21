# TiDB Cluster on AWS

## ディレクトリ構成

- terraform: AWS上でTiDBクラスターをTerraformで構築するためのファイル
- ansible: Ansibleを使ったサーバのセットアップ
- tiup: TiUPを使ったTiDBクラスターのセットアップ

## 利用方法

このディレクトリは、AWS上にTiDBクラスターを構築するためのプロジェクトです。

### 1. Terraformでインフラ構築

```bash
cd terraform
cp terraform.tfvars.template terraform.tfvars
# terraform.tfvarsを編集
terraform init
terraform plan
terraform apply
```

### 2. Ansibleでサーバセットアップ

踏み台サーバ上でAnsibleを実行します：

```bash
scp -i ~/.ssh/<ssh秘密鍵> -r ansible/ ubuntu@<踏み台サーバのIPアドレス>:~/
ssh -i ~/.ssh/<ssh秘密鍵> ubuntu@<踏み台サーバのIPアドレス>
cd ansible
ansible-playbook -i inventory.ini bastion_playbook.yml
ansible-playbook -i inventory.ini cluster_playbook.yml
```

### 3. TiUPでクラスターセットアップ

```bash
scp -i ~/.ssh/<ssh秘密鍵> -r tiup/ ubuntu@<踏み台サーバのIPアドレス>:~/
ssh -i ~/.ssh/<ssh秘密鍵> ubuntu@<踏み台サーバのIPアドレス>
cd tiup
tiup cluster deploy tidb-test v7.5.1 topology.yml
tiup cluster start tidb-test
```

## アーキテクチャ

- VPC: 10.0.0.0/16
- パブリックサブネット: 10.0.1.0/24
- プライベートサブネット: 10.0.2.0/24
- 踏み台サーバ: パブリックサブネット
- TiDB/TiKV/PDサーバ: プライベートサブネット