# Fintech Infrastructure

- Diagram (open this file to view architecture): [architecture.drawio.png](architecture.drawio.png)

Overview
- This repo defines infrastructure for a document verification service using App Runner, CloudFront, Route53, WAF, ACM and a CI/CD pipeline (CodePipeline + CodeBuild).
- Main Terraform entry: [main.tf](main.tf)

Security practices implemented (with code references)
- Web Application Firewall (WAF)
  - IP blocklist: [`aws_wafv2_ip_set.malicious_ips`](modules/waf/main.tf) — Sourced from `var.blocked_ips` ([variables.tf](variables.tf))
  - Web ACL with blocking rule: [`aws_wafv2_web_acl.this`](modules/waf/main.tf)
  - Logging to hardened S3: [`aws_wafv2_web_acl_logging_configuration.this`](modules/waf/main.tf) + [`aws_s3_bucket.waf_logs`](modules/waf/main.tf)
  - S3 log delivery policy and encryption: [`data.aws_iam_policy_document.waf_logs`](modules/waf/main.tf), [`aws_s3_bucket_server_side_encryption_configuration.waf_logs`](modules/waf/main.tf), [`aws_s3_bucket_public_access_block.waf_logs`](modules/waf/main.tf)
  - WAF output: [`module.waf.waf_web_acl_arn`](modules/waf/outputs.tf)

- TLS / Certificate management
  - ACM certificate + DNS validation: [`aws_acm_certificate.this`](modules/acm_certificate/main.tf), validation records: [`aws_route53_record.validation`](modules/acm_certificate/main.tf), and validation resource: [`aws_acm_certificate_validation.this`](modules/acm_certificate/main.tf)
  - ACM output: [`module.acm_certificate.acm_certificate_arn`](modules/acm_certificate/outputs.tf)

- CDN (CloudFront)
  - CloudFront distribution with TLS minimum TLSv1.2_2021 and viewer certificate: [`aws_cloudfront_distribution.this`](modules/cloudfront/main.tf)
  - CloudFront associates a WAF Web ACL via `web_acl_id` (input `waf_web_acl_arn` in [modules/cloudfront/variables.tf](modules/cloudfront/variables.tf))

- Secrets & least-privilege IAM
  - App Runner reads secrets from Secrets Manager using `runtime_environment_secrets`: see [`aws_apprunner_service.this`](modules/apprunner/main.tf) and `var.secret_arn` ([modules/apprunner/vairbales.tf](modules/apprunner/vairbales.tf))
  - IAM role for App Runner with scoped SecretsManager and ECR actions: [`aws_iam_role.apprunner_access`](modules/iam_apprunner_role/main.tf) and [`aws_iam_role_policy.apprunner_policy`](modules/iam_apprunner_role/main.tf)

- CI/CD (CodePipeline & CodeBuild)
  - CodeBuild project: [`aws_codebuild_project.build`](modules/cicd/main.tf) using [buildspec.yml](buildspec.yml)
  - CodePipeline: [`aws_codepipeline.pipeline`](modules/cicd/main.tf) with CodeStar connection configured (no plaintext GitHub creds)
  - Artifacts bucket variable: `var.artifact_bucket` ([modules/cicd/variables.tf](modules/cicd/variables.tf), [terraform.tfvars](terraform.tfvars))

- DNS / routing
  - Route53 alias A record pointing to CloudFront: [`aws_route53_record.this`](modules/route53/main.tf)
  - Route53 output: [`module.route53.route53_record_fqdn`](modules/route53/outputs.tf)

