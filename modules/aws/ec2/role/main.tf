data "template_file" "ec2-assume-role-policy" {
  template = file("${path.module}/templates/assume-role-policy.tpl")
}


resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.template_file.ec2-assume-role-policy.rendered
  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "role-attach" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.role.name
  policy_arn = var.policy_arns[count.index]
}

resource "aws_iam_instance_profile" "profile" {
  name  = var.name
  role  = aws_iam_role.role.name
}