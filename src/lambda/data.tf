# # Retrieve the subnet ID based on tags
# data "aws_subnets" "private_subnets" {
#   tags = {
#     Name = "*PrivateSubnet*"
#   }
# }

# data "aws_vpc" "vpc" {
#   tags = {
#     Name = "*-VPC"
#   }
# }




data "aws_codestarconnections_connection" "connection" {
  name = "github-hemanthreddyjonnala"
}


# data "aws_ssm_parameter" "dbpassword" {
#   name = "/database/password"
# #   with_decryption = true
# }

# data "aws_db_instance" "example_db" {
#   db_instance_identifier = "${var.db_name}-db"
# }

# data "aws_iam_policy" "secret_manager_policy" {
#   name = "secret_manager_policy"
# }