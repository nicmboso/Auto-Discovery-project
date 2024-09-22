output "vpc-id" {
  value = aws_vpc.pet-vpc.id
}

output "pubsn-1-id" {
  value = aws_subnet.pubsn-1.id
}

output "pubsub-2-id" {
  value = aws_subnet.pubsn-2.id
}

output "prvsub-1-id" {
  value = aws_subnet.prvsn-1.id
}

output "prvsub-2-id" {
  value = aws_subnet.prvsn-2.id
}