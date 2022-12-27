# ポリシードキュメントの定義
data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect = "Allow"
    actions = ["ec2:DescribeRegions"]
    resources = ["*"]
  }
}

# IAMポリシー
resource "aws_iam_policy" "policy_example" {
  name = var.name
  policy = data.aws_iam_policy_document.allow_describe_regions.json
}

# 信頼ポリシーの定義
data "aws_iam_policy_document" "ec2_assume_role" {
    statement {
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = [ var.identifier ]
      }
    }
}