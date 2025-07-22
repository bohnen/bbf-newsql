# モニタリングサーバ
resource "aws_instance" "monitor" {
  ami                    = var.ami_id
  instance_type          = var.monitor_instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.cluster.id]
  subnet_id              = aws_subnet.private.id
  
  private_ip = "192.168.100.8"

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-monitor"
    Type = "monitor"
  }
}

# モニターサーバの IP アドレスを出力
output "monitor_private_ip" {
  value = aws_instance.monitor.private_ip
}