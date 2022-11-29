resource "aws_launch_configuration" "ec2LaunchConfig" {
  name = "LanuchConfig- " 
  image_id      = var.AmiID
  instance_type = var.InstanceType
  security_groups=[ aws_security_group.ec2SecurityGrp.id]
  user_data = <<-EOF
   #!/bin/bash
        #!/bin/bash
        apt update -y
        apt install apache2 -y
        systemctl start apache2.service
        systemctl enable apache2.service
        echo "<h><head><title> Udacitys School of Cloud Computing</title></head> <body>Hello from Udgram Hussein Ahmed </body> </h>" > /var/www/html/index.html
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





resource "aws_security_group" "ec2SecurityGrp" {

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

