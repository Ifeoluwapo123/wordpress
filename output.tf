output "ELB_DNS" {
  value     = aws_elb.default.dns_name
}

output "Blog_DNS" {
  value     = aws_instance.wb1.public_dns
#   sensitive = true
}

output "DB_HOST" {
  value = aws_db_instance.default.address
}
