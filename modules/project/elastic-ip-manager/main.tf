data "template_file" "policy" {
  template = file("${path.module}/templates/policy.tpl")
}

module "lambda" {
  source        = "github.com/claranet/terraform-aws-lambda"

  function_name = "elastic-ip-manager"
  description   = "Elastic IP manager for Autoscaling Group instances"
  handler       = "manager.handler"
  runtime       = "python3.7"
  timeout       = 600

  // Specify a file or directory for the source code.
  source_path = "${path.module}/code"

  // Attach a policy.
  policy = {
    json = data.template_file.policy.rendered
  }

  tags = {
    terraform   = true
    environment = "prod"
  }
}

resource "aws_cloudwatch_event_rule" "elastic_ip_manager_sync_rule" {
  name                       = "elastic-ip-manager-sync-rule"
  description                = "elastic-ip-manager sync"
  schedule_expression        = "rate(5 minutes)"
  is_enabled                 = true

}

resource "aws_cloudwatch_event_target" "lambda_sync_target" {
  rule      = aws_cloudwatch_event_rule.elastic_ip_manager_sync_rule.name
  target_id = "elastic-ip-manager"
  arn       = module.lambda.function_arn
}

resource "aws_cloudwatch_event_rule" "elastic_ip_manager_rule" {
  name                       = "elastic-ip-manager-rule"
  description                = "elastic-ip-manager"
  is_enabled                 = true
  event_pattern              = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.elastic_ip_manager_rule.name
  target_id = "elastic-ip-manager"
  arn       = module.lambda.function_arn
}