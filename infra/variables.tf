variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "kandidatnr" {
  description = "Candidate number, used in naming"
  type        = string
  default     = 17
}

variable "image_tag" {
  description = "Image tag in ECR (short commit SHA)"
  type        = string
}

variable "execution_role_arn" {
  type    = string
  default = "arn:aws:iam::244530008913:role/ecsTaskExecutionRole"
}

variable "infrastructure_role_arn" {
  type    = string
  default = "arn:aws:iam::244530008913:role/service-role/ecsInfrastructureRoleForExpressServices"
}