# test action "*"
resource "aws_s3_bucket_public_access_block" "positive3" {
  count = length(var.positive3)

  bucket = var.positive3[count.index]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "positive3" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "*",
    ]

    resources = [
      var.positive3,
      "${var.positive3}/*",
    ]
  }
}

#   "Action": "s3:Delete", "Principal":"*" and "Type":"AWS"
resource "aws_s3_bucket_policy" "positive3" {
  depends_on = [aws_s3_bucket_public_access_block.positive3]
  bucket     = var.positive3
  policy     = data.aws_iam_policy_document.positive3.json
}