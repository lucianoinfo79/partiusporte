data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "partiusporte-hml"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Project     = "partiusporte"
    Environment = "homologation"
    ManagedBy   = "Terraform"
  }

  atlas_host = trimsuffix(trimprefix(var.atlas_public_origin, "https://"), "/")

  environment = [
    { name = "RAILS_ENV", value = "production" },
    { name = "RAILS_LOG_LEVEL", value = "info" },
    { name = "RAILS_MAX_THREADS", value = "5" },
    { name = "HTTP_PORT", value = "8080" },
    { name = "TARGET_PORT", value = "3000" },
    { name = "PARTILPROVA_PUBLIC_HOST", value = var.app_host },
    { name = "PARTILPROVA_PUBLIC_BASE_URL", value = "https://${var.app_host}" },
    { name = "PARTILPROVA_PUBLIC_CACHE_ENABLED", value = "true" },
    { name = "PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH", value = "false" },
    { name = "PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS", value = "false" },
    { name = "PARTILPROVA_ATLAS_PUBLIC_ORIGIN", value = var.atlas_public_origin },
    { name = "PARTILPROVA_REGISTRATION_ALLOWED_HOSTS", value = local.atlas_host },
    { name = "PARTILPROVA_PARTICIPANT_ALLOWED_HOSTS", value = local.atlas_host },
    { name = "ATLAS_PUBLIC_API_BASE_URL", value = var.atlas_public_api_base_url },
    { name = "ATLAS_PUBLIC_API_OPEN_TIMEOUT", value = "2" },
    { name = "ATLAS_PUBLIC_API_READ_TIMEOUT", value = "10" },
    { name = "DATABASE_HOST", value = aws_db_instance.partiusporte.address },
    { name = "DATABASE_PORT", value = tostring(aws_db_instance.partiusporte.port) },
    { name = "DATABASE_USERNAME", value = "app" },
    { name = "AWS_REGION", value = var.aws_region }
  ]

  task_secrets = [
    {
      name      = "APP_DATABASE_PASSWORD"
      valueFrom = "${aws_db_instance.partiusporte.master_user_secret[0].secret_arn}:password::"
    },
    {
      name      = "SECRET_KEY_BASE"
      valueFrom = aws_secretsmanager_secret.secret_key_base.arn
    }
  ]

  task_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.app.name
      awslogs-region        = var.aws_region
      awslogs-stream-prefix = "partiusporte"
    }
  }
}

resource "terraform_data" "account_guard" {
  input = data.aws_caller_identity.current.account_id

  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == var.expected_account_id
      error_message = "The active AWS account does not match expected_account_id."
    }
  }
}

resource "aws_vpc" "partiusporte" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${local.name}-vpc" })
}

resource "aws_internet_gateway" "partiusporte" {
  vpc_id = aws_vpc.partiusporte.id
  tags   = merge(local.tags, { Name = "${local.name}-igw" })
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.partiusporte.id
  availability_zone       = local.azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = false
  tags                    = merge(local.tags, { Name = "${local.name}-public-${count.index + 1}" })
}

