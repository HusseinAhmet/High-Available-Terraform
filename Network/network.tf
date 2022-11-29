resource "aws_vpc" "VPC" {
   cidr_block       = var.cidr
   enable_dns_hostnames = true
   enable_dns_support= true

   tags = {
     "Name" = " ${var.enviromentName} VPC"
   }
}
resource "aws_subnet" "PubSub1" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = var.PubSub1
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.enviromentName} PublicSubnet1"
  }
}
resource "aws_subnet" "PrivSub1" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = var.PrivSub1
availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.enviromentName} PrivateSubnet1"
  }
}
resource "aws_subnet" "PubSub2" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = var.PubSub2
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.enviromentName} PublicSubnet2"
  }
}
resource "aws_subnet" "PrivSub2" {
  vpc_id     =aws_vpc.VPC.id
  cidr_block = var.PrivSub2
availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.enviromentName} PrivateSubnet2"
  }
}
resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "${var.enviromentName} InternetGateway"
  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }

  tags = {
    Name = "${var.enviromentName} PublicRouteTable "
  }
}
resource "aws_route_table_association" "PubRouteTableAssociate" {
  subnet_id      = aws_subnet.PubSub1.id

  route_table_id = aws_route_table.PublicRouteTable.id
}
resource "aws_route_table_association" "PubRouteTableAssociate2" {
  subnet_id      = aws_subnet.PubSub2.id

  route_table_id = aws_route_table.PublicRouteTable.id
}
resource "aws_eip" "EIP1" {

  vpc      = true
}
resource "aws_eip" "EIP2" {
  vpc      = true
}
resource "aws_nat_gateway" "Nat1" {
  allocation_id = aws_eip.EIP1.id
  subnet_id     = aws_subnet.PubSub1.id

  tags = {
    Name = "gw NAT1"
  }
}
resource "aws_nat_gateway" "Nat2" {
  allocation_id = aws_eip.EIP2.id
  subnet_id     = aws_subnet.PubSub2.id

  tags = {
    Name = "gw NAT2"
  }

}

resource "aws_route_table" "PrivateRouteTable1" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat1.id
  }

  tags = {
    Name = "${var.enviromentName} PrivateRouteTable1"
  }
}
resource "aws_route_table" "PrivateRouteTable2" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat2.id
  }

  tags = {
    Name = "PrivateRouteTable2"
  }
}

resource "aws_route_table_association" "PrivRouteTableAssociate1" {
  subnet_id      = aws_subnet.PrivSub1.id

  route_table_id = aws_route_table.PrivateRouteTable1.id
}
resource "aws_route_table_association" "PrivRouteTableAssociate2" {
  subnet_id      = aws_subnet.PrivSub2.id

  route_table_id = aws_route_table.PrivateRouteTable2.id
}