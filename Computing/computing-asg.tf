/*
Code in this file does following:
1. Data type to get AMIID for instance
2. Launch Configuration
3. AutoScaling group, with MIN, MAX and DESIRED count as variable.

TODO:
1. In the output section display IPs, IDs of launched instances.
2. To add AWS Managed policy in Instance profile, to connect to instance.
3. Granualrity in Security policy.
4. Have Name and Tags update with variable string.
*/

# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_configuration" "rearc-quest-tasks-trfm-ec2-lnchcfg" {
  image_id                    = data.aws_ami.amzlinux.id
  iam_instance_profile        = aws_iam_instance_profile.rearc-quest-tasks-trfm-ec2-instprfl.name
  security_groups             = [aws_security_group.rearc-quest-tasks-trfm-sg-ec2.id]
  user_data                   = file("apache-install.sh")
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
}

resource "aws_autoscaling_group" "rearc-quest-tasks-trfm-ec2-asg" {
  name                 = "rearc-quest-tasks-trfm-ec2-asg"
  vpc_zone_identifier  = [aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id]
  launch_configuration = aws_launch_configuration.rearc-quest-tasks-trfm-ec2-lnchcfg.name

  desired_capacity = var.rearc-quest-tasks-trfm-ec2-asg-desired_capacity
  min_size         = var.rearc-quest-tasks-trfm-ec2-asg-min_size
  max_size         = var.rearc-quest-tasks-trfm-ec2-asg-max_size

  health_check_grace_period = 300
  health_check_type         = "EC2"

  #code to have ASG part of ALB
  target_group_arns = ["${aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup.arn}"]
}

#TODO:
#Output - List IPs, IDs of launched instances through ASG;