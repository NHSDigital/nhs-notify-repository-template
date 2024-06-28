output "aws_account_id" {
  value = var.aws_account_id
}

output "r53_delegation_set_id" {
  value = aws_route53_delegation_set.main.id
}

output "r53_delegation_set_nameservers" {
  value = aws_route53_delegation_set.main.name_servers
}

output "r53_subdomain_name" {
  value = var.subdomain_name
}

output "r53_subdomain_id" {
  value = one(aws_route53_zone.subdomain[*].id)
}
