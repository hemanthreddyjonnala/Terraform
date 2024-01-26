
# ---------------------------------------------------------------------------------------------------------------------
# Code Pipeline
# ---------------------------------------------------------------------------------------------------------------------


# Codepipeline role

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.stack}-lambda-codepipeline-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
  tags={name = "lambda-codepipeline-role"}
}

resource "aws_iam_policy" "codepipeline_policy" {
  description = "Policy to allow codepipeline to execute"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.artifact_bucket.arn}/*"
    },
    {
      "Action" : [
        "codebuild:StartBuild", "codebuild:BatchGetBuilds",
        "cloudformation:*",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action" : [
        "ecs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
   
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:GetConnection",
        "codestar-connections:UseConnection"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

#  {
#       "Action" : [
#         "codecommit:CancelUploadArchive",
#         "codecommit:GetBranch",
#         "codecommit:GetCommit",
#         "codecommit:GetUploadArchiveStatus",
#         "codecommit:UploadArchive"
#       ],
#       "Effect": "Allow",
#       "Resource": "${aws_codecommit_repository.source_repo.arn}"
#     },


resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

# Create a custom IAM policy for invoking the Lambda function
resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "${var.stack}-lambda-invoke-policy"
  description = "Allows invoking the target Lambda function"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "${aws_lambda_function.deploy_lambda.arn}"
    }
  ]
}
EOF
}

# Attach the custom IAM policy to the CodePipeline role
resource "aws_iam_role_policy_attachment" "lambda_invoke_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}


resource "aws_s3_bucket" "artifact_bucket" {
  tags={Name="${var.stack}-lambda-artifacts"}
}




# CodePipeline 

resource "aws_codepipeline" "pipeline" {
  depends_on = [
    aws_codebuild_project.codebuild,
    # aws_codecommit_repository.source_repo
  ]
  name     = "${var.stack}_${var.source_repo_name}-${var.source_repo_branch}-Pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.connection.arn
        FullRepositoryId = "${var.github_user}/${var.source_repo_name}"
        BranchName       = var.source_repo_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.id
      }
    }
  }

  stage {
    name = "manual-approval"
    action {
      name            = "manual-approval-action"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"
      run_order       = 1
      region = "${var.AWS_REGION}"
      configuration = {
        # ActionMode       = "Manual"
        CustomData       = "Approve or reject this stage"
        # NotificationArn  = "arn:aws:sns:your-notification-arn"
        # ExternalEntityLink = "https://your-custom-link"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "DeployAction"
      category         = "Invoke"
      owner            = "AWS"
      provider         = "Lambda"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      run_order        = 1

      configuration = {
        FunctionName = aws_lambda_function.deploy_lambda.function_name
        UserParameters = jsonencode(
          {
            "FunctionName": "${aws_lambda_function.java_lambda.function_name}",
            "ecrImage": "${aws_ecr_repository.image_repo.repository_url}:latest"
          })
      }
    }
  }

}



output "lambda_pipeline_url" {
  value = "https://console.aws.amazon.com/codepipeline/home?region=${var.AWS_REGION}#/view/${aws_codepipeline.pipeline.id}"
}


