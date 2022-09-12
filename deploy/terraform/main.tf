data "aws_caller_identity" "current" {}

module "github_readonly" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role = true

  role_name = "github_readonly"

  provider_url = "token.actions.githubusercontent.com"

  role_policy_arns              = [data.aws_iam_policy_document.github_readonly.arn, "arn:aws:iam::aws:policy/ReadOnlyAccess"]
  number_of_role_policy_arns    = 2
  oidc_fully_qualified_subjects = ["repo:CloudCitizen/polaris-iam:pull_request"]

  tags = {
    Role = "github-role-with-oidc"
  }
}

module "github_readwrite" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role = true

  role_name = "github_readonly"

  provider_url = "token.actions.githubusercontent.com"

  role_policy_arns              = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  number_of_role_policy_arns    = 2
  oidc_fully_qualified_subjects = ["repo:CloudCitizen/polaris-iam:ref:refs/heads/main"]

  tags = {
    Role = "github-role-with-oidc"
  }
}

data "aws_iam_policy_document" "github_readonly" {
  statement {
    sid = "KMSkeyAccess"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
  statement {
    sid = "StateBucket"
    actions = [
      "s3:GetBucketLocation",
      "s3:List*"
    ]
    resources = ["*"]
  }
  statement {
    sid = "StateFileRead"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = ["${local.terraform_state_bucket_arn}/${data.aws_caller_identity.current.account_id}/*"]
  }
  statement {
    sid = "AllowDynamoDBActions"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem"
    ]
    resources = ["*"]
  }
}
