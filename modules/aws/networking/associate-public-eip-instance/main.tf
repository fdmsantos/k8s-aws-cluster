resource "aws_eip" "public-ip" {
  vpc              = true
  public_ipv4_pool = "amazon"
  instance         = var.instance_id
}
