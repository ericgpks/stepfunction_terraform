terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "stepfunction-tf-state"
    key    = "test.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  definition    = templatefile(
    "definition.tftpl",
    {
      wait_sec = 5
    }
  )
  name          = "HelloWorld"
  role_arn      = "arn:aws:iam::XXX:role/service-role/StepFunctions-HelloWorld-role"
  tags          = {}
  tags_all      = {}
  type          = "STANDARD"

  logging_configuration {
    include_execution_data = false
    level                  = "OFF"
  }

  tracing_configuration {
    enabled = false
  }
}
