output "nameservers" {
  value = aws_route53_zone.main.name_servers
}

output "public_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "private_zone_id" {
  value = aws_route53_zone.private.zone_id
}

output "public_domain" {
  value = aws_route53_zone.main.name
}

output "private_domain" {
  value = aws_route53_zone.private.name
}