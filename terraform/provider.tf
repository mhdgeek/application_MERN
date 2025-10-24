variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name"
  type        = string
  default     = "aws-key"
}

variable "ami" {
  description = "AMI ID pour EC2"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}
