####################################################################
# Kinesis
####################################################################
data "aws_iam_policy_document" "kinesis_execution_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kinesis_execution_role" {
  name               = "kinesis_execution_role"
  assume_role_policy = data.aws_iam_policy_document.kinesis_execution_policy.json
}

####################################################################
# Allows Firehose to write data to S3 bucket
####################################################################
data "template_file" "kinesis_s3" {
  template = file("${path.root}/policies/kinesis_s3.json")

  vars = {
    bucket_arn  = var.mv_bucket_arn
  }
}

resource "aws_iam_policy" "firehose_s3_policy" {
  name        = "firehose_s3_policy"
  description = "Allows Firehose to write data to S3 bucket"
  policy      = data.template_file.kinesis_s3.rendered
}

####################################################################
# Grants certain permissions related to Kinesis Stream operations
####################################################################
data "template_file" "kinesis_stream" {
  template = file("${path.root}/policies/kinesis_stream.json")

  vars = {
    kinesis_stream_arn  = var.mv_kinesis_stream_arn
  }
}

resource "aws_iam_policy" "kinesis_stream_policy" {
  name        = "kinesis_stream_policy"
  description = "Grants certain permissions related to Kinesis Stream operations"
  policy      = data.template_file.kinesis_stream.rendered
}

resource "aws_iam_role_policy_attachment" "firehose_s3_policy_attachment" {
  role        = aws_iam_role.kinesis_execution_role.name
  policy_arn  = aws_iam_policy.firehose_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "kiensis_stream_policy_attachment" {
  role        = aws_iam_role.kinesis_execution_role.name
  policy_arn  = aws_iam_policy.kinesis_stream_policy.arn
}

####################################################################
# Lambda
####################################################################
data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_execution_policy.json
}

data "template_file" "lambda" {
  template = file("${path.root}/policies/lambda.json")

  vars = {
    kinesis_stream_arn  = var.mv_kinesis_stream_arn
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "allows Lambda to write data to Kinesis stream."
  policy      = data.template_file.lambda.rendered
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name   = "lambda_function_policy"
  policy = data.template_file.lambda.rendered
}

resource "aws_iam_role_policy_attachment" "sqs_lambda_role_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}