provider "aws" {
  region = var.region

  allowed_account_ids = [
    var.aws_account_id,
  ]

  default_tags {
    tags = {
      Project         = var.project
      Environment     = var.environment
      Component       = var.component
      Group           = var.group
      NHSNotifyDomain = var.nhs_notify_domain
      Name            = local.csi
    }
  }
}
