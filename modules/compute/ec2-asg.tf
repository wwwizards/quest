#ami data
data "aws_ami" "a2linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

#Create autoscaling group launch template
resource "aws_launch_template" "web" {
  name_prefix            = "web-server"
  image_id               = data.aws_ami.a2linux.id
  instance_type          = var.web_instance_type
  key_name               = "quest-key"
  vpc_security_group_ids = [var.vpc_security_group_ids]
  user_data              = filebase64("dockerizer.sh")

  tags = {
    Name = "web-server"
  }
}

#create autoscaling group
resource "aws_autoscaling_group" "web" {
  name                = "web"
  vpc_zone_identifier = tolist(var.public_subnet)
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  
  lifecycle {
    ignore_changes = [ target_group_arns ]
  }
}

