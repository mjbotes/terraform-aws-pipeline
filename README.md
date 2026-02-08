# AWS Infrastructure Documentation

## Architecture Overview

This project implements a complete cloud infrastructure with automated CI/CD pipeline on AWS.

### Architecture Diagram
```
GitHub Repository
       ↓
GitHub Actions (CI/CD)
       ↓
   ┌───────────────────────────────────┐
   │         AWS Cloud                 │
   │                                   │
   │  ┌─────────┐      ┌──────────┐  │
   │  │   ECR   │←────→│   EC2    │  │
   │  │Registry │      │Web Server│  │
   │  └─────────┘      └────┬─────┘  │
   │                        │         │
   │                        ↓         │
   │                   ┌────────┐    │
   │                   │  RDS   │    │
   │                   │ MySQL  │    │
   │                   └────────┘    │
   └───────────────────────────────────┘
```

## AWS Services Used

### 1. EC2 (Elastic Compute Cloud)
- **Purpose**: Web server hosting Docker containers
- **Configuration**: 
  - AMI: Amazon Linux 2
  - Instance Type: t2.micro (free tier)
  - Docker installed for container runtime
  - IAM role for ECR access and SSM management

### 2. RDS (Relational Database Service)
- **Purpose**: MySQL database backend
- **Configuration**:
  - Engine: MySQL 8.0
  - Instance: db.t3.micro (free tier)
  - Storage: 20 GB
  - Database: mydb

### 3. ECR (Elastic Container Registry)
- **Purpose**: Docker image repository
- **Configuration**: Private registry for Nginx images

### 4. Security Groups
- **Web Security Group**: 
  - Inbound: HTTP (80), SSH (22)
  - Outbound: All traffic
- **RDS Security Group**:
  - Inbound: MySQL (3306) from EC2 only
  - Isolated from internet

### 5. IAM Roles
- **EC2 Role**: ECR read access + SSM management

## CI/CD Pipeline

### Pipeline Stages

1. **Terraform Plan** - Infrastructure planning
   - Shows what resources will be created/modified
   - Generates execution plan for review

2. **Approval Gate** - Manual review
   - Review Terraform plan output
   - Manual approval required before apply
   - Only authorized users can approve

3. **Terraform Apply** - Infrastructure deployment
   - Executes the approved plan
   - Provisions all AWS resources
   - Outputs instance ID for deployment

4. **Build** - Docker image creation
   - Builds Nginx image with "Hello World" page
   - Pushes to ECR

5. **Deploy** - Container deployment
   - Pulls image from ECR to EC2
   - Runs container on port 80

## Deployment Process

### Prerequisites
1. AWS Account with appropriate permissions
2. GitHub repository
3. Configure AWS OIDC Provider and IAM Role
4. Configure GitHub Secrets:
   - `AWS_ROLE_ARN`
   - `AWS_ACCOUNT_ID`

### Setup Steps

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd aws
   ```

2. **Configure GitHub Environment**
   - Go to Settings → Environments
   - Create "production" environment
   - Enable "Required reviewers"

3. **Deploy**
   ```bash
   git push origin main
   ```

4. **Pipeline Execution**
   - Terraform plan shows proposed changes (~1 min)
   - Manual approval required (review plan output)
   - Terraform apply executes approved plan (~5 min)
   - Docker image builds and pushes to ECR (~2 min)
   - Container deploys to EC2 (~1 min)

5. **Access Application**
   - Get public IP from GitHub Actions output
   - Visit: `http://<public-ip>`

## Security Features

- Database isolated from internet (private subnet via security group)
- EC2 only allows HTTP/SSH inbound
- IAM roles follow least privilege principle
- Manual approval gate prevents unauthorized deployments
- OIDC authentication (no long-lived credentials)
- GitHub secrets for sensitive data

## Cost Optimization

- All services use free tier eligible resources:
  - EC2: t2.micro
  - RDS: db.t3.micro
  - ECR: 500 MB free storage
- Estimated monthly cost: $0-15 (depending on usage)

## Monitoring & Management

- EC2 accessible via AWS Systems Manager (SSM)
- No SSH keys required for deployment
- CloudWatch logs available for all services
- Terraform state tracks infrastructure changes

## File Structure

```
aws/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline
├── infra/
│   ├── provider.tf             # AWS provider config
│   ├── variables.tf            # Input variables
│   ├── ec2.tf                  # EC2 instance & IAM
│   ├── rds.tf                  # RDS database
│   ├── ecr.tf                  # ECR registry
│   └── main.tf                 # Outputs
├── Dockerfile                  # Nginx container
└── README.md                   # This file
```

## Troubleshooting

### Pipeline fails at Terraform stage
- Verify AWS role ARN in GitHub secrets
- Check OIDC provider is configured correctly
- Ensure role trust policy matches your repository

### Build fails
- Ensure AWS_ACCOUNT_ID is correct
- Verify ECR repository exists

### Deploy fails
- Wait 2-3 minutes after Terraform completes for SSM agent
- Check EC2 instance has IAM role attached

### Cannot access web page
- Verify security group allows port 80
- Check EC2 instance is running
- Ensure Docker container started successfully

## Maintenance

### Update Application
- Modify Dockerfile
- Push to main branch
- Pipeline automatically rebuilds and redeploys

### Update Infrastructure
- Modify Terraform files in `infra/`
- Push to main branch
- Pipeline automatically applies changes

### Destroy Infrastructure
```bash
cd infra
terraform destroy
```

## Future Enhancements

- Add Application Load Balancer for high availability
- Implement Auto Scaling Groups
- Add CloudWatch alarms and monitoring
- Configure RDS automated backups
- Implement blue-green deployments
- Add SSL/TLS certificates
