output "pipeline_name" {
  description = "Name of CodePipeline"
  value       = aws_codepipeline.pipeline.name
}

output "codebuild_project_name" {
  description = "Name of CodeBuild project"
  value       = aws_codebuild_project.build.name
}
