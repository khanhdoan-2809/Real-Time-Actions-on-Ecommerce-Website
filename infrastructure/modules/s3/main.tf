resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.mv_bucket_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true # all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred" # when enable ACL, use this to ensure have full access
  }
}

resource "aws_s3_bucket_acl" "s3_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket] # Wait for the ownership controls to be applied before setting the ACL
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private" # owner have full control, no one else has access rights
}

data "template_file" "bucket_policy" {
  template = file("${path.root}/policies/bucket_policy.json")

  vars = {
    bucket_arn  = aws_s3_bucket.s3_bucket.arn
    service     = "kinesis.amazonaws.com"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.template_file.bucket_policy.rendered
}