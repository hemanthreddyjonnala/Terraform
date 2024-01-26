# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "AWS_REGION" {
  description = "aws region"
  default     = "us-east-1"
}

variable "AWS_PROFILE" {
  description = "aws profile"
  default     = "default"
}

variable "AWS_CREDENTIALS" {
  description = "path to credential file"
  default     = "~/.aws/credentials"
}

variable "function_name" {
  description = "Name of the Lambda function"
  default     = "lambda-py-docker-image"
}

variable "stack" {
  description = "Name of the stack."
  default     = "devops"
}


# Source repo name and branch

variable "github_user" {
    description = "github user name"
    type = string
    default = "hemanthreddyjonnala"
}

variable "source_repo_name" {
    description = "Source repo name"
    type = string
    default = "lambda_docker"
}

variable "source_repo_branch" {
    description = "Source repo branch"
    type = string
    default = "main"
}




# Image repo name for ECR

variable "image_repo_name" {
    description = "Image repo name"
    type = string
    default = "lambda-py-ecr-image"
}

variable "container_name" {
    description = "Lambda container repo name"
    type = string
    default = "lambda-py-container"
}


variable "db_user" {
  description = "RDS DB username"
  default     = "root"
}

variable "db_name" {
  description = "RDS DB name"
  default     = "measure"
}