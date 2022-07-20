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
  definition    = jsonencode(
    {
      Comment = "A Hello World example demonstrating various state types of the Amazon States Language"
      StartAt = "Pass"
      States  = {
        "Hello World"          = {
          End  = true
          Type = "Pass"
        }
        "Hello World example?" = {
          Choices = [
            {
              BooleanEquals = true
              Next          = "Yes"
              Variable      = "$.IsHelloWorldExample"
            },
            {
              BooleanEquals = false
              Next          = "No"
              Variable      = "$.IsHelloWorldExample"
            },
          ]
          Comment = "A Choice state adds branching logic to a state machine. Choice rules can implement 16 different comparison operators, and can be combined using And, Or, and Not"
          Default = "Yes"
          Type    = "Choice"
        }
        No                     = {
          Cause = "Not Hello World"
          Type  = "Fail"
        }
        "Parallel State"       = {
          Branches = [
            {
              StartAt = "Hello"
              States  = {
                Hello = {
                  End  = true
                  Type = "Pass"
                }
              }
            },
            {
              StartAt = "World"
              States  = {
                World = {
                  End  = true
                  Type = "Pass"
                }
              }
            },
          ]
          Comment  = "A Parallel state can be used to create parallel branches of execution in your state machine."
          Next     = "Hello World"
          Type     = "Parallel"
        }
        Pass                   = {
          Comment = "A Pass state passes its input to its output, without performing work. Pass states are useful when constructing and debugging state machines."
          Next    = "Hello World example?"
          Type    = "Pass"
        }
        "Wait 3 sec"           = {
          Comment = "A Wait state delays the state machine from continuing for a specified time."
          Next    = "Parallel State"
          Seconds = 3
          Type    = "Wait"
        }
        Yes                    = {
          Next = "Wait 3 sec"
          Type = "Pass"
        }
      }
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
