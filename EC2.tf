provider "aws" {
  region     = "ap-south-1"
  profile    = "default" 
}

# Create Instance #

resource "aws_instance" "vivek" {
  ami           = "ami-076e3a557efe1aa9c"
  instance_type = "t2.micro"

  tags = {
    Name = "VIVEKTERA"
  }
}