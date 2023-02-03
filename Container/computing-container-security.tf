/*
Code in this file does following:
1. IAM policy document with assume role, i.e trust policy.
2. IAM Role, with IAM policy document which is trust policy.
3. Create instance profile, that will associate with EC2 instance.

TODO:
1. Name and Tags in variable format.
2. IAM role is not having any IAM policy
3. Could not add AWS Managed policy in the IAM role. This seems to be Terraform limitation.
*/

# IAM Rola and Policy
data "aws_iam_policy_document" "rearc-quest-tasks-trfm-tdef-iampolicy" {
  statement {

    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rearc-quest-tasks-trfm-tdef-iamrole" {
  name               = "rearc-quest-tasks-trfm-tdef-iamrole"
  assume_role_policy = data.aws_iam_policy_document.rearc-quest-tasks-trfm-tdef-iampolicy.json
}


resource "aws_iam_instance_profile" "rearc-quest-tasks-trfm-tdef-instprfl" {
  name = "rearc-quest-tasks-trfm-tdef-instprfl"
  role = aws_iam_role.rearc-quest-tasks-trfm-tdef-iamrole.name
}

/*
│ Error: Error attaching policy arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role to IAM Role aws_iam_role.rearc-quest-tasks-trfm-tdef-iamrole.name: NoSuchEntity: The role with name aws_iam_role.rearc-quest-tasks-trfm-tdef-iamrole.name cannot be found.
│       status code: 404, request id: 54b8e510-a510-46c9-a910-16b624823b1e
│
│   with aws_iam_role_policy_attachment.rearc-quest-tasks-trfm-tdef-polattach,
│   on computing-container.tf line 84, in resource "aws_iam_role_policy_attachment" "rearc-quest-tasks-trfm-tdef-polattach":
│   84: resource "aws_iam_role_policy_attachment" "rearc-quest-tasks-trfm-tdef-polattach" {

==> Do we need to create ROLE beforehand only?
This seems to be known issue - attaching managed policy to role;
https://github.com/hashicorp/terraform/issues/5979

*/

/*
Since these 2 policies are not part of instance profile, launch instance is not able to get into cluster;
once policies are attached manually, instances getting added;
*/
# resource "aws_iam_role_policy_attachment" "rearc-quest-tasks-trfm-tdef-polattach" {
#   role       = "aws_iam_role.rearc-quest-tasks-trfm-tdef-iamrole.name"
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
# }
