# codepipelineから各サービスを動かすためのポリシー
data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "codestar-connections:CreateConnection",
      "codestar-connections:DeleteConnection",
      "codestar-connections:UseConnection",
      "codestar-connections:GetConnection",
      "codestar-connections:ListConnections",
      "codestar-connections:TagResource",
      "codestar-connections:ListTagsForResource",
      "codestar-connections:UntagResource",
      "iam:PassRole"
    ]
  }
}

# pipeline用のIAMロールの作成
module "codepipeline_role" {
  source     = "../iam"
  name       = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}

# codestarconnectionを利用してgithubと連携する
resource "aws_codestarconnections_connection" "codestarconnections" {
  name          = "github-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "codepipeline"
  role_arn = module.codepipeline_role.iam_role_arn

  # ソースステージ
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = 1
      output_artifacts = ["Source"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.codestarconnections.arn
        FullRepositoryId = "dai0115/sample_project"
        BranchName       = "main"
      }
    }
  }

  # ビルドステージ
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.id
      }
    }
  }

  # デプロイステージ
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build"]

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinition.json"
      }
    }
  }

  # アーティファクトの保存場所の定義
  artifact_store {
    location = var.artifact_bucket_id
    type     = "S3"
  }
}

resource "aws_codepipeline_webhook" "webhook" {
  name            = "webhook"
  target_pipeline = aws_codepipeline.codepipeline.name
  target_action   = "Source"
  authentication  = "GITHUB_HMAC"
  authentication_configuration {
    secret_token = "VeryRandomStringMoreThan20Byte"
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/head/{Branch}"
  }
}