# ec2がssmを利用するためのベースポリシー
data "aws_iam_policy" "ec2_for_ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# cloudwatch logsとs3への書き込みを許可
data "aws_iam_policy_document" "policy_document" {
  source_policy_documents = [data.aws_iam_policy.ec2_for_ssm.policy]

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "kms:Decrypt"
    ]
  }
}

# インスタンスプロファイルに紐付けるIAMロール
module "ec2_for_ssm_role" {
  source     = "../iam"
  name       = "ec2forssm"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.policy_document.json
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = module.ec2_for_ssm_role.iam_role_name
}

# EC2インスタンスの作成
resource "aws_instance" "ec2_instance" {
  ami                  = "ami-0bba69335379e17f8"
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  subnet_id            = var.private_subnet_0_id
  user_data            = file("./computing/user_data.sh")
}