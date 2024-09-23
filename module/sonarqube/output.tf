output "sonarqube-ip" {
  value = aws_instance.sonarqube.public_ip
}

output "sonarqube-dns" {
  value = aws_elb.sonarqube-elb.dns_name
}

output "sonarqube-zone-id" {
  value = aws_elb.sonarqube-elb.zone_id
}
