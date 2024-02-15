provider "aws" {
    region = var.Region
}

terraform {
  backend "s3" {
    key    = "Split-integratin/state"
  }
}

data "aws_caller_identity" "current" {}


resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = var.State-Bucket
}

resource "aws_cloudwatch_event_rule" "invoke_lambda" {
  name        = "Invoke-Lambda"
  description = "Need to trigger lambda wrt cron"
  schedule_expression = var.CRON
}


resource "aws_cloudwatch_event_target" "Attaching_Splitwise_lambda" {
  target_id = "Splitwise_Lambda"
  rule      = aws_cloudwatch_event_rule.invoke_lambda.name
  arn = aws_lambda_function.Splitwise_Lambda.arn
}

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

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid       = "AllowS3GetObject"
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.Bucket}/*",
    ]
  }

  statement {
    sid       = "AllowSSMParameterRead"
    effect    = "Allow"
    actions   = [
      "ssm:GetParameter",
    ]
    resources = [
      "arn:aws:ssm:${var.Region}:${data.aws_caller_identity.current.account_id}:parameter${aws_ssm_parameter.split_api_key.name}"
    ]
  }
}


resource "aws_iam_policy" "iam_for_lambda" {
  name               = "split_lambda_role"
  policy = data.aws_iam_policy_document.lambda_policy.json
}


resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.iam_for_lambda.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_ssm_parameter" "split_api_key" {
  name      = "/my-split-api-keys"
  type      = "SecureString"
  value     = var.split-key
  key_id    = "alias/aws/ssm"
  overwrite = true
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "code"
  output_path = "code_py.zip"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.Bucket
  acl    = "private"
}

resource "aws_s3_bucket_object" "my_json" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "sheets-integrate.json" 
  source = "sheets-integrate.json"
  content_type = "text/plain"
  content_encoding = "gzip"
}

resource "aws_lambda_function" "Splitwise_Lambda" {
  filename      = "code_py.zip"
  function_name = "Splitwise_Integration"
  role          = aws_iam_role.lambda_role.arn
  handler       = "balance.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime = "python3.8"
  timeout = 30
  layers = [aws_lambda_layer_version.requests_lambda_layer.arn, aws_lambda_layer_version.gspread_lambda_layer.arn, aws_lambda_layer_version.oAuth_lambda_layer.arn]
    environment {
    variables = {
      Bucket = aws_s3_bucket.my_bucket.id
      Bucket_key = aws_s3_bucket_object.my_json.key
      S_key = aws_ssm_parameter.split_api_key.name
      Sheets = var.Gsheet-name
      Column = var.Place-to-insert
    }
  }
}

resource "aws_lambda_permission" "with_event_rule" {
  statement_id  = "AllowExecutionFromEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Splitwise_Lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_lambda.arn
}

resource "aws_lambda_layer_version" "requests_lambda_layer" {
  filename   = "Python_Libraries/request_lambda_layer_payload.zip"
  layer_name = "requests_lambda_layer_name"
  compatible_runtimes = ["python3.8"]
  compatible_architectures = ["x86_64"]
  description = "Python Library"
  skip_destroy = true
}

resource "aws_lambda_layer_version" "gspread_lambda_layer" {
  filename   = "Python_Libraries/gspread_lambda_layer_payload.zip"
  layer_name = "gspread_lambda_layer_name"
  compatible_runtimes = ["python3.8"]
  compatible_architectures = ["x86_64"]
  description = "Python Library"
  skip_destroy = true
}

resource "aws_lambda_layer_version" "oAuth_lambda_layer" {
  filename   = "Python_Libraries/oAuth2_lambda_layer_payload.zip"
  layer_name = "oAuth2_lambda_layer_name"
  compatible_runtimes = ["python3.8"]
  compatible_architectures = ["x86_64"]
  description = "Python Library"
  skip_destroy = true
}