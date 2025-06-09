locals {
  # ホスト名
  monitor_host = "${var.server_name_prefix}-monitor"
}

# 作成するディスクを定義
resource "sakuracloud_disk" "monitor_server" {
  name              = "${local.monitor_host}-disk"
  size              = 40
  plan              = "ssd"
  connector         = "virtio"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
}

# 作成するサーバを定義
resource "sakuracloud_server" "monitor_server" {
  name        = local.monitor_host
  disks       = [sakuracloud_disk.monitor_server.id]
  core        = 2
  memory      = 6

  # サーバのNICの接続先の定義
  network_interface {
    upstream = sakuracloud_switch.private_sw.id
    user_ip_address = var.monitor_server_ip
  }

  disk_edit_parameter {
    hostname = local.monitor_host
    password = var.server_local_password
    disable_pw_auth = false
    ssh_keys = [
      file(var.ssh_public_key_path),
    ]
    ip_address = var.monitor_server_ip
    netmask = 24
    gateway = var.gateway_ip
  }
}
