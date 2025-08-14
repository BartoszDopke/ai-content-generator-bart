resource "random_integer" "random" {
  min = 100
  max = 1000
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "aicontentgeneratorbucket${random_integer.random.result}"
}

resource "aws_s3_bucket_ownership_controls" "frontend_bucket" {
  depends_on = [aws_s3_bucket_public_access_block.frontend_bucket]

  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "frontend_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.frontend_bucket]

  bucket = aws_s3_bucket.frontend_bucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "index.html"
  source = replace(
    replace(
      file("frontend/index.html"),
      "${lambda_function_url}",
      aws_lambda_function_url.backend.function_url
    ),
    "${gemini_api_key}",
    var.gemini_api_key
  )
  content_type = "text/html"
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  depends_on = [aws_s3_bucket_public_access_block.frontend_bucket]

  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })
}