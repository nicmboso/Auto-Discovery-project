output "alb-production-dns" {
  value = aws_lb.alb-production.dns_name
}

output "alb-production-arn" {
  value = aws_lb.alb-production.arn
}

output "alb-production-zoneid" {
  value = aws_lb.alb-production.zone_id
}

output "tg-production-arn" {
  value = aws_lb_target_group.lb-tg-production.arn
}