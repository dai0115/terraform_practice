# IAMロールの定義
resource "aws_iam_role" "role_example" {
  name = var.name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# IAMポリシーとIAMロールの関連付け
resource "aws_iam_role_policy_attachment" "attachment_example" {
  role = aws_iam_role.role_example.name
  policy_arn = aws_iam_policy.policy_example.arn
}

# 作成したIAMロールのarnと名前を出力する
output "iam_role_arn" {
  value = aws_iam_role.role_example.arn
}

output "iam_role_name" {
  value = aws_iam_role.role_example.name
}