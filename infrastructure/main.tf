module "iam" {
  source                = "./modules/iam"
  mv_kinesis_stream_arn = module.kinesis.arn
  mv_bucket_arn         = module.s3.bucket_arn
}

module "kinesis" {
  source                    = "./modules/kinesis"
  mv_kinesis_stream_name    = var.lv_kinesis_stream_name 
  mv_kinesis_firehose_name  = var.lv_kinesis_firehose_name
  mv_bucket_arn             = module.s3.bucket_arn
  mv_firehose_role_arn      = module.iam.kinesis_execution_role_arn
}

module "s3" {
  source                = "./modules/s3"
  mv_bucket_name        = var.lv_bucket_name
}
