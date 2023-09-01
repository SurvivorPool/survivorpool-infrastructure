# MANUAL STEPS - NEED TO AUTHENTICATE GITHUB CONNECTION IN UI AND GIVE CODEBUILD ACCESS TO THE REPO IN UI 
resource "aws_codestarconnections_connection" "codestar_connection" {
  name          = "${var.app-name}-connection"
  provider_type = "GitHub"
}

# Create a webhook that triggers the CodeBuild project on push
resource "aws_codepipeline_webhook" "webhook" {
  name           = "${var.app-name}-${var.env}-webhook"
  target_pipeline = aws_codepipeline.pipeline.name
  authentication = "GITHUB_HMAC"
  target_action   = "Source"
  authentication_configuration {
    allowed_ip_range = "0.0.0.0/0"
    secret_token = var.github-token
  }
  filter {
    json_path      = "$.ref"
    match_equals = "refs/heads/${var.branch-name}"
  }
#  authentication_failure_reset_seconds = 60
  tags = {
    Name = "My Webhook"
  }
}

resource "aws_iam_role_policy" "codebuild-policy" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["codecommit:GitPull"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
        "iam:PassRole"
        ],
        Effect = "Allow",
        Resource = "*" 
      },
      {
        Action = [
        "ecs:*"
        ]
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"]
        Effect   = "Allow"
        Resource = "*"
      }
    ] 
  }) 
}

resource "aws_codebuild_project" "codebuild_project" {
  name         = "${var.app-name}-${var.env}-build-project"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS" 
  }

  source {
    type     = "GITHUB"
    location = var.repository-url
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    
    dynamic "environment_variable" {
      for_each = var.env-variables
      content {
        name = environment_variable.key
        value = environment_variable.value
      }
    }
  }
}

resource "aws_s3_bucket" "bucket-artifact" {
  bucket = "${var.app-name}-${var.env}-bucket"
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.app-name}-${var.env}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket-artifact.bucket
    type     = "S3"
  }
  # SOURCE
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.codestar_connection.arn
        FullRepositoryId = "${var.repo-owner-name}/${var.repo-name}"
        BranchName     = var.branch-name 
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }
  # BUILD
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }
  # DEPLOY
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]
      role_arn = aws_iam_role.codepipeline_role.arn

      configuration = {
        ClusterName =  var.cluster-name
        ServiceName = var.service-name
        //noinspection SpellCheckingInspection
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.app-name}-${var.env}-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  policy_arn = aws_iam_policy.codepipeline_iam_policy.arn
  role = aws_iam_role.codepipeline_role.name
}


resource "aws_iam_policy" "codepipeline_iam_policy" {
  name        = "${var.app-name}-${var.env}-codepipeline-policy"
  description = "Policy for CodePipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "codepipeline:StartPipelineExecution",
          "codepipeline:GetPipelineState",
          "codepipeline:GetPipelineExecution",
          "codepipeline:GetPipeline",
          "codepipeline:GetPipelineVersion",
          "codepipeline:GetPipelineExecution",
          "codepipeline:GetPipelineExecutionState",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:GetPipelineState",
          "codepipeline:GetPipeline",
          "codepipeline:GetPipelineVersion",
          "codepipeline:GetPipelineExecution",
          "codepipeline:GetPipelineExecutionState",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:GetPipelineExecutionSummary",
          "codepipeline:GetPipelineMetadata",
          "codepipeline:ListPipelines"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutBucketWebsite",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.bucket-artifact.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.bucket-artifact.bucket}",
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = [
          aws_codebuild_project.codebuild_project.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:GetDeployment",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeploymentTarget",
          "codedeploy:GetOnPremisesInstance",
          "codedeploy:ListDeploymentTargets",
          "codedeploy:ListOnPremisesInstances"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.codebuild_role.arn,
          aws_iam_role.codepipeline_role.arn,
          aws_iam_role.codedeploy_role.arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecs:*"
        ]
        Resource = "*"
      },
      {
        "Effect": "Allow",
        "Action": "codestar-connections:UseConnection",
        "Resource": aws_codestarconnections_connection.codestar_connection.arn
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM policy for CodeDeploy
resource "aws_iam_policy" "codedeploy_policy" {
  name        = "${var.app-name}-${var.env}-codedeploy-policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "codedeploy:*"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecs:*"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecr:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM role for CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.app-name}-${var.env}-codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}



# Attach the CodeDeploy policy to the CodeDeploy role
resource "aws_iam_role_policy_attachment" "codedeploy" {
  policy_arn = aws_iam_policy.codedeploy_policy.arn
  role       = aws_iam_role.codedeploy_role.name
}

# IAM policy for CodeBuild
resource "aws_iam_policy" "codebuild_policy" {
  name   = "${var.app-name}-${var.env}-codebuild-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:GetLifecycleConfiguration",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.bucket-artifact.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.bucket-artifact.bucket}",
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "sts:AssumeRole"
        ]
        Resource = [
          aws_iam_role.codebuild_role.arn
        ]
      },
      {
        "Effect": "Allow",
        "Action": "codestar-connections:UseConnection",
        "Resource": aws_codestarconnections_connection.codestar_connection.arn
      }
    ]
  })
}

# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name               = "${var.app-name}-${var.env}-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the CodeBuild policy to the CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild" {
  policy_arn = aws_iam_policy.codebuild_policy.arn
  role       = aws_iam_role.codebuild_role.name
}

resource "aws_iam_role_policy_attachment" "codedeply_ecs" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  role = aws_iam_role.codepipeline_role.name
}
