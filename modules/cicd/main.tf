
resource "aws_codebuild_project" "build" {
  name         = "${var.project}-${var.environment}-build"
  description  = "Build project for ${var.project}"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ECR_REPO"
      value = var.ecr_repository_url
    }
  }
source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.root}/buildspec.yml")  
}

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.project}-${var.environment}-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  # Source stage (GitHub via CodeStar Connection)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = var.github_repo
        BranchName       = var.github_branch
      }
    }
  }

  # Build stage
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  # Deploy stage (App Runner)
  stage {
    name = "Deploy"

    action {
      name            = "DeployToAppRunner"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "AppRunner"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ServiceArn = var.apprunner_service_arn
      }
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
