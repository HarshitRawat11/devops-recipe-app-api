variable "tf_state_bucket" {
  description = "Name of S3 bucket in AWS for storing TF state"
  default     = "tf-state-devops-recipe-api"
}

variable "tf_state_lock_bucket" {
  description = "Name of the DynamoDB table for TF state locking"
  default     = "tf-lock-devops-recipe-app-api"
}

variable "project" {
  description = "Project name for tagging resources"
  default     = "recipe-app-api"
}

variable "contact" {
  description = "Contact name for tagging resources"
  default     = "harshit@example.com"
}