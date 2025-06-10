# test action "s3:Delete*"
resource "aws_s3_bucket_public_access_block" "positive1" {
  count = length(var.positive1)

  bucket = var.positive1[count.index]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "positive1" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:Delete*",
    ]

    resources = [
      var.positive1,
      "${var.positive1}/*",
    ]
  }
}

#   "Action": "s3:Delete", "Principal":"*" and "Type":"AWS"
resource "aws_s3_bucket_policy" "positive1" {
  depends_on = [aws_s3_bucket_public_access_block.positive1]
  bucket     = var.positive1
  policy     = data.aws_iam_policy_document.positive1.json
}