variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0c02fb55956c7d316" # Amazon Linux 2
}

variable "key_name" {
  description = "Nom de la clé SSH"
  default     = "ma-cle-ssh"
}

