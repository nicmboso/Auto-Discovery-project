output "stage-id" {
  value = aws_autoscaling_group.stage-asg.id
}

output "stage-name" {
  value = aws_autoscaling_group.stage-asg.name
}

output "stage-lt-id" {
  value = aws_launch_template.stage_lt.image_id
}