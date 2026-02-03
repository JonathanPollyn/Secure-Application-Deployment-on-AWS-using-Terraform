data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "secure-prod-style-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -eux
    dnf -y update
    dnf -y install nginx
    systemctl enable nginx
    echo "<h1>JP Portfolio App - $(hostname)</h1>" > /usr/share/nginx/html/index.html
    systemctl start nginx
  EOF
  )



  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "secure-prod-style-app"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name             = "secure-prod-style-app-asg"
  desired_capacity = 2
  min_size         = 2
  max_size         = 2

  vpc_zone_identifier = [
    aws_subnet.private-app-sn-1.id,
    aws_subnet.private-app-sn-2.id
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "secure-prod-style-app-asg"
    propagate_at_launch = true
  }
}