Quick links (important files)
- Root: [main.tf](main.tf), [variables.tf](variables.tf), [providers.tf](providers.tf), [terraform.tfvars](terraform.tfvars), [outputs.tf](outputs.tf)
- CI/CD: [modules/cicd/main.tf](modules/cicd/main.tf), [modules/cicd/variables.tf](modules/cicd/variables.tf), [buildspec.yml](buildspec.yml)
- App Runner: [modules/apprunner/main.tf](modules/apprunner/main.tf), [modules/apprunner/vairbales.tf](modules/apprunner/vairbales.tf)
- WAF: [modules/waf/main.tf](modules/waf/main.tf), [modules/waf/outputs.tf](modules/waf/outputs.tf)
- CloudFront: [modules/cloudfront/main.tf](modules/cloudfront/main.tf), [modules/cloudfront/variables.tf](modules/cloudfront/variables.tf), [modules/cloudfront/output.tf](modules/cloudfront/output.tf)
- ACM: [modules/acm_certificate/main.tf](modules/acm_certificate/main.tf), [modules/acm_certificate/outputs.tf](modules/acm_certificate/outputs.tf)
- IAM (App Runner): [modules/iam_apprunner_role/main.tf](modules/iam_apprunner_role/main.tf)
- Route53: [modules/route53/main.tf](modules/route53/main.tf), [modules/route53/outputs.tf](modules/route53/outputs.tf)

Notes / Review — issues found (actionable)
- Output / variable name mismatches (fix to avoid runtime errors)
  - Root `main.tf` references `module.acm_certificate.certificate_arn` but module output is [`module.acm_certificate.acm_certificate_arn`](modules/acm_certificate/outputs.tf). Update one to match ([main.tf](main.tf), [modules/acm_certificate/outputs.tf](modules/acm_certificate/outputs.tf)).
  - Root expects `module.cloudfront.domain_name` but `modules/cloudfront/output.tf` exposes `apprunner_domain_name` and does not output the CloudFront domain. Add output `domain_name = aws_cloudfront_distribution.this.domain_name` in [modules/cloudfront/output.tf](modules/cloudfront/output.tf) and/or update references in [main.tf](main.tf) and [modules/route53/main.tf](modules/route53/main.tf).
  - Root `outputs.tf` references `module.waf.waf_arn` but WAF module outputs [`module.waf.waf_web_acl_arn`](modules/waf/outputs.tf). Make these consistent ([outputs.tf](outputs.tf), [modules/waf/outputs.tf](modules/waf/outputs.tf)).

- Naming / typos to normalize
  - Variable filenames inconsistent: `modules/apprunner/vairbales.tf` (typo) and `modules/iam_apprunner_role/variable.tf` (singular). Rename to `variables.tf` for clarity and tooling compatibility ([modules/apprunner/vairbales.tf](modules/apprunner/vairbales.tf), [modules/iam_apprunner_role/variable.tf](modules/iam_apprunner_role/variable.tf)).

- CI/CD environment variables
  - `buildspec.yml` calls `aws apprunner update-service --service-arn $APP_RUNNER_SERVICE_ARN` — ensure CodeBuild receives `APP_RUNNER_SERVICE_ARN` (e.g., via CodeBuild environment variables or parameter store). See CodeBuild project: [`aws_codebuild_project.build`](modules/cicd/main.tf) and pipeline deploy stage configuration: [`aws_codepipeline.pipeline`](modules/cicd/main.tf).

- Principle of least privilege
  - The App Runner role currently allows ECR and CloudWatch logs with Resource = "*" in [`aws_iam_role_policy.apprunner_policy`](modules/iam_apprunner_role/main.tf). Consider scoping ECR and logs permissions to specific ARNs.

How to deploy
- Initialize & apply terraform at repo root:
  - terraform init
  - terraform plan
  - terraform apply
  See provider config: [providers.tf](providers.tf) and backend config in [providers.tf](providers.tf).

Next steps / suggestions
- Fix the naming mismatches listed above and re-run `terraform validate`.
- Scope IAM permissions narrower (replace "*" with specific ARNs where possible).
- Ensure secrets and sensitive ARNs in [terraform.tfvars](terraform.tfvars) are stored securely (CI/CD secrets manager or remote secret store) and remote state is encrypted (backend already uses S3 — ensure encryption + locking).

If you want, I can:
- Generate the suggested fixes as a small diff for the TF files noted above.
- Add a CloudFront output (`domain_name`) and align the ACM/WAF output names to match `main.tf`.
