output "string_value" {
  description = "Value of the random string created."
  value       = random_string.main.result
}