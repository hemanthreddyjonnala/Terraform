# Create the Lambda deployment package (ZIP)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "lambda_source"  # Path to the Python Lambda source code directory
  output_path = "lambda.zip"
}



# Create the target Lambda function
resource "aws_lambda_function" "deploy_lambda" {
  function_name = "ecr-docker-image-deploy-lambda-function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  memory_size   = 128
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_execution_role.arn

  # vpc_config {
  #   subnet_ids         = data.aws_subnets.private_subnets.ids
  #   security_group_ids = [aws_security_group.lambda_sg.id]
  # }
}