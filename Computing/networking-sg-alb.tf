/*
Code in this file does following:
1. SG for ALB with ingress policy on port 22, 80 and 443 from internet
2. SG for ALB with egress policy destined to SG-ID of server's SG policy.
3. Egress security group rule created destined to SG-ID of server's SG policy, to avoid cyclic dependency.

TODO:
1. More granularity in SG is required.
2. Also in rule, confirm that policy is added properly, security and source security group id.
3. Have Name and Tags update with variable string.
*/

# Configure Security Group for ALB
resource "aws_security_group" "rearc-quest-tasks-trfm-sg-alb" {
  depends_on = [
    aws_vpc.rearc-quest-tasks-trfm-vpc
  ]

  name        = "rearc-quest-tasks-trfm-sg-alb"
  description = "SG for ALB"
  vpc_id      = aws_vpc.rearc-quest-tasks-trfm-vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG Rule for SSH Traffic"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG Rule for HTTP Traffic"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG Rule for HTTPs Traffic"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ingress SG Rule allowing all traffic - Wild Entry - DeleteIt"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress SG Rule forwarding all traffic to EC2 SG"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-sg-alb"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}

resource "aws_security_group_rule" "rearc-quest-tasks-trfm-sg-alb-egr-addon" {
  security_group_id        = aws_security_group.rearc-quest-tasks-trfm-sg-ec2.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  type                     = "egress"
  source_security_group_id = aws_security_group.rearc-quest-tasks-trfm-sg-alb.id
}



#respective output of created SG
output "aws_security_group_albid_output" {
  description = "SG ID for ALB"
  value       = aws_security_group.rearc-quest-tasks-trfm-sg-alb.id
}
