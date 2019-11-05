data "local_file" "template_body" {
  filename = "${path.module}/templates/elastic-ip-manager.yaml"
}

resource "aws_cloudformation_stack" "elastic-ip-manager" {
  name          = "elastic-ip-manager"
  template_body = data.local_file.template_body.content
  capabilities  = ["CAPABILITY_IAM"]
}