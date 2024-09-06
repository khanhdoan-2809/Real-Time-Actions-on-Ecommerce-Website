####################################################################
# Kinesis Stream
####################################################################
resource "aws_kinesis_stream" "main" {
  name              = var.mv_kinesis_stream_name
  shard_count       = 1
  retention_period  = 48 # length of time that data records are accessible after they are added to the stream

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

####################################################################
# Kinesis Firehose
####################################################################
resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose" {
  name        = var.mv_kinesis_firehose_name
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.main.arn
    role_arn           = var.mv_firehose_role_arn
  }

  extended_s3_configuration {
    role_arn   = var.mv_firehose_role_arn
    bucket_arn = var.mv_bucket_arn 
  }

  depends_on = [aws_kinesis_stream.main]
}