locals {
  # ホスト名
  tikv_host = "${var.server_name_prefix}-tikv"
}

# 作成するディスクを定義
resource "sakuracloud_disk" "tikv_server" {
  count             = var.num_tikv_servers
  name              = "${local.tikv_host}-disk-${count.index + 1}"
  size              = 100
  plan              = "ssd"
  connector         = "virtio"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
}

# 作成するサーバを定義
resource "sakuracloud_server" "tikv_server" {
  count       = var.num_tikv_servers
  name        = "${local.tikv_host}-${count.index + 1}"
  disks       = [element(sakuracloud_disk.tikv_server.*.id,count.index)]
  core        = 4
  memory      = 8

  # サーバのNICの接続先の定義
  network_interface {
    upstream = sakuracloud_switch.private_sw.id
    user_ip_address = "${var.tikv_server_ip_prefix}${count.index + 1}"
  }

  disk_edit_parameter {
    hostname = "${local.tikv_host}-${count.index + 1}"
    password = var.server_local_password
    disable_pw_auth = false
    ssh_keys = [
      file(var.ssh_public_key_path),
    ]
    ip_address = "${var.tikv_server_ip_prefix}${count.index + 1}"
    netmask = 24
    gateway = var.gateway_ip
  }
}
