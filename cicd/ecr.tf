# ECRリポジトリの定義
resource "aws_ecr_repository" "ecr" {
  name = "ecr_repository"
}

# ECRライフサイクルポリシーの定義
resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = file("./cicd/ecr_policy.json")
}