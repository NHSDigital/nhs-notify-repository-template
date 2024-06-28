resource "aws_route53_zone" "subdomain" {
  count = var.subdomain_name != "" ? 1 : 0

  name = var.subdomain_name

  delegation_set_id = aws_route53_delegation_set.main.id
}
