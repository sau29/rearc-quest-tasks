# About Computing Solution:
This solution deploys following:
Networking Component:
1. It deploys VPC, 2 Public Subnets, Internet Gateways, Route Table
2. Security Groups for Application Load Balancer and Server Instances

# Computing Compnent:
1. It creates Application Load Balancer
2. Listener, listening on port 80 for HTTP traffic
3. Target group, connected to Server Instance
4. AutoScaling and Launch Configuration for server instance
5. IAM role and policies

# About Container Solution:
Networking Component:
1. It deploys VPC, 2 Public Subnets, Internet Gateways, Route Table
2. Security Groups for Application Load Balancer and Server Instances

# Computing and Container Compnent:
1. It creates Application Load Balancer
2. Listener, listening on port 80 for HTTP traffic
3. Target group, connected to Server Instance
4. AutoScaling and Launch Configuration to launch EC2 instance for container
5. IAM role and policies
6. Task Definition, Service and ECS Cluster

# Status of the Tasks:
1. If you know how to use git, start a git repository (local-only is acceptable) and commit all of your work to it.
STATUS: DONE

2. Deploy the app in any public cloud and navigate to the index page. Use Linux 64-bit x86/64 as your OS (Amazon Linux preferred in AWS, Similar Linux flavor preferred in GCP and Azure)
STATUS: DONE in AWS

3. Deploy the app in a Docker container. Use node as the base image. Version node:10 or later should work.
STATUS: DONE

4. Inject an environment variable (SECRET_WORD) in the Docker container. The value of SECRET_WORD should be the secret word discovered on the index page of the application.
STATUS: NOT DONE

5. Deploy a load balancer in front of the app.
STATUS: DONE

6. Use Infrastructure as Code (IaC) to "codify" your deployment. Terraform is ideal, but use whatever you know, e.g. CloudFormation, CDK, Deployment Manager, etc.
STATUS: DONE

7. Add TLS (https). You may use locally-generated certs.
STATUS: NOT DONE


# Submissions:
1. Your work assets, as one or both of the following:
Github link

2. Proof of completion, as one or both of the following:
Snapshot of accessing index file in computing environment, is uploaded in Github.

3. An answer to the prompt: "Given more time, I would improve..."
a. Explore more on the limitations of Terraform(mentioned in issues section below)
b. Implemented HTTPS in listener, in absence of domain name could not do it.
c. Tested by implementing granular security rules in Security group
d. Debugged why tasks are failing in container. It seems it is memory issue. At one instance I could access container through it's public IP when it ran successfully, 
but somewhere I messed up and now task is not running in container.
e. Assigned values in parameters through variables.
f. Assign name of the resource and Tag names, using variables.
g. Could have explore how to add AWS Managed Policy in IAM role through Terraform(known issue in Terraform). As workaround I had to do it manually.

# Issues experienced:
Issue-1: Attaching Instance Id in Load Balancer's Target Group.
While launching multiple instance, can't attach them into the target group using "target_id". Since this attribute takes only string and not list.

│ Error: Incorrect attribute value type
│
│   on computing-alb.tf line 44, in resource "aws_lb_target_group_attachment" "rearc-quest-tasks-trfm-targetgroup-atchmt":
│   44:   target_id        = ["aws_instance.rearc-quest-tasks-trfm-instance.id", "aws_instance.rearc-quest-tasks-trfm-instance2.id"]
│
│ Inappropriate value for attribute "target_id": string required.

Solution: 
1. used "COUNT" metadata while launching instances and also in "aws_lb_target_group_attachment" with value of target_iad as 
target_id        = aws_instance.rearc-quest-tasks-trfm-instance-count[count.index].id
2. Use AutoScaling and add below code in resource "aws_autoscaling_group"
  target_group_arns = ["${aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup.arn}"]


Issue-2: AutoScaling group configured with Desired/MIN and MAX as 0 through variable, yet I could see Instance getting launched. Issue is not seen when I hardcode 
the values to 0.

Issue-3: AMI Id in Launch Configuration
In the launch configuration, if AMI-ID is configured, terraform throws strange error, quite difficult to find the reason, eg:
image_id = "ami-094d4d00fd7462815"
Error: creating Auto Scaling Launch Configuration (terraform-20230201093315359300000001): couldn't find resource
Use "aws_ami" data type to find the latest ami and use that varible, it works...
image_id = data.aws_ami.amzlinux.id

Solution:
Use aws_ami data resource to get latest AMI ID.

Issue-4: Unable to edit Launch Configuration once it is deployed
Once Launch configuration is deployed with Auto Scaling Group, we cannot UPDATE any parameter in Launch Configuration. It throws error, also note I AM NOT 
DELETING but just UPDATING...
Error: deleting Auto Scaling Launch Configuration (terraform-20230201095140131800000001): ResourceInUse: Cannot delete launch configuration 
terraform-20230201095140131800000001 because it is attached to AutoScalingGroup rearc-quest-tasks-trfm-ecs-asg
 │       status code: 400, request id: fb166d17-87c2-4ad6-9739-6c05e1ec8e5b

Solution:
To delete the AutoScaling group and Launch configuration and do "terraform apply" again, with changes after doing "terraform plan".

Issue-5: ECS Optimized AMI
ECS Optimized AMI does not have ssm-agent installed, hence could not connect to EC2 instance to debug.

Issue-6: Unable to add AWS Managed Policy in IAM Role through Terraform
1. Terraform throws STRANGE error while adding AWS Managed policy to IAM Role through "aws_iam_role_policy_attachment", quite difficult to understand and debug.... 
well, this is known issue.
│ Error: Error attaching policy arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role to IAM Role 
aws_iam_role.rearc-quest-tasks-trfm-tdef-iamrole.name: NoSuchEntity: The role with name aws_iam_role.rearc-quest-tasks-trfm-tdef-iamrole.name cannot be found.
│       status code: 404, request id: 54b8e510-a510-46c9-a910-16b624823b1e

# Learnings:
1. Displaying of Instances ID when instances are launched not through AutoScaling, but using COUNT Meta-Argument from Terraform:
When count number of instances getting launched, than to gets their IDs on output we cannot use count, rather have to use:
aws_instance.trfm-instance-count[*].id

2. While configuring through console, we have option to create target group without registering instance(s), but in case of terraform it is mandatory. 
So option is to use instance-id resource or update ARN of targetgroup in AutoScaling Group.


# Issue facing with ECS Container:
1. Health check in Target group is failing when httpd server not running in EC2 instance, through Uerdata.

2. When I explictly run httpd server in Userdata, health check pass but task fails to run, stating port issue:
Status reason	CannotStartContainerError: Error response from daemon: driver failed programming external connectivity on endpoint ecs-rearc-quest-tasks-trfm-ecs-17-rearc-quest-tasks-trfm-tdef-contnr-9edaed8b8fa48e8b3500 (600f547283c2d4054152be4874eb3de399303c94a1655a8a5
Run tasks failed
Reasons : ["RESOURCE:PORTS"].

3 When I am not starting httpd server explicitly in Uerdata, task is failing stating memory issue.
Stopped reason Essential container in task exited
Exit Code	2
