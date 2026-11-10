output "service_url" {
  description = "Public endpoint for the service"
  value       = aws_ecs_express_gateway_service.app.ingress_paths[0].endpoint
}

output "s3_bucket" {
  value = aws_s3_bucket.images.bucket
}

output "image" {
  value = local.image_uri
}

output "dashboard_url" {
  value = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}