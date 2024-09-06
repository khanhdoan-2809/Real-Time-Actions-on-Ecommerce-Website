data "archive_file" "lambda_archive" {
  source_dir    = "${path.root}../../../src"
  output_path   = "${path.root}../../../src/lambda-archive.zip"
  type          = "zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name       = "lambda"
  handler             = "process_data.lambda_handler"
  runtime             = "python3.11"
  role                = var.mv_lambda_role
  filename            = data.archive_file.lambda_archive.output_path
  source_code_hash    = data.archive_file.lambda_archive.output_base64sha256
  timeout             = 30
  memory_size         = 128
}

resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    principal     = "apigateway.amazonaws.com"
    function_name = aws_lambda_function.lambda_function.function_name
    source_arn    = var.mv_api_gatway_arn
}