#Create nexus server
resource "aws_instance" "nexus" {
  ami                         = var.redhat
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = var.pubsn1
  key_name                    = var.pub-key
  vpc_security_group_ids      = [var.nexus-sg]
  # user_data = file("./modules/nexus/nexus-script.sh")
  user_data = base64encode(templatefile("./module/nexus/nexus-script.sh", {
    nexus-ip = var.nexus-ip,
    newrelic-license-key = var.nr-user-licence,
    newrelic-account-id = var.nr-acct-id,
    newrelic-region = var.nr-region

  }))

  tags = {
    Name = var.nexus-server-name
  }
}

#elb
resource "aws_elb" "nexus_lb" {
  name            = "nexus-lb"
  subnets         = var.pub-subnets
  security_groups = [var.nexus-sg]
  listener {
    instance_port      = 8081
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.cert-arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8081"
    interval            = 30
  }

    instances                   = [aws_instance.nexus.id]
    cross_zone_load_balancing   = true
    idle_timeout                = 400
    connection_draining         = true
    connection_draining_timeout = 400

    tags = {
      Name = "nexus-elb"
  }
}