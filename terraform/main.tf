resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "aws-key"

  tags = {
    Name = "terraform-mern"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install docker -y",
      "sudo systemctl enable docker",
      "sudo systemctl start docker"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/aws-key.pem")
      host        = self.public_ip
    }
  }
}
