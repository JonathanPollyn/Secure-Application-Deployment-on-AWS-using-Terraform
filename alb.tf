# ALB for HTTPS, ACM, target group including listner
resource "aws_alb" "alb" {
  name               = "secure-prod-style-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public-sn-1.id, aws_subnet.public-sn-2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "secure-prod-style-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}