provider "aws" {
  region = var.region
}

variable "private_key" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0" # à adapter selon ton OS
  instance_type = "t2.micro"
  key_name      = "aws-key"  # Clé EC2 déjà créée dans AWS
  private_key   = var.private_key

  tags = {
    Name = "MERN-App"
  }
}
