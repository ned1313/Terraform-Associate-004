resource "random_string" "random" {
  length           = 10
  special          = false
}

resource "local_file" "hello" {
  content  = "Hello, Terraform!"
  filename = "${path.module}/hello.txt"
}