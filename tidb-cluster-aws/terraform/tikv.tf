# TiKVサーバ
resource "aws_instance" "tikv" {
  count                  = var.num_tikv_servers
  ami                    = var.ami_id
  instance_type          = var.tikv_instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.cluster.id]
  subnet_id              = aws_subnet.private.id
  
  private_ip = "192.168.100.2${count.index + 1}"

  root_block_device {
    volume_size = 200
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-tikv-${count.index + 1}"
    Type = "tikv"
  }
}

# TiKV サーバの IP アドレスを出力
output "tikv_private_ips" {
  value = aws_instance.tikv[*].private_ip
}