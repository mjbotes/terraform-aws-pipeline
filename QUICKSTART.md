# Quick Start Guide

## Prerequisites
- AWS Account
- GitHub Account
- Git installed locally

## Setup (5 minutes)

### 1. Configure GitHub Secrets
Go to: Repository → Settings → Secrets and variables → Actions

Add these secrets:
```
AWS_ACCESS_KEY_ID=<your-access-key>
AWS_SECRET_ACCESS_KEY=<your-secret-key>
AWS_ACCOUNT_ID=<your-12-digit-account-id>
```

### 2. Configure GitHub Environment
Go to: Repository → Settings → Environments

1. Click "New environment"
2. Name: `production`
3. Check "Required reviewers"
4. Add yourself as reviewer
5. Save

### 3. Deploy
```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

### 4. Monitor Pipeline
Go to: Repository → Actions

Watch the pipeline execute:
- ✅ Terraform (5 min)
- ✅ Build (2 min)
- ⏸️ Approval (waiting for you)
- Click "Review deployments" → Approve
- ✅ Deploy (1 min)

### 5. Access Application
Check Actions output for public IP:
```
http://<public-ip>
```

You should see: "Hello World"

## Verify Infrastructure

### AWS Console
1. EC2 → Instances → "web-server" (running)
2. RDS → Databases → "mydb" (available)
3. ECR → Repositories → "app-repository" (1 image)

### Terraform Outputs
```bash
cd infra
terraform output
```

## Troubleshooting

**Pipeline fails at Terraform?**
- Check AWS credentials are correct
- Verify AWS account has necessary permissions

**Can't access web page?**
- Wait 2-3 minutes after deployment
- Check EC2 instance is running
- Verify security group allows port 80

**Approval not showing?**
- Ensure "production" environment exists
- Add yourself as required reviewer

## Clean Up

To destroy all resources:
```bash
cd infra
terraform destroy -auto-approve
```

## Next Steps
- Read README.md for detailed documentation
- Review CTO_PRESENTATION.md for architecture details
- Customize Dockerfile for your application
- Add monitoring and alerting
