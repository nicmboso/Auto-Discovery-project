output "prod-id" {
  value = aws_autoscaling_group.prod-asg.id
}

output "prod-name" {
  value = aws_autoscaling_group.prod-asg.name
}

output "Prod-lt-id" {
  value = aws_launch_template.prod_lt.image_id
}