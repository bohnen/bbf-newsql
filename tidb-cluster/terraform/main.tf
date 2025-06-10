data "sakuracloud_archive" "ubuntu" {
  # filter {
  #   tags = ["distro-ubuntu", "distro-ver-24.04", "cloud-init"]
  # }
  os_type = "ubuntu"
}

locals {
  # ホスト名
  host_name = "${var.server_name_prefix}-bastion"
}

# プライベートネットワークのスイッチ
resource "sakuracloud_switch" "private_sw" {
  name        = "${var.server_name_prefix}-sw"
  description = "Private network switch"
}

# VPCRouter
resource "sakuracloud_vpc_router" "vpcrouter" {
  name = "${var.server_name_prefix}-vpcRouter"
  private_network_interface {
    index        = 1 # VPCrouterの利用するNICのインデックス
    switch_id    = sakuracloud_switch.private_sw.id # 接続するスイッチ
    ip_addresses = [
      var.gateway_ip, # VPCルータのIPアドレス
    ]
    netmask      = 24
  }
  port_forwarding {
    protocol     = "tcp"
    public_port  = 22
    private_ip   = var.bastion_ip
    private_port = 22
    description  = "SSH Forwarding"
  }
}

### Bastionサーバの定義

# 作成するディスクを定義
resource "sakuracloud_disk" "tidb_bastion" {
  name              = "${local.host_name}-disk"
  size              = 20
  plan              = "ssd"
  connector         = "virtio"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
}

# 作成するサーバを定義
resource "sakuracloud_server" "tidb_bastion" {
  name        = "${local.host_name}"
  disks       = [sakuracloud_disk.tidb_bastion.id]
  core        = 1
  memory      = 2

  # サーバのNICの接続先の定義。sharedだと共有セグメント(インターネット)に接続される。
  network_interface {
    upstream = sakuracloud_switch.private_sw.id
    user_ip_address = var.bastion_ip
  }

  disk_edit_parameter {
    hostname = local.host_name
    password = var.server_local_password
    disable_pw_auth = false
    ssh_keys = [
      file(var.ssh_public_key_path),
    ]
    ip_address = var.bastion_ip
    netmask = 24
    gateway = var.gateway_ip
  }
}

output "vpcrouter_public_ip" {
  value = sakuracloud_vpc_router.vpcrouter.public_ip
  description = "The public IP address of the VPC Router"
}