resource "aws_subnet" "database" {
  count                   = 2
  vpc_id                  = aws_vpc.partiusporte.id
  availability_zone       = local.azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  map_public_ip_on_launch = false
  tags                    = merge(local.tags, { Name = "${local.name}-database-${count.index + 1}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.partiusporte.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.partiusporte.id
  }
  tags = merge(local.tags, { Name = "${local.name}-public" })
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.partiusporte.id
  tags   = merge(local.tags, { Name = "${local.name}-database-isolated" })
}

resource "aws_route_table_association" "database" {
  count          = 2
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "aws_security_group" "load_balancer" {
  name        = "${local.name}-alb"
  description = "Public HTTPS ingress for Partiusporte homologation."
  vpc_id      = aws_vpc.partiusporte.id
  ingress {
    description = "HTTP redirect"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS application traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${local.name}-alb" })
}

resource "aws_security_group" "application" {
  name        = "${local.name}-application"
  description = "ECS tasks accept HTTP only from the Partiusporte load balancer."
  vpc_id      = aws_vpc.partiusporte.id
  ingress {
    description     = "HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${local.name}-application" })
}

resource "aws_security_group" "database" {
  name        = "${local.name}-database"
  description = "PostgreSQL accepts connections only from Partiusporte ECS tasks."
  vpc_id      = aws_vpc.partiusporte.id
  ingress {
    description     = "PostgreSQL from application tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${local.name}-database" })
}

resource "aws_db_subnet_group" "partiusporte" {
  name       = local.name
  subnet_ids = aws_subnet.database[*].id
  tags       = merge(local.tags, { Name = local.name })
}

resource "aws_db_instance" "partiusporte" {
  identifier                  = local.name
  engine                      = "postgres"
  instance_class              = var.db_instance_class
  allocated_storage           = var.db_allocated_storage_gb
  max_allocated_storage       = 100
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = "app_production"
  username                    = "app"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.partiusporte.name
  vpc_security_group_ids      = [aws_security_group.database.id]
  publicly_accessible         = false
  multi_az                    = false
  backup_retention_period     = 1
  deletion_protection         = var.db_deletion_protection
  skip_final_snapshot         = true
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  tags                        = merge(local.tags, { Name = local.name })
}

resource "aws_secretsmanager_secret" "secret_key_base" {
  name                    = "${local.name}/secret-key-base"
  description             = "Rails SECRET_KEY_BASE for Partiusporte homologation."
  recovery_window_in_days = 7
  tags                    = local.tags
}

resource "random_password" "secret_key_base" {
  length  = 64
  special = true
}

resource "aws_secretsmanager_secret_version" "secret_key_base" {
  secret_id     = aws_secretsmanager_secret.secret_key_base.id
  secret_string = random_password.secret_key_base.result
}

resource "aws_ecr_repository" "app" {
  name                 = "partiusporte/hml"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
  tags = merge(local.tags, { Name = "${local.name}-ecr" })
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the most recent 30 homologation images."
      selection = {
        tagStatus   = "tagged"
        tagPrefixList = ["homologation-"]
        countType   = "imageCountMoreThan"
        countNumber = 30
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

resource "aws_ecs_cluster" "app" {
  name = local.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = local.tags
}

resource "aws_iam_role" "execution" {
  name = "atlas-partiusporte-hml-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

data "aws_partition" "current" {}

resource "aws_iam_role_policy" "execution_runtime" {
  name = "partiusporte-hml-runtime-access"
  role = aws_iam_role.execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AuthenticateToECR"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "PullPartiusporteImage"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = aws_ecr_repository.app.arn
      },
      {
        Sid      = "WriteApplicationLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.app.arn}:*"
      },
      {
        Sid      = "ReadRuntimeSecrets"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [aws_db_instance.partiusporte.master_user_secret[0].secret_arn, aws_secretsmanager_secret.secret_key_base.arn]
      }
    ]
  })
}

resource "aws_iam_role" "task" {
  name = "atlas-partiusporte-hml-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

resource "aws_lb" "app" {
  name                       = "partiusporte-hml"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer.id]
  subnets                    = aws_subnet.public[*].id
  enable_deletion_protection = false
  tags                       = local.tags
}

resource "aws_lb_target_group" "web" {
  name        = "partiusporte-hml-web"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.partiusporte.id
  health_check {
    enabled             = true
    path                = "/up"
    matcher             = "200"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  tags = local.tags
}

resource "aws_acm_certificate" "app" {
  domain_name       = var.app_host
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
  tags = local.tags
}

resource "aws_lb_listener" "https" {
  count             = var.enable_application ? 1 : 0
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.app.arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_listener" "http" {
  count             = var.enable_application ? 1 : 0
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_ecs_task_definition" "web" {
  count                    = var.enable_application ? 1 : 0
  family                   = "${local.name}-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions = jsonencode([{
    name             = "web"
    image            = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
    essential        = true
    portMappings     = [{ containerPort = 8080, hostPort = 8080, protocol = "tcp" }]
    environment      = local.environment
    secrets          = local.task_secrets
    logConfiguration = local.task_log_configuration
  }])
  tags = local.tags
}

resource "aws_ecs_task_definition" "worker" {
  count                    = var.enable_application ? 1 : 0
  family                   = "${local.name}-worker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions = jsonencode([{
    name             = "worker"
    image            = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
    essential        = true
    command          = ["bin/jobs"]
    environment      = local.environment
    secrets          = local.task_secrets
    logConfiguration = local.task_log_configuration
  }])
  tags = local.tags
}

resource "aws_ecs_service" "web" {
  count           = var.enable_application ? 1 : 0
  name            = "${local.name}-web"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.web[0].arn
  desired_count   = var.initial_web_tasks
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent        = 100
  health_check_grace_period_seconds = 90
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.application.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "web"
    container_port   = 8080
  }
  depends_on = [aws_lb_listener.https]
  tags       = local.tags
}

resource "aws_ecs_service" "worker" {
  count            = var.enable_application ? 1 : 0
  name             = "${local.name}-worker"
  cluster          = aws_ecs_cluster.app.id
  task_definition  = aws_ecs_task_definition.worker[0].arn
  desired_count    = var.initial_worker_tasks
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent        = 100
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.application.id]
    assign_public_ip = true
  }
  tags = local.tags
}
