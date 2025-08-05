
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backend" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "backend" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.backend.name
}

# resource "terraform_data" "pip_install" {
#   triggers_replace = [ 
#       sha256(file("${path.module}/backend/requirements.txt")) 
#     ]
#   provisioner "local-exec" {
#     command = "pip3 install -r backend/requirements.txt -t ${path.module}/backend/"
#   }
# }

data "archive_file" "backend" {
  type        = "zip"
  source_dir  = "${path.module}/backend"
  output_path = "${path.module}/lambda.zip"
}


# Lambda function
resource "aws_lambda_function" "backend" {
  filename         = data.archive_file.backend.output_path
  function_name    = "ai-content-generator"
  role             = aws_iam_role.backend.arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.backend.output_base64sha256
  timeout          = 60

  runtime = "python3.13"

  environment {
    variables = {
      LOG_LEVEL      = "info"
      GEMINI_API_KEY = var.gemini_api_key
    }
  }
}

resource "aws_lambda_function_url" "backend" {
  function_name      = aws_lambda_function.backend.function_name
  authorization_type = "NONE" # TEMPORARY!

  cors {
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["*"]
  }
}

resource "aws_lambda_permission" "backend" {
  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.backend.function_name
  principal              = "*"
  function_url_auth_type = "NONE" # TEMPORARY!
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/aws/lambda/${aws_lambda_function.backend.function_name}"
  retention_in_days = 7
}