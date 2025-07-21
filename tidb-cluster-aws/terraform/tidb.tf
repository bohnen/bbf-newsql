# TiDBサーバ
resource "aws_instance" "tidb" {
  count                  = var.num_tidb_servers
  ami                    = var.ami_id
  instance_type          = var.tidb_instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.cluster.id]
  subnet_id              = aws_subnet.private.id
  
  private_ip = "10.0.2.1${count.index + 1}"

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-tidb-${count.index + 1}"
    Type = "tidb"
  }
}

# TiDB サーバの IP アドレスを出力
output "tidb_private_ips" {
  value = aws_instance.tidb[*].private_ip
}