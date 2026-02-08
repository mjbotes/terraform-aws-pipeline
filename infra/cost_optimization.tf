# Auto-shutdown Lambda for cost optimization
resource "aws_lambda_function" "auto_shutdown" {
  filename         = "auto_shutdown.zip"
  function_name    = "auto-shutdown-resources"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 60

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = {
    Environment = "demo"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "auto_shutdown.zip"
  source {
    content = <<EOF
import boto3
import json

def handler(event, context):
    ec2 = boto3.client('ec2')
    rds = boto3.client('rds')
    
    # Stop EC2 instances with AutoShutdown tag
    instances = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:AutoShutdown', 'Values': ['true']},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            print(f"Stopping instance: {instance['InstanceId']}")
            ec2.stop_instances(InstanceIds=[instance['InstanceId']])
    
    # Stop RDS instances with AutoShutdown tag
    databases = rds.describe_db_instances()
    for db in databases['DBInstances']:
        if db['DBInstanceStatus'] == 'available':
            tags = rds.list_tags_for_resource(ResourceName=db['DBInstanceArn'])
            for tag in tags['TagList']:
                if tag['Key'] == 'AutoShutdown' and tag['Value'] == 'true':
                    print(f"Stopping database: {db['DBInstanceIdentifier']}")
                    rds.stop_db_instance(DBInstanceIdentifier=db['DBInstanceIdentifier'])
    
    return {'statusCode': 200, 'body': json.dumps('Resources stopped')}
EOF
    filename = "index.py"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "auto-shutdown-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "auto-shutdown-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "rds:DescribeDBInstances",
          "rds:StopDBInstance",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

# Schedule to run every evening at 6 PM UTC
resource "aws_cloudwatch_event_rule" "auto_shutdown_schedule" {
  name                = "auto-shutdown-schedule"
  description         = "Trigger auto-shutdown Lambda"
  schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.auto_shutdown_schedule.name
  target_id = "AutoShutdownLambdaTarget"
  arn       = aws_lambda_function.auto_shutdown.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_shutdown.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_shutdown_schedule.arn
}