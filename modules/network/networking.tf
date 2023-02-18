# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Demo VPC"
  }
}

# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-Subnet-${count.index + 1}"
  }
}


# Create Application Public Subnet
resource "aws_subnet" "application-subnet" {
  count                   = length(var.private_cidrs)
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.private_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-Subnet-${count.index + 1}"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "Demo IGW"
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.web-subnet.*.id[count.index]
  route_table_id = aws_route_table.web-rt.id
}

# Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "ALB-SG"
  description = "Allows  inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "SSH from SYSADMIN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["100.1.218.234/32"]
  }

  ingress {
    description = "HTTP from WORLD"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from WORLD"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  
  ingress {
    description = "QuestApp from WORLD"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-SG"
  }
}

# Create Application Security Group
resource "aws_security_group" "webserver-sg" {
  name        = "Webserver-SG"
  description = "Allows inbound traffic from ALB to web layer"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description     = "Allow traffic to web layer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }

  ingress {
    description     = "Allow traffic to web layer"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Webserver-SG"
  }
}

#create internet facing ALB
resource "aws_lb" "external-elb" {
  name               = "External-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-sg.id]
  subnets            = aws_subnet.web-subnet[*].id
}

resource "aws_lb_target_group" "external-elb" {
  name     = "ALB-TG"
  port     = 443
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = var.target_id
  alb_target_group_arn   = aws_lb_target_group.external-elb.arn
}

resource "aws_lb_listener" "external-80" {
  load_balancer_arn = aws_lb.external-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"

    }
  }
}

resource "aws_lb_listener" "external-443" {
  load_balancer_arn = aws_lb.external-elb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-elb.arn
  }
}


