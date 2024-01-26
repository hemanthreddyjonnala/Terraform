resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.stack}-lambda-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
        "Effect": "Allow",
        "Principal": {
          "Service": "codedeploy.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.stack}-lambda-create-network-interface-policy"
  description = "Policy for Lambda to call CreateNetworkInterface"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*NetworkInterface*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_execution_role_policy" {
  name   = "${var.stack}-lambda-execution-role-policy"
  role   = aws_iam_role.lambda_execution_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode"
      ],
      "Resource": "arn:aws:lambda:us-east-1:*:function:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name   = "${var.stack}-lambda-execution-codepipeline-job-policy"
  role   = aws_iam_role.lambda_execution_role.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CodePipelinePermissions",
      "Effect": "Allow",
      "Action": [
        "codepipeline:PutJob*Result"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}



# resource "aws_iam_role_policy_attachment" "secret-manger-policy-attachment" {
#    # Attach the secret manager policy to the Lambda execution role
#   role       = aws_iam_role.lambda_execution_role.name
#   policy_arn = data.aws_iam_policy.secret_manager_policy.arn
# }


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


resource "aws_iam_role_policy_attachment" "lambda_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess" # Adjust the policy as per your requirements
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}
