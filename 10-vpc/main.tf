variable "profile" {
  type        = "string"
  description = "Das Profil, mit dem das Setup ausgeführt werden soll"
  default     = "default"
}

variable "environment" {
  type        = "string"
  description = "Die Umgebung, in der die Infrastruktur aufgesetzt wird (develop, staging, live)"
}

variable "project" {
  type        = "string"
  description = "Das Projekt, für welches die Infrastruktur aufgesetzt wird"
}

variable "workspace_iam_roles" {
  type = "map"
  description = "Die Auflistung der IAM-Role-IDS in den unterschiedlichen Umgebungen"
}

variable "environment_key" {
  type = "string"
  description = "Der Key der aktuellen Umgebung. (live, staging oder dev für die verschiedenen Entwickler)"
}

variable "region" {
  type = "string"
}

locals {
  prefix = "${var.environment}-${var.project}"
}

provider "aws" {
  profile = "${var.profile}"
  region  = "eu-central-1"
  version = "1.46"

  assume_role {
    role_arn = "${var.workspace_iam_roles[var.environment_key]}"
  }
}

terraform {
  backend "s3" {
    bucket               = "user-state"
    key                  = "<ordername>.tfstate"
    region               = "eu-central-1"
    dynamodb_table       = "StateLocks"
    encrypt              = true
    kms_key_id           = "<kms-key>"
    workspace_key_prefix = "<projektname>"
  }
}

//module "vpc" {
//  source = "../tf-modules/vpc"
//  environment = "${var.environment}"
//  ident = "${var.project}-main"
//  region = "${var.region}"
//}

