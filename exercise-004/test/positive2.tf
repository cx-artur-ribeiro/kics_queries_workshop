# test action "s3:*"
resource "aws_s3_bucket_public_access_block" "positive2" {
  count = length(var.positive2)

  bucket = var.positive2[count.index]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "positive2" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      var.positive2,
      "${var.positive2}/*",
    ]
  }
}

#   "Action": "s3:Delete", "Principal":"*" and "Type":"AWS"
resource "aws_s3_bucket_policy" "positive2" {
  depends_on = [aws_s3_bucket_public_access_block.positive2]
  bucket     = var.positive2
  policy     = data.aws_iam_policy_document.positive2.json
}