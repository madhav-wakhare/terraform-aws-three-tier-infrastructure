# terraform-aws-three-tier-infrastructure

Production-grade, multi-environment AWS three-tier infrastructure managed with Terraform. Uses the **structural (live) approach** — each environment (`dev`, `staging`, `prod`) is an independent Terraform root module with its own state, variables, and lifecycle.

---

## Architecture Overview

The infrastructure implements a classic three-tier model on AWS:

- **Web tier** — Application Load Balancer (ALB) with HTTP-to-HTTPS redirect and ACM SSL termination, deployed across two public subnets.
- **Application tier** — Auto Scaling Group (ASG) with a Launch Template running Ubuntu EC2 instances in private subnets. A Bastion Host in the public subnet provides controlled SSH access.
- **Data tier** — Amazon RDS (MySQL) in isolated RDS subnets with encrypted storage, automated backups, and optional Multi-AZ for high availability.

```
Internet
    |
[ ALB ] (public subnets, port 80 redirect → 443)
    |
[ ASG / EC2 ] (private subnets)
    |
[ RDS MySQL ] (rds subnets, no public access)

[ Bastion Host ] (public subnet, SSH gateway)
```

---

## Repository Structure

```
terraform-aws-three-tier-infrastructure/
├── .gitignore
├── README.md
├── environments/
│   ├── dev/
│   │   ├── backend.tf          # S3 state: dev/terraform.tfstate
│   │   ├── main.tf             # Root module, calls all child modules
│   │   ├── secrets.tf          # Reads RDS credentials from AWS Secrets Manager
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars    # Dev-specific values (committed — no secrets)
│   ├── staging/
│   │   └── ...                 # Same structure, staging-specific values
│   └── prod/
│       └── ...                 # Same structure, production-grade values
└── modules/
    ├── vpc/                    # VPC, public/private/rds subnets, DB subnet group
    ├── gateways/               # Internet Gateway, NAT Gateway, Elastic IP
    ├── route_tables/           # Route tables and subnet associations
    ├── sg/                     # Security groups for ALB, Bastion, EC2, RDS
    ├── ec2/                    # Bastion host EC2 instance and key pairs
    ├── alb/                    # ALB, target group, HTTP and HTTPS listeners
    ├── asg/                    # Launch template, ASG, scaling policy, ALB attachment
    └── rds/                    # RDS MySQL instance
```

---

## Environment Configuration

