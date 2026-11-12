# Partiusporte homologation on AWS

Dedicated ECS Fargate, PostgreSQL, ECR, ALB, ACM, Secrets Manager, and CloudWatch resources in `sa-east-1`. The application reads event data from Atlas and hands registration off to the Atlas-owned registration route. This stack does not enable production payment credentials.

The default hostname is `hml.partiusporte.com.br`. The application tasks run in public subnets with public IPs so they can reach ECR, Secrets Manager, the Atlas homologation API, and other HTTPS endpoints without a NAT Gateway. Their security group accepts inbound HTTP only from the ALB. PostgreSQL is in isolated subnets and accepts connections only from the ECS task security group.

## Before applying

- Run these commands in **Windows PowerShell** from the Partiusporte repository. Terraform state contains the generated Rails `SECRET_KEY_BASE`; keep the checkout in a user-only Windows folder and never commit or share `terraform.tfstate` or plan files.
- Use the AWS profile `atlas-homologacao-deploy` in account `414762935567` and region `sa-east-1`.
- Check that `10.44.0.0/16` does not overlap another connected VPC. Change `vpc_cidr` in `terraform.tfvars` if needed.
- The uploaded source archive contained local environment and Rails credential files. They are excluded from the container build. Do not copy `.env`, `config/master.key`, or encrypted credentials into this stack.
- The deployment profile needs permission to create the resources in this configuration. The ECS task roles are named `atlas-partiusporte-hml-*` to fit the existing deployment policy's `atlas-*` role naming boundary.
- This application snapshot uses Atlas for event publication, registration, and payment. It has no independent Mercado Pago runtime integration.

## 1. Create the base stack and certificate

Open PowerShell in the Partiusporte repository root. Set AWS credentials for this terminal session and move into the Terraform folder:

```powershell
$env:AWS_PROFILE = "atlas-homologacao-deploy"
$env:AWS_REGION = "sa-east-1"
$env:TF_VAR_expected_account_id = "414762935567"
$env:TF_VAR_aws_region = "sa-east-1"
$env:TF_VAR_app_host = "hml.partiusporte.com.br"
$env:TF_VAR_enable_application = "false"
Set-Location .\infra\terraform\homologation

terraform init
terraform plan -out=partiusporte-hml-base.tfplan
```

Review the plan. It creates the VPC, ALB, RDS database, ECR repository, certificate request, secrets, and ECS cluster, but no web or worker tasks. Apply only after reviewing:

```powershell
terraform apply partiusporte-hml-base.tfplan
terraform output certificate_validation_records
```

Add the displayed CNAME record(s) to the DNS provider for `partiusporte.com.br`. Check ACM until the certificate is `ISSUED`:

```powershell
$certificateArn = terraform output -raw certificate_arn
aws acm describe-certificate `
  --region sa-east-1 `
  --certificate-arn $certificateArn `
  --query 'Certificate.Status' `
  --output text
```

## 2. Build and push the image

Run from the repository root. Use a new tag for each image build:

```powershell
Set-Location ..\..\..
$imageTag = "homologation-20261112-01"
$registry = terraform -chdir=infra/terraform/homologation output -raw ecr_repository_url
$registryHost = $registry.Split('/')[0]
$dockerConfig = Join-Path $env:TEMP ("partiusporte-docker-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $dockerConfig | Out-Null
$previousDockerConfig = $env:DOCKER_CONFIG
$env:DOCKER_CONFIG = $dockerConfig

try {
  aws ecr get-login-password --region sa-east-1 |
    docker login --username AWS --password-stdin $registryHost
  if ($LASTEXITCODE -ne 0) { throw "ECR login failed" }

  docker build --platform linux/amd64 --tag "${registry}:$imageTag" .
  if ($LASTEXITCODE -ne 0) { throw "Docker build failed" }

  docker push "${registry}:$imageTag"
  if ($LASTEXITCODE -ne 0) { throw "Docker push failed" }
}
finally {
  docker logout $registryHost 2>$null | Out-Null
  Remove-Item -Recurse -Force $dockerConfig -ErrorAction SilentlyContinue
  if ($null -eq $previousDockerConfig) { Remove-Item Env:DOCKER_CONFIG -ErrorAction SilentlyContinue }
  else { $env:DOCKER_CONFIG = $previousDockerConfig }
}
```

## 3. Create task definitions and services with zero tasks

Return to the Terraform folder and create the services without starting them yet:

```powershell
Set-Location .\infra\terraform\homologation
$env:TF_VAR_enable_application = "true"
$env:TF_VAR_image_tag = $imageTag
$env:TF_VAR_initial_web_tasks = "0"
$env:TF_VAR_initial_worker_tasks = "0"
terraform plan -out=partiusporte-hml-app.tfplan
```

Review and apply:

```powershell
terraform apply partiusporte-hml-app.tfplan
```

## 4. Prepare the application databases

Run `db:prepare` once before starting web and worker tasks:

```powershell
$subnetIds = (terraform output -json public_subnet_ids | ConvertFrom-Json) -join ","
$appSecurityGroup = terraform output -raw application_security_group_id
$cluster = terraform output -raw ecs_cluster_name
$taskDefinition = terraform output -raw web_task_definition
$networkConfiguration = "awsvpcConfiguration={subnets=[$subnetIds],securityGroups=[$appSecurityGroup],assignPublicIp=ENABLED}"
$overrides = '{"containerOverrides":[{"name":"web","command":["./bin/rails","db:prepare"]}]}'

$taskArn = aws ecs run-task `
  --region sa-east-1 `
  --cluster $cluster `
  --task-definition $taskDefinition `
  --launch-type FARGATE `
  --network-configuration $networkConfiguration `
  --overrides $overrides `
  --query 'tasks[0].taskArn' `
  --output text
if ($LASTEXITCODE -ne 0 -or $taskArn -eq "None") { throw "Could not start the database preparation task" }

aws ecs wait tasks-stopped --region sa-east-1 --cluster $cluster --tasks $taskArn
aws ecs describe-tasks `
  --region sa-east-1 `
  --cluster $cluster `
  --tasks $taskArn `
  --query 'tasks[0].{status:lastStatus,exitCode:containers[0].exitCode,reason:stoppedReason}' `
  --output json
```

Continue only when the container exit code is `0`.

## 5. Start web and worker

Create and review a new plan that sets both task counts to one:

```powershell
$env:TF_VAR_initial_web_tasks = "1"
$env:TF_VAR_initial_worker_tasks = "1"
terraform plan -out=partiusporte-hml-start.tfplan
terraform apply partiusporte-hml-start.tfplan

$cluster = terraform output -raw ecs_cluster_name
$webService = terraform output -raw web_service_name
$workerService = terraform output -raw worker_service_name
aws ecs wait services-stable --region sa-east-1 --cluster $cluster --services $webService $workerService
```

Create a DNS CNAME from `hml.partiusporte.com.br` to `terraform output -raw application_cname_target`. Then verify:

```powershell
curl.exe -fsS -o NUL -w '/up: HTTP %{http_code}\n' https://hml.partiusporte.com.br/up
curl.exe -fsS -o NUL -w '/: HTTP %{http_code}\n' https://hml.partiusporte.com.br/
```

The catalog and registration handoff require published homologation events in Atlas. Registration and payment remain in the Atlas environment.
