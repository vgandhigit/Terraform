
provider "aws" {
  region     = "ap-south-1"
  profile    = "default" 
}

# Create Instance #

resource "aws_instance" "vivek" {
  ami           = "ami-076e3a557efe1aa9c"
  instance_type = "t2.micro"


  tags = {
    Name = "VIVEKTERAEBS"
  }
}

# Create EBS volume #

resource "aws_ebs_volume" "vivekdata" {
  availability_zone = aws_instance.vivek.availability_zone
  size              = 1

  tags = {
    Name = "vivekdata"
  }
}

# Attached EBS volume to EC2 #

resource "aws_volume_attachment" "vivekdata" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.vivekdata.id
  instance_id = aws_instance.vivek.id
}

# Getting Multipule values from one output #

output "instance_info" {
    value = [aws_ebs_volume.vivekdata.id, aws_instance.vivek.id]
}