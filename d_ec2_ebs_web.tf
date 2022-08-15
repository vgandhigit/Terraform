provider "aws" {
  region     = "ap-south-1"
  profile = "default"

}


resource "aws_instance" "webserver" {
  ami = "ami-076e3a557efe1aa9c"
  instance_type = "t2.micro"           ## To use existing security group
  key_name = "web"                     ## To use existing key pair

  tags = {
    Name = "webserver"
  }
}


resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.webserver.availability_zone
  size              = 1

  tags = {
    Name = "webdata"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.webserver.id

}

#### Connection Block ####

resource "null_resource" "null3" {

connection { 
   type 	= "ssh"
   user  = "ec2-user"
   private_key = file("C:/Users/Vivek Gandhi/Downloads/web.pem")   
   host = aws_instance.webserver.public_ip
}

#### Provisioner Block ####

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",      
      "sudo yum install php -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo yum install git -y",
      "sudo mkfs.ext4 /dev/xvdc",
      "sudo mount /dev/xvdc /var/www/html",
      "sudo git clone https://github.com/vgandhigit/web.git /var/www/html/web",
    ]
  }

}


