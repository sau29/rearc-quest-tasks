/*
Code in this file does following:
1. Create LB Target group, reaching to instances on port 80
2. Create HTTP Listener, listening on port 80 from internet, forwarding traffic to target group
3. Create HTTP Listener, listening on port 443 from internet, forwarding traffic to target group - TODO
4. Create Application Load Balancer

TODO:
1. Listener for port 443, support of HTTPS traffic. In absence of domain name could not create certificate. Need to explore.
2. Have Name and Tags update with variable string.
*/


#Target Group - aws_lb_target_group
resource "aws_lb_target_group" "rearc-quest-tasks-trfm-targetgroup" {
  name     = "rearc-quest-tasks-trfm-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.rearc-quest-tasks-trfm-vpc.id
}


#Listener - aws_lb_listener
resource "aws_lb_listener" "rearc-quest-tasks-trfm-listener-http" {
  depends_on = [
    aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup
  ]

  load_balancer_arn = aws_alb.rearc-quest-tasks-trfm-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup.arn
  }
}

#TLS certificate with Load Balancer - aws_lb_listerner_certificate
# resource "aws_lb_listener" "rearc-quest-tasks-trfm-listener-https" {
#   load_balancer_arn = aws_lb.rearc-quest-tasks-trfm-alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = ""

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup.arn
#   }
# }

#Load Balancer - aws_lb
resource "aws_alb" "rearc-quest-tasks-trfm-alb" {
  name               = "rearc-quest-tasks-trfm-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rearc-quest-tasks-trfm-sg-alb.id]

  subnets = [aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id, aws_subnet.rearc-quest-tasks-trfm-subnet2-pub.id]

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-alb"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}