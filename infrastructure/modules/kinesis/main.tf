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