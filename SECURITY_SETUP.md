# Security Improvements Setup Guide

## Improvements Implemented

✅ **1. HTTPS/SSL Certificate** - Application Load Balancer with SSL support
✅ **2. Restricted SSH Access** - SSH limited to specific IP (configurable)
✅ **3. AWS Secrets Manager** - RDS password stored securely
✅ **4. Multi-AZ RDS** - High availability database deployment

## Setup Instructions

### 1. Set Your IP for SSH Access

Get your current IP:
```bash
curl ifconfig.me
```

Update `variables.tf` or set via environment:
```bash
export TF_VAR_allowed_ssh_cidr="YOUR_IP/32"
```

### 2. Set Secure Database Password

```bash
export TF_VAR_db_password="YourSecurePassword123!"
```

Or add to GitHub Secrets:
- `TF_VAR_db_password`

### 3. (Optional) Configure SSL Certificate

If you have a domain:
```bash
export TF_VAR_domain_name="yourdomain.com"
```

Then add DNS validation records shown in Terraform output.

### 4. Deploy

```bash
cd infra
terraform init
terraform apply
```

## What Changed

### Network Architecture
```
Internet
   ↓
Application Load Balancer (HTTPS/HTTP)
   ↓
EC2 in Public Subnet (restricted SSH)
   ↓
RDS Multi-AZ in Private Subnets
```

### Security Improvements

**Before:**
- Direct EC2 access on HTTP
- SSH open to world (0.0.0.0/0)
- Password hardcoded
- Single-AZ database

**After:**
- ALB with HTTPS redirect
- SSH restricted to your IP
- Password in Secrets Manager
- Multi-AZ database (99.95% SLA)

### Access URLs

**Without Domain:**
- HTTP: `http://<alb-dns-name>` (redirects to HTTPS)
- HTTPS: Not available (need domain)

**With Domain:**
- HTTP: `http://yourdomain.com` (redirects to HTTPS)
- HTTPS: `https://yourdomain.com` ✅

## Cost Impact

| Service | Before | After | Additional Cost |
|---------|--------|-------|-----------------|
| EC2 | $0 (free tier) | $0 (free tier) | $0 |
| RDS | $0 (free tier) | $0 (free tier) | $0 |
| ALB | N/A | $16/month | +$16 |
| Multi-AZ RDS | N/A | $15/month | +$15 |
| Secrets Manager | N/A | $0.40/month | +$0.40 |
| **Total** | **$0** | **~$31/month** | **+$31** |

Note: Free tier covers first 750 hours/month for EC2 and RDS

## Verification

### 1. Check ALB is Running
```bash
terraform output alb_dns_name
```

### 2. Test HTTP Redirect
```bash
curl -I http://<alb-dns-name>
# Should return 301 redirect to HTTPS
```

### 3. Verify SSH Restriction
```bash
# From your IP - should work
ssh ec2-user@<ec2-ip>

# From other IP - should timeout
```

### 4. Check Multi-AZ RDS
AWS Console → RDS → Your database → Configuration
- Multi-AZ: Yes ✅

### 5. Verify Secrets Manager
```bash
aws secretsmanager get-secret-value --secret-id rds-db-password
```

## Troubleshooting

### Can't SSH to EC2
- Verify your IP: `curl ifconfig.me`
- Update `allowed_ssh_cidr` variable
- Re-run `terraform apply`

### ALB health checks failing
- Wait 2-3 minutes for container to start
- Check EC2 security group allows traffic from ALB
- Verify Docker container is running: `docker ps`

### SSL certificate pending
- Add DNS validation records from ACM console
- Wait 5-30 minutes for validation
- Certificate must be validated before HTTPS works

### Multi-AZ deployment slow
- Multi-AZ takes 10-15 minutes to provision
- Creates standby in different availability zone
- Normal behavior

## Rollback

To revert to previous setup:
```bash
git checkout HEAD~1 infra/
terraform apply
```

## Next Steps

1. ✅ Add domain to Route 53
2. ✅ Validate SSL certificate
3. ✅ Update DNS to point to ALB
4. ✅ Test HTTPS access
5. ✅ Remove HTTP listener (force HTTPS only)
