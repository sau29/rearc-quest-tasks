/*
Code in this file does following:
1. Creates Task Definition, with UserData and Docker image - httpd:2.4
2. Creates ECS/EC2 cluster
3. Creates ECS Service with 1 task deplyment.

TODO:
1. Name and Tags in variable format.
2. Variable for Task count in services.
3. EC2 instance launched with ECS Optimized AMI, which has limitation. It doesn;t allow ssh connection.
4. In absence of AWS managed policy in Instance profile, unable to connect though system manager.
5. Unable to debug, as could not get access to ec2 console.
6. Launched EC2 instance is not part of ECS cluster.

WORKAROUND:
1. Instance laucnhed(not through AutoScal) but with the same AMI, with httpd server starting in userdata, ALB's health check is healthy.
2. IAM instance role needs to update policy manually AmazonEC2ContainerServiceforEC2Role, than instance gets added to the cluster.
3. Still container is not running in the launched instance. Though it has worked once, but something went wrong in between.... :-(
4. Not using ASG but launching instance through seperate resource, for the same AMI id, with same policy - uanble to connect to instance,
hence could not debug why it is not part of cluster.
*/

resource "aws_ecs_task_definition" "rearc-quest-tasks-trfm-tdef" {
  family       = "rearc-quest-tasks-trfm-ecs"
  network_mode = "bridge"
  # requires_compatibilities = ["EC2"]
  # cpu                      = 1024
  # memory                   = 2048
  container_definitions = <<DEFINITION
[
      {
        "entryPoint": [
          "sh",
          "-c"
        ],
        "portMappings": [
          {
            "hostPort": 80,
            "protocol": "tcp",
            "containerPort": 80
          }
        ],
        "command": [
          "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Saurabh's application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
        ],
        "cpu": 10,
        "secrets": null,
        "memory": 300,
        "image": "httpd:2.4",
        "essential": true,
        "name": "rearc-quest-tasks-trfm-tdef-contnr"
      }
]
DEFINITION
}

resource "aws_ecs_cluster" "rearc-quest-tasks-trfm-cluster" {
  name = "rearc-quest-tasks-trfm-cluster"
}

#Issue: service rearc-quest-tasks-trfm-tdef-service was unable to place a task 
#because no container instance met all of its requirements. Reason: No Container 
#Instances were found in your cluster. 
resource "aws_ecs_service" "rearc-quest-tasks-trfm-tdef-service" {
  name                = "rearc-quest-tasks-trfm-tdef-service"
  cluster             = aws_ecs_cluster.rearc-quest-tasks-trfm-cluster.id
  task_definition     = aws_ecs_task_definition.rearc-quest-tasks-trfm-tdef.arn
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  launch_type         = "EC2"
}