resource "aws_ecs_cluster" "main" {
  name = "Sahil-Demo-Cluster"
}

data "template_file" "myapp" {
  template = file("./templates/ecs/myapp.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

resource "aws_ecs_task_definition" "app" {
  family = "Sahil-Demo-TaskDefinition"
  # execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = "arn:aws:iam::997817439961:role/sahil-smit-ecs-role"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.myapp.rendered
}

resource "aws_ecs_service" "main" {
  name            = "Sahil-Demo-Service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "sahil-demo"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end]
}

resource "aws_ecs_task_set" "example" {
  service         = aws_ecs_service.main.id
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "sahil-demo"
    container_port   = var.app_port
  }
}