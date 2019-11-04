resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = var.assume_role_policy
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
  count = var.create_instance_profile == false ? 0 : 1
  name  = var.name
  role  = aws_iam_role.role.name
}