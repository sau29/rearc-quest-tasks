# Define Output Values

# Attribute Reference: VPC
output "aws_vpc_id_output" {
  description = "VPC ID"
  value       = aws_vpc.rearc-quest-tasks-trfm-vpc.id
}

#Subnets
output "aws_subnet_pub1_output" {
  description = "Subnet ID for public subnet1"
  value       = aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id
}
output "aws_subnet_pub2_output" {
  description = "Subnet ID for public subnet2"
  value       = aws_subnet.rearc-quest-tasks-trfm-subnet2-pub.id
}

# # Security Groups
# output "aws_security_group_albid_output" {
#   description = "SG ID for ALB"
#   value       = aws_security_group.rearc-quest-tasks-trfm-sg-alb.id
# }
# output "aws_security_group_ec2id_output" {
#   description = "SG ID for EC2 Server"
#   value       = aws_security_group.rearc-quest-tasks-trfm-sg-ec2.id
# }