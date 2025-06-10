# test principal type not AWS
resource "aws_s3_bucket_public_access_block" "negative" {
  count = length(var.negative)

  bucket = var.negative[count.index]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "negative" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:Delete*",
    ]

    resources = [
      var.negative,
      "${var.negative}/*",
    ]
  }
}

#   "Action": "s3:Delete", "Principal":"*" and "Type":"Service"
resource "aws_s3_bucket_policy" "negative" {
  depends_on = [aws_s3_bucket_public_access_block.negative]
  bucket     = var.negative
  policy     = data.aws_iam_policy_document.negative.json
}