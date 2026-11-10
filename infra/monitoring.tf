resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = local.name
  dashboard_body = jsonencode({
    widgets = [
      # Business
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Gift suggestions generated (business)"
          region  = var.region
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300
          metrics = [[local.name, "wishifai.gifts.suggested.count"]]
        }
      },
      # Latency metrics
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Latency: Bedrock vs Rekognition (ms)"
          region = var.region
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          metrics = [
            [local.name, "wishifai.bedrock.latency.avg"],
            [local.name, "wishifai.rekognition.latency.avg"]
          ]
        }
      },
      # Infrastructure (ECS)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ECS: CPU and memory (%)"
          region = var.region
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", "default", "ServiceName", local.name],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", "default", "ServiceName", local.name]
          ]
        }
      },
      # Application
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "HTTP /api/analyze: response time (ms)"
          region = var.region
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          metrics = [
            [local.name, "http.server.requests.avg", "exception", "none", "method", "POST", "error", "none",
            "uri", "/api/analyze", "outcome", "SUCCESS", "status", "200"]
          ]
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "bedrock_slow" {
  alarm_name          = "${local.name}-bedrock-latency-high"
  alarm_description   = "Bedrock average response time over 25 seconds for 10 minutes"
  namespace           = local.name
  metric_name         = "wishifai.bedrock.latency.avg"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 25000
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}