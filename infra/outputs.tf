output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
