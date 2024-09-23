#sonarqube instance
resource "aws_instance" "sonarqube" {
  ami                         = var.ubuntu
  instance_type               = "t2.medium"
  key_name                    = var.pub-key
  vpc_security_group_ids      = [var.sonarqube-sg]
  subnet_id                   = var.pubsn1
  associate_public_ip_address = true
  # user_data = file("./module/sonarqube/sonarqube-script.sh")
  user_data = base64encode(templatefile("./module/sonarqube/sonarqube-script.sh", {
    # nexus-ip = var.nexus-ip,
    newrelic-license-key = var.nr-user-licence,
    newrelic-account-id = var.nr-acct-id,
    newrelic-region = var.nr-region

  }))
  tags = {
    Name = var.sonarqube-server-name
  }
}

#elb
# Create an elastic load balancer
resource "aws_elb" "sonarqube-elb" {
  name               = "sonarqube-elb"
  security_groups    = [var.sonarqube-sg]
  subnets = [var.pub-subnets]

  listener {
    instance_port     = 9000
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id = var.cert-arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:9000"
    interval            = 30
  }

  instances                   = [aws_instance.sonarqube.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = var.sonarqube-elb
  }
}
