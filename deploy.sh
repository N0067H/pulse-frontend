#!/bin/bash
set -e

BUCKET=$(cd infra && terraform output -raw s3_bucket_name)
DIST_ID=$(cd infra && terraform output -raw cloudfront_distribution_id)

npm run build
aws s3 sync build/ "s3://$BUCKET" --delete
aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*"

echo "Deployed: $(cd infra && terraform output -raw cloudfront_url)"
