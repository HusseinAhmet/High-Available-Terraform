# data "template_file" "user-data" {
#   template = file("Server/launch.sh")
# }

data "aws_vpc" "VPC" {
    tags = {
     "Name" = " ${var.enviromentName} VPC"
   }
  
}
data "aws_subnet" "PrivSubnet1" {
    tags = {
     Name = "${var.enviromentName} PrivateSubnet1"
  }
  
}
data "aws_subnet" "PrivSubnet2" {
    tags = {
      Name = "${var.enviromentName} PrivateSubnet2"
  
   }
  
}
data "aws_subnet" "PublicSub1" {
    tags = {
     Name = "${var.enviromentName} PublicSubnet1"
  }
  
}
data "aws_subnet" "PublicSub2" {
    tags = {
      Name = "${var.enviromentName} PublicSubnet2"
  
   }
  
}
