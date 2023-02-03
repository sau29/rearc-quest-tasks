/*
Code in this file does following:
1. Creates Application Load Balancer.
2. Creates Target Group with port 80 and HTTP protocol to connect to EC2 instance, where containers will be running.
3. Creates Listener which will be listening on HTTP:80 from internet which will get forward to Target group.

TODO:
1. Name and Tags in variable format.
*/

#Load Balancer - aws_lb
resource "aws_alb" "rearc-quest-tasks-trfm-ecs-alb" {
  name               = "rearc-quest-tasks-trfm-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rearc-quest-tasks-trfm-sg-ecs.id]

  subnets = [aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id, aws_subnet.rearc-quest-tasks-trfm-subnet2-pub.id]

  #   enable_deletion_protection = true

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-alb"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}

#Target Group - aws_lb_target_group
resource "aws_lb_target_group" "rearc-quest-tasks-trfm-ecs-targetgroup" {
  name     = "rearc-quest-tasks-trfm-ecs-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.rearc-quest-tasks-trfm-vpc.id
}

#Listener - aws_lb_listener
resource "aws_lb_listener" "rearc-quest-tasks-trfm-listener-ecs-http" {
  depends_on = [
    aws_lb_target_group.rearc-quest-tasks-trfm-ecs-targetgroup
  ]

  load_balancer_arn = aws_alb.rearc-quest-tasks-trfm-ecs-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rearc-quest-tasks-trfm-ecs-targetgroup.arn
  }
}