| Setting | dev | staging | prod |
|---|---|---|---|
| Region | ap-south-1 | ap-south-1 | us-east-2 |
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| EC2 type | t2.micro | t3.small | t3.medium |
| RDS class | db.t3.micro | db.t3.small | db.t3.medium |
| Multi-AZ RDS | No | No | Yes |
| Backup retention | 7 days | 7 days | 14 days |
| ASG min/max | 1 / 2 | 1 / 3 | 2 / 6 |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate credentials
- An S3 bucket for remote state storage
- An ACM certificate in the target region for ALB HTTPS
- AWS Secrets Manager secrets for RDS credentials (see [Secrets Management](#secrets-management))

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/<your-org>/terraform-aws-three-tier-infrastructure.git
cd terraform-aws-three-tier-infrastructure
```

### 2. Create Secrets Manager entries

Before running Terraform, create the RDS credentials secret in AWS Secrets Manager for the target environment. Use the **Key/value** secret type with the following structure:

```json
{ "username": "admin", "password": "<strong-password>" }
```

| Environment | Secret name |
|---|---|
| dev | `wg/dev/rds` |
| staging | `wg/staging/rds` |
| prod | `wg/prod/rds` |

You can create a secret from the AWS CLI:

```bash
aws secretsmanager create-secret \
  --name "wg/dev/rds" \
  --region ap-south-1 \
  --secret-string '{"username":"admin","password":"<your-password>"}'
```

### 3. Review environment values

Open `environments/<env>/terraform.tfvars` and verify the values are correct for your account. Key values to check:

- `allowed_ssh_cidr` — Your trusted IP address(es) for bastion SSH access
- `acm_certificate_arn` — A valid ACM certificate ARN in the target region
- `bastion_public_keys` / `private_ec2_public_keys` — Your SSH public key contents

### 4. Deploy an environment

Navigate to the target environment directory and run the standard Terraform workflow:

```bash
cd environments/dev

terraform init
terraform plan
terraform apply
```

Repeat for `staging` and `prod` as needed. Each environment is fully independent — running `apply` in one directory has no effect on the others.

---

## Remote State

State is stored in Amazon S3 with native file locking (`use_lockfile = true`). Each environment writes to a separate key:

| Environment | S3 key |
|---|---|
| dev | `dev/terraform.tfstate` |
| staging | `staging/terraform.tfstate` |
| prod | `prod/terraform.tfstate` |

The S3 bucket name is configured in `environments/<env>/backend.tf`. Update it to match your own bucket before running `terraform init`.

---

## Secrets Management

RDS credentials (`username` and `password`) are **not stored in any `.tfvars` file or source code**. They are fetched at plan/apply time from AWS Secrets Manager via a `data` source in `secrets.tf`.

The `secrets.tf` file handles two secret formats gracefully:

- **JSON object** (recommended): `{ "username": "admin", "password": "..." }` — both values extracted from keys.
- **Plain string** (fallback): The raw string is used as the password; `username` defaults to `admin`.

The Terraform caller must have the following IAM permissions on the relevant secret ARN:

```json
{
  "Effect": "Allow",
  "Action": [
    "secretsmanager:GetSecretValue",
    "secretsmanager:DescribeSecret"
  ],
  "Resource": "arn:aws:secretsmanager:<region>:<account-id>:secret:wg/<env>/rds*"
}
```

---

## Security Notes

- RDS instances are not publicly accessible and are placed in dedicated isolated subnets.
- All RDS storage is encrypted at rest.
- Private EC2 instances are only accessible via the Bastion Host.
- ALB enforces HTTPS via a permanent HTTP 301 redirect.
- IMDSv2 is required on all ASG instances (`http_tokens = "required"`).
- ALB deletion protection is configurable per environment (disabled in dev, recommended enabled in prod).

---

## Modules

Each module under `modules/` is a standalone, reusable Terraform child module. Modules accept an `environment` string variable used for resource naming and tagging. They have no knowledge of the environment structure — all wiring is done in the environment's `main.tf`.

| Module | Key resources |
|---|---|
| `vpc` | `aws_vpc`, `aws_subnet` (x6), `aws_db_subnet_group` |
| `gateways` | `aws_internet_gateway`, `aws_nat_gateway`, `aws_eip` |
| `route_tables` | `aws_route_table`, `aws_route_table_association` |
| `sg` | Security groups and rules for ALB, Bastion, EC2, RDS |
| `ec2` | Bastion `aws_instance`, `aws_key_pair` resources |
| `alb` | `aws_lb`, `aws_lb_target_group`, `aws_lb_listener` (x2) |
| `asg` | `aws_launch_template`, `aws_autoscaling_group`, `aws_autoscaling_policy` |
| `rds` | `aws_db_instance` |

---

## Outputs

After a successful `apply`, each environment exposes:

| Output | Description |
|---|---|
| `vpc_id` | ID of the environment VPC |
| `alb_dns_name` | DNS name of the Application Load Balancer |

---

## Destroying Infrastructure

```bash
cd environments/dev
terraform destroy
```

> Note: The RDS instance is configured with `skip_final_snapshot = false`, meaning a final snapshot is created before deletion. In production, review this carefully before running `destroy`.

---

## Contributing

1. Make changes inside the appropriate `environments/<env>/` or `modules/<module>/` directory.
2. Run `terraform fmt -recursive` to normalise formatting.
3. Run `terraform validate` from the affected environment directory before opening a pull request.
4. Never commit secrets, state files, or `.terraform/` directories — the `.gitignore` enforces this.
