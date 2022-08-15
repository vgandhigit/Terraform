provider "aws" {
  region  = "ap-south-1"
  profile = "default"
}

###########  VPC block ##################

resource "aws_vpc" "vivek_vpc_web" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vivek_vpc_web"
  }
}

##########  Internet Gateway ############
resource "aws_internet_gateway" "vivek_igw_web" {
  vpc_id = aws_vpc.vivek_vpc_web.id

  tags = {
    Name = "vivek_igw_web"
  }
}

######### Subnet #################

resource "aws_subnet" "vivek_Subnet_web" {
  vpc_id            = aws_vpc.vivek_vpc_web.id # Argument
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "vivek_subnet_web"
  }
}

############ Route Table ###################

resource "aws_route_table" "vivek_rt_web" {
  vpc_id = aws_vpc.vivek_vpc_web.id

  route = []
  tags = {
    Name = "vivek_rt_web"
  }
}

########### Route #####################

resource "aws_route" "vivek_route_web" {
  route_table_id         = aws_route_table.vivek_rt_web.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vivek_igw_web.id
  depends_on             = [aws_route_table.vivek_rt_web] # First create route table than after create route #
}

######### Security Group ###################

resource "aws_default_security_group" "default" {
  vpc_id      = aws_vpc.vivek_vpc_web.id

  ingress {
    description      = "All traffic"
    from_port        = 0    # All ports
    to_port          = 0    # All Ports
    protocol         = "-1" # All traffic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }

  ingress {
    description      = "ssh"
    from_port        = 22    # All ports
    to_port          = 22    # All Ports
    protocol         = "tcp" # All traffic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }


  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Outbound rule"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "vivek_sg_web"
  }
}

################# Route Table Association #################

resource "aws_route_table_association" "vivek_a_web" {
  subnet_id      = aws_subnet.vivek_Subnet_web.id
  route_table_id = aws_route_table.vivek_rt_web.id
}



################ EC2 Instance ##########################

resource "aws_instance" "vivek_ec2_web" {
  ami                         = "ami-076e3a557efe1aa9c"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.vivek_Subnet_web.id
  key_name                    = "web" ## To use existing key pair
  #security_groups             = ["aws_default_security_group.default"]
  tags = {
    Name = "vivek_web_terra"
  }
}


# Create EBS volume #

resource "aws_ebs_volume" "vivekdata_web" {
  availability_zone = aws_instance.vivek_ec2_web.availability_zone
  size              = 1

  tags = {
    Name = "vivekdata_web"
  }
}


# Attached EBS volume to EC2 #

resource "aws_volume_attachment" "vivekdata_web" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.vivekdata_web.id
  instance_id = aws_instance.vivek_ec2_web.id
}

#### Connection Block ####

resource "null_resource" "null3" {

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Vivek Gandhi/Downloads/web.pem")
    host        = aws_instance.vivek_ec2_web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo yum install git -y",
      "sudo mkfs.ext4 /dev/xvdc",
      "sudo mount /dev/xvdc /var/www/html",
      "sudo git clone https://github.com/vgandhigit/web.git /var/www/html/web",
    ]
  }
}




