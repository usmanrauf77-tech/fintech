module "acm_certificate" {
  source           = "./modules/acm_certificate"
  domain_name      = var.domain_name
  route53_zone_id  = var.hosted_zone_id
  project          = var.project
  environment      = var.environment
}
module "iam_apprunner_role" {
  source      = "./modules/iam_apprunner_role"
  project     = var.project
  environment = var.environment
  secret_arn  = var.secret_arn
}

module "app_runner" {
  source             = "./modules/apprunner"
  project            = var.project
  environment        = var.environment
  secret_arn         = var.secret_arn
  auto_scaling_arn   = var.auto_scaling_arn
  ecr_repository_url = var.ecr_repository_url
  access_role_arn    = var.access_role_arn
}

module "cloudfront" {
  source                = "./modules/cloudfront"
  apprunner_domain_name = module.app_runner.service_url
  acm_cert_arn          = module.acm_certificate.certificate_arn
  project               = var.project
  environment           = var.environment
}

module "route53" {
  source                 = "./modules/route53"
  hosted_zone_id         = var.hosted_zone_id
  subdomain_name         = var.subdomain
  cloudfront_domain_name = module.cloudfront.domain_name
}

module "waf" {
  source        = "./modules/waf"
  project       = var.project
  environment   = var.environment
  blocked_ips   = var.blocked_ips
}



module "cicd" {
  source                = "./modules/cicd"
  project               = var.project
  environment           = var.environment
  apprunner_service_arn = module.app_runner.service_arn
  github_connection_arn = var.github_connection_arn
  artifact_bucket       = var.artifact_bucket
  github_repo           = var.github_repo
  ecr_repository_url    = var.ecr_repository_url
  codepipeline_role_arn = var.codepipeline_role_arn
  codebuild_role_arn    = var.codebuild_role_arn
  github_branch         = var.github_branch
}

