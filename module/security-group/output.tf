output "sonarqube-sg-id" {
  value = aws_security_group.sonarqube-sg.id
}
output "ansible-sg-id" {
  value = aws_security_group.ansible-sg.id
}
output "nexus-sg-id" {
  value = aws_security_group.nexus-sg.id
}
output "Jenkins-sg-id" {
  value =  aws_security_group.jenkins-sg.id
}
output "docker-sg-id" {
  value = aws_security_group.docker-sg.id
}
output "bastion-sg-id" {
  value = aws_security_group.bastion-sg.id
}
output "rds-sg-id" {
  value = aws_security_group.rds-sg.id
}
