# Create Launch Template
resource "aws_launch_template" "prod_lt" {
  image_id               = var.redhat
  instance_type          = "t2.medium"
  vpc_security_group_ids = [var.docker-sg]
  key_name               = var.pub-key
  user_data = base64encode(templatefile("./module/production-asg/docker-script.sh", {
    nexus-ip = var.nexus-ip,
    newrelic-license-key = var.nr-user-licence,
    newrelic-account-id = var.nr-acct-id,
    newrelic-region = var.nr-region

  }))
}

#Create AutoScaling Group
resource "aws_autoscaling_group" "prod-asg" {
  name                      = var.prod-name
  desired_capacity          = 1
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = var.vpc-zone-id
  target_group_arns         = [var.lb-target-grp-arn]
  launch_template {
    id      = aws_launch_template.prod_lt.id
  }
  tag {
    key                 = "Name"
    value               = var.prod-name
    propagate_at_launch = true
  }
}

#Create ASG Policy
resource "aws_autoscaling_policy" "prod-asg-policy" {
  name                   = "prod-asg-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.prod-asg.id
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}