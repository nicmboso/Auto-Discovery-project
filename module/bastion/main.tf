# create baston_host
resource "aws_instance" "bastion" {
  ami                         = var.redhat
  instance_type               = "t2.micro"
  subnet_id                   = var.pub1-name
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion-sg]
  key_name                    = var.pub-key
  user_data                   = local.bastion-userdata
  tags = {
    Name = var.bastion-server-name
  }
}