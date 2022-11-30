resource "aws_launch_configuration" "ec2LaunchConfig" {
  name = "LanuchConfig- " 
  image_id      = var.AmiID
  instance_type = var.InstanceType
  security_groups=[ aws_security_group.ec2SecurityGrp.id]
  key_name = var.keyPair
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  user_data = <<-EOF
   #!/bin/bash
        #!/bin/bash
        apt update -y
        apt-get install apache2 python3-pip  awscli -y 
        systemctl start apache2.service
        systemctl enable apache2.service
        cd /var/www/html
        aws s3 \cp  s3://${var.bucketname}/code/index.html .
  EOF
}
resource "aws_autoscaling_group" "AutoScallingGroup" {
  name = "ASGGroupp"
  max_size             = var.MaxCapacity
  min_size             = var.MinCapacity
  launch_configuration = aws_launch_configuration.ec2LaunchConfig.name
  vpc_zone_identifier  = [data.aws_subnet.PrivSubnet1.id, data.aws_subnet.PrivSubnet2.id]
  target_group_arns = [ aws_lb_target_group.alb-targetGroup.arn ]
 
}
resource "aws_autoscaling_policy" "ASGpolicy" {
  name = "ASGPoliccy"
 target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

  target_value = 40.0
 }
  policy_type= "TargetTrackingScaling"
  autoscaling_group_name= aws_autoscaling_group.AutoScallingGroup.name
}
resource "aws_lb" "LoadBalancer" {
  name               = "test-lb-tf"
 
  subnets            = [data.aws_subnet.PublicSub1.id,data.aws_subnet.PublicSub2.id]

  security_groups = [ "${aws_security_group.LB-Secrity-Group.id}" ]

  tags = {
    name = "Load-balancer"
  }
}

resource "aws_lb_target_group" "alb-targetGroup" {
  name        = "tf-example-lb-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.VPC.id
  health_check {
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 8
    unhealthy_threshold= 2
  }
}
resource "aws_lb_listener" "LB-Listner" {
  load_balancer_arn = aws_lb.LoadBalancer.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-targetGroup.arn
  }
}




resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = aws_lb_listener.LB-Listner.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-targetGroup.arn
  }

    condition {
    path_pattern {
      values = ["/"]
    }
}
}


resource "aws_security_group" "bastionSecGrp" {

  vpc_id      = data.aws_vpc.VPC.id

  ingress {
   
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
   ingress {
   
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }
}
resource "aws_instance" "bastionServer" {  
  ami = var.AmiID
  instance_type = var.InstanceType
  subnet_id = data.aws_subnet.PublicSub1.id
  security_groups=[ aws_security_group.bastionSecGrp.id]
  key_name = var.keyPair

  tags = {
    Name = "Jumpbox"
  }
}

resource "aws_s3_bucket" "b" {
  bucket = var.bucketname

  tags = {
    Name        = "TF web app code"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.b.bucket
  source = "webcode/index.html"
  key = "code/index.html"
  
}

resource "aws_security_group" "ec2SecurityGrp" {

  vpc_id      = data.aws_vpc.VPC.id

  ingress {
   
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
   ingress {
   
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.VPC.cidr_block]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  tags = {
    Name = "Terraform-ec2-sec-grp"
  }
}

resource "aws_security_group" "LB-Secrity-Group" {
  vpc_id      = data.aws_vpc.VPC.id

  ingress {
   
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  tags = {
    Name = "Terraform-LB-sec-grp"
  }
}

