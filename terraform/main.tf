provider "aws" {
  region = "us-east-1"
}

# ✅ ECR Repo
resource "aws_ecr_repository" "runner" {
  name = "devops-runner"

  image_tag_mutability = "MUTABLE"
}

# ✅ ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "devops-cluster"
}

# ✅ IAM Role for ECS Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRoleRunner"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ✅ Attach AWS Managed Policy
resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ✅ ECS Task Definition (Runner)
resource "aws_ecs_task_definition" "runner" {
  family                   = "github-runner"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn  # ✅ important

  container_definitions = jsonencode([
    {
      name  = "runner"
      image = "${aws_ecr_repository.runner.repository_url}:latest"

      essential = true

      environment = [
        {
          name  = "REPO_URL"
          value = "https://github.com/rupamkabasiVHA/devops-sample-app"
        }
      ]
    }
  ])
}

# ✅ Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow HTTP"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ ECS Service
resource "aws_ecs_service" "service" {
  name            = "github-runner-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.runner.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-046c95f35b512509f", "subnet-067bf3bae8ad9ab7c"]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}