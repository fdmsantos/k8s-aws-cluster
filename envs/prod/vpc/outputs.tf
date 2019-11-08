output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_ids" {
  value = module.vpc.public_subnets
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_private_route_table" {
  value = module.vpc.private_route_table_ids[0]
}

output "vpc_public_route_table" {
  value = module.vpc.public_route_table_ids[0]
}