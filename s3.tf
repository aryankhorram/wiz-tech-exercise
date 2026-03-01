resource "aws_s3_bucket" "mongo_backups" {
  bucket        = var.backup_bucket_name
  force_destroy = true
}

# allow public bucket policy (intentionally insecure per assignment)
resource "aws_s3_bucket_public_access_block" "mongo_backups" {
  bucket = aws_s3_bucket.mongo_backups.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.mongo_backups.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.mongo_backups.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.mongo_backups]
}