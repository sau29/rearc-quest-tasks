/*
Code in this file does following:
1. SG for EC2 with ingress policy for all traffic from ALB's SG-ID
2. SG for EC2 with egress policy destined to SG-ID of server's SG policy.
3. Both Ingress and Egress security group rule created from/destined to SG-ID of ALB's SG policy, to avoid cyclic dependency.

TODO:
1. More granularity is required.
2. Also in rule, confirm that policy is added properly, security and source security group id.
3. Have Name and Tags update with variable string.
*/

resource "aws_security_group" "rearc-quest-tasks-trfm-sg-ec2" {
  depends_on = [
    aws_vpc.rearc-quest-tasks-trfm-vpc
  ]

  name        = "rearc-quest-tasks-trfm-sg-ec2"
  description = "SG for EC2 Server Instance"
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
  # # Error: Cycle: aws_security_group.rearc-quest-tasks-trfm-sg-alb, aws_security_group.rearc-quest-tasks-trfm-sg-ec2
  # ingress {
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "Egress SG Rule allowing all traffic - Wild Entry - DeleteIt"
  #   from_port   = 0
  #   protocol    = "-1"
  #   to_port     = 0
  # # security_groups = [aws_security_group.rearc-quest-tasks-trfm-sg-alb.id]
  # }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress SG Rule allowing all traffic - Wild Entry - DeleteIt"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-sg-ec2"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}

resource "aws_security_group_rule" "rearc-quest-tasks-trfm-sg-ec2-egr-addon" {
  security_group_id        = aws_security_group.rearc-quest-tasks-trfm-sg-alb.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  type                     = "egress"
  source_security_group_id = aws_security_group.rearc-quest-tasks-trfm-sg-ec2.id
}
resource "aws_security_group_rule" "rearc-quest-tasks-trfm-sg-ec2-ingr-addon" {
  security_group_id        = aws_security_group.rearc-quest-tasks-trfm-sg-alb.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  type                     = "ingress"
  source_security_group_id = aws_security_group.rearc-quest-tasks-trfm-sg-ec2.id
}

output "aws_security_group_ec2id_output" {
  description = "SG ID for EC2 Server"
  value       = aws_security_group.rearc-quest-tasks-trfm-sg-ec2.id
}