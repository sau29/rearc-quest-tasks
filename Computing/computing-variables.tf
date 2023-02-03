variable "rearc-quest-tasks-trfm-ec2-instance_type" {
  description = "Instance Type for server"
  type        = string
  default     = "t2.micro"
}

variable "rearc-quest-tasks-trfm-ec2-asg-desired_capacity" {
  description = "Desired Capacity"
  type        = string
  default     = "1"
}

variable "rearc-quest-tasks-trfm-ec2-asg-min_size" {
  description = "Min Numbers of Server"
  type        = string
  default     = "1"
}
variable "rearc-quest-tasks-trfm-ec2-asg-max_size" {
  description = "Min Numbers of Server"
  type        = string
  default     = "1"
}