resource "aws_lambda_function" "java_lambda" {
  function_name = "${var.stack}-${var.function_name}"
  description = "sample lambda for docker image"
#   runtime       = "java17"
#   handler       = "com.example.Handler" # Update with your Java class handler
  memory_size   = 256
  timeout       = 10

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.image_repo.repository_url}:latest"

  role = aws_iam_role.lambda_execution_role.arn

#   filename         = "dummy-lambda-function.zip" # Update with your Java application's ZIP file
#   source_code_hash = filebase64sha256("dummy-lambda-function.zip")

  # vpc_config {
  #   subnet_ids         = data.aws_subnets.private_subnets.ids
  #   security_group_ids = [aws_security_group.lambda_sg.id]
  # }

  # environment {
  #   variables = {
  #     SPRING_DATASOURCE_URL  = data.aws_db_instance.example_db.endpoint
  #     SPRING_DATASOURCE_USERNAME = var.db_user
  #     SPRING_DATASOURCE_PASSWORD  = "rds_mysql_secret"
  #   }
  }

# # #    image_config {
# # #           command           = ["./mvnw", "spring-boot:run" ]
# # #           entry_point       = []
# # #           working_directory = "/app"
# # #         }


# #   tags = {Name="${var.stack}-${var.function_name}"}
# #   # lifecycle {
# #   #   ignore_changes = [ environment["SPRING_DATASOURCE_PASSWORD"] ]
# #   # }
# }


# Create an SQS Queue
# resource "aws_sqs_queue" "sqs_queue" {
#   name = "sqs-lambda-trigger-queue"
# }


# Configure the SQS trigger for the Lambda function
# resource "aws_lambda_event_source_mapping" "sqs_trigger" {
#   event_source_arn = aws_sqs_queue.sqs_queue.arn
#   function_name    = aws_lambda_function.java_lambda.arn
#   batch_size       = 1
# }