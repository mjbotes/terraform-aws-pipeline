# Quick Start Guide

## Prerequisites
- AWS Account
- GitHub Account
- Git installed locally

## Setup (5 minutes)

### 1. Setup AWS OIDC Provider (One-time)
AWS Console → IAM → Identity providers → Add provider:
- Provider type: OpenID Connect
- Provider URL: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

### 2. Create IAM Role
AWS Console → IAM → Roles → Create role:

**Trust Policy** (replace `<GITHUB_USERNAME>` and `<REPO_NAME>`):
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": "repo:<GITHUB_USERNAME>/<REPO_NAME>:ref:refs/heads/main"
                }
            }
        }
    ]
}
```

**Attach these AWS managed policies:**
- `AmazonEC2FullAccess`
- `AmazonRDSFullAccess`
- `AmazonEC2ContainerRegistryFullAccess`
- `IAMFullAccess`
- `AmazonSSMFullAccess`
- `AWSLambda_FullAccess`
- `CloudWatchEventsFullAccess`

### 3. Configure GitHub Secrets
Go to: Repository → Settings → Secrets and variables → Actions

Add these secrets:
```
AWS_ROLE_ARN=arn:aws:iam::<AWS_ACCOUNT_ID>:role/<ROLE_NAME>
AWS_ACCOUNT_ID=<your-12-digit-account-id>
```

### 4. Configure GitHub Environment
Go to: Repository → Settings → Environments

1. Click "New environment"
2. Name: `production`
3. Check "Required reviewers"
4. Add yourself as reviewer
5. Save

### 5. Deploy
```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

### 6. Monitor Pipeline
Go to: Repository → Actions

Watch the pipeline execute:
- ⏸️ Terraform (waiting for approval)
- Click "Review deployments" → Approve
- ✅ Terraform (5 min)
- ✅ Build (2 min)
- ✅ Deploy (1 min)

### 7. Access Application
Check Actions output for public IP:
```
http://<public-ip>
```

You should see: "Hello World"

## Cost Optimization Features

### Automatic Shutdown
- Resources tagged with `AutoShutdown=true` stop daily at 6 PM UTC
- Lambda function automatically stops EC2 and RDS instances
- Saves ~70% on compute costs for demo environments

### Cost-Optimized Configuration
- RDS: Single-AZ, no backups, no multi-AZ
- EC2: t2.micro (free tier eligible)
- No NAT Gateway (uses public subnets)
- Local Terraform state (no S3 costs)

## Destroy Infrastructure

### Option 1: GitHub Actions (Recommended)
1. Go to: Repository → Actions
2. Click "CI/CD Pipeline" → "Run workflow"
3. Select "destroy" from dropdown
4. Click "Run workflow"
5. Wait ~3 minutes for complete destruction

### Option 2: Local Terraform
```bash
cd infra
terraform destroy -auto-approve
```

### Option 3: AWS Console
Manually delete resources in this order:
1. EC2 instances
2. RDS databases
3. ECR repositories
4. Lambda functions
5. VPC and subnets

## Troubleshooting

**Pipeline fails at Terraform?**
- Check AWS role ARN is correct
- Verify OIDC provider is configured
- Ensure role trust policy matches your repo
- Add Lambda and CloudWatch permissions to IAM role

**Can't access web page?**
- Wait 2-3 minutes after deployment
- Check EC2 instance is running
- Verify security group allows port 80

**Approval not showing?**
- Ensure "production" environment exists
- Add yourself as required reviewer

## Clean Up

**Automatic Destruction:**
```bash
# Via GitHub Actions
Repository → Actions → Run workflow → Select "destroy"
```

**Manual Destruction:**
```bash
cd infra
terraform destroy -auto-approve
```

## Next Steps
- Read README.md for detailed documentation
- Review CTO_PRESENTATION.md for architecture details
- Customize Dockerfile for your application
- Add monitoring and alerting
