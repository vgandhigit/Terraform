provider "aws" {
  region  = "ap-south-1"
  profile = "default"
}

###########  VPC block ##################

resource "aws_vpc" "vivek_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vivek_vpc"
  }
}

##########  Internet Gateway ############
resource "aws_internet_gateway" "vivek_igw" {
  vpc_id = aws_vpc.vivek_vpc.id

  tags = {
    Name = "vivek_igw"
  }
}

######### Subnet #################

resource "aws_subnet" "vivek_Subnet" {
  vpc_id     = aws_vpc.vivek_vpc.id # Argument
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "vivek_subnet"
  }
}

############ Route Table ###################

resource "aws_route_table" "vivek_rt" {
  vpc_id = aws_vpc.vivek_vpc.id

  route = []
  tags = {
    Name = "vivek_rt"
  }
}

########### Route #####################

resource "aws_route" "vivek_route" {
  route_table_id         = aws_route_table.vivek_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vivek_igw.id
  depends_on             = [aws_route_table.vivek_rt] # First create route table than after create route #
}

######### Security Group ###################

resource "aws_security_group" "vivek_sg" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.vivek_vpc.id

  ingress = [
    {
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
  ]

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
    Name = "all_traffic"
  }
}

################# Route Table Association #################

resource "aws_route_table_association" "vivek_a" {
  subnet_id      = aws_subnet.vivek_Subnet.id
  route_table_id = aws_route_table.vivek_rt.id
}