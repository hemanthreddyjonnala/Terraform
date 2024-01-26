# resource "aws_security_group" "lambda_sg" {
#   name        = "${var.stack}-lambda-security-group"
#   description = "Security group for Lambda function"
#   vpc_id      = data.aws_vpc.vpc.id

#   ingress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow inbound traffic from anywhere
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere
#   }
# }
