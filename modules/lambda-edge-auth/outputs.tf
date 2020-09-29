output "qualified_arn" {
  description = "Qualified ARN of the lambda edge that performs basic authentication"
  value       = aws_lambda_function.lambda_edge_auth.qualified_arn
}