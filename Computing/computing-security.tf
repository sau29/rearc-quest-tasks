/*
Code in this file does following:
1. Create Trust policy - Assume role
2. Attaching this policy to Role
3. Create IAM instance profile

TODO:
1. Attach AWS Managed policy - currently Terraform has limitation and it throws error.
2. Have Name and Tags update with variable string.
*/


# IAM Rola and Policy
data "aws_iam_policy_document" "rearc-quest-tasks-trfm-ec2-iampolicy" {
  statement {

    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rearc-quest-tasks-trfm-ec2-iamrole" {
  name               = "rearc-quest-tasks-trfm-ec2-iamrole"
  assume_role_policy = data.aws_iam_policy_document.rearc-quest-tasks-trfm-ec2-iampolicy.json
}


resource "aws_iam_instance_profile" "rearc-quest-tasks-trfm-ec2-instprfl" {
  name = "rearc-quest-tasks-trfm-ec2-instprfl"
  role = aws_iam_role.rearc-quest-tasks-trfm-ec2-iamrole.name
}