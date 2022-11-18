output "vpc_id" {
  value = aws_vpc.main.id
}

output "publicsub_id" {
  value = aws_subnet.publicsub.*.id
}

output "privatesub_id" {
  value = aws_subnet.privatesub.*.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}