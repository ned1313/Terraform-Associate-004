terraform {
  required_providers {
    random = {
        source = "hashicorp/random"
        version = ">2.0"
    }
  }
}

variable "test" {
  type = bool
  default = false
}

variable "post_cond" {
  type = bool
  default = false
}

resource "random_id" "testing" {
    byte_length = 8

    lifecycle {
      precondition {
        condition = var.test
        error_message = "The var.test failed."
      }
      postcondition {
        condition = var.post_cond
        error_message = "The var.post_cond failed."
      }
    }
}