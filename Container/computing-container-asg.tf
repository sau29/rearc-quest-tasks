/*
Code in this file does following:
1. Creates Launch Configuration, with aws_ami which is ecs-optimized ami, along with UserData and enabled public ip, which is meeded to connect through ssh console.
2. Creates AutoScaling group, with Desired/MIN/MAX count and associated with Application Load Balancer
3. data type to get latest ECS-Optimized AMI.
4. Userdata with HTTP enabled to pass health check in LB
5. Userdata with ecs config to have this instance part of cluster.

TODO:
1. Name and Tags in variable format.
2. Variable for Desired, Min and Max count.
3. With http enabled, health check is succeeding but seeing issue launching containers in this instance:
Status reason	CannotStartContainerError: Error response from daemon: driver failed programming external connectivity on 
endpoint ecs-rearc-quest-tasks-trfm-ecs-17-rearc-quest-tasks-trfm-tdef-contnr-9edaed8b8fa48e8b3500 
(600f547283c2d4054152be4874eb3de399303c94a1655a8a5

*/

resource "aws_launch_configuration" "rearc-quest-tasks-trfm-ecs-lnchcfg" {
  # image_id             = "ami-094d4d00fd7462815"
  image_id                    = data.aws_ami.ecs_ami.id
  iam_instance_profile        = aws_iam_instance_profile.rearc-quest-tasks-trfm-tdef-instprfl.name
  security_groups             = [aws_security_group.rearc-quest-tasks-trfm-sg-ecs.id]
  user_data                   = <<EOF
      #!/bin/bash 
      echo "ECS_CLUSTER=rearc-quest-tasks-trfm-cluster" > /etc/ecs/ecs.config
      # sudo yum update -y
      # sudo yum install -y httpd
      # sudo systemctl enable httpd
      # sudo service httpd start  
      # echo "<h1>Welcome !! AWS Infra created using Terraform in us-east-1 Region</h1>" | sudo tee /var/www/html/index.html
    EOF
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
}

resource "aws_autoscaling_group" "rearc-quest-tasks-trfm-ecs-asg" {
  name                 = "rearc-quest-tasks-trfm-ecs-asg"
  vpc_zone_identifier  = [aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id]
  launch_configuration = aws_launch_configuration.rearc-quest-tasks-trfm-ecs-lnchcfg.name

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"

  #code to have ASG part of ALB
  target_group_arns = ["${aws_lb_target_group.rearc-quest-tasks-trfm-ecs-targetgroup.arn}"]
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}