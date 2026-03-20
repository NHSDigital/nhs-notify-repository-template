# module "example_image_lambda" {
#   source = "https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.32/terraform-lambda.zip"

#   project        = var.project
#   environment    = var.environment
#   component      = var.component
#   aws_account_id = var.aws_account_id
#   region         = var.region
#   group          = var.group

#   function_name = "example-image-lambda"
#   description   = "Example image lambda function"

#   kms_key_arn = var.kms_key_arn

#   package_type           = "Image"
#   image_uri              = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project}-${var.parent_acct_environment}-acct@${data.aws_ecr_image.example_image_lambda.image_digest}"
#   image_repository_names = ["${var.project}-${var.parent_acct_environment}-acct"]

#   memory  = 128
#   timeout = 3


#   send_to_firehose          = var.send_to_firehose
#   log_destination_arn       = var.log_destination_arn
#   log_retention_in_days     = var.log_retention_in_days
#   log_subscription_role_arn = var.log_subscription_role_arn
# }

# data "aws_ecr_image" "example_image_lambda" {
#   registry_id     = var.aws_account_id
#   repository_name = "${var.project}-${var.parent_acct_environment}-acct"
#   image_tag       = "${var.project}-${var.environment}-${var.component}-example-image-lambda-latest"
# }
