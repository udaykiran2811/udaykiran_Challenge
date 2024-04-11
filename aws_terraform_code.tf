# Define provider (AWS)
provider "aws" {
  region = "us-east-1" # Adjust the desired region
}
resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Security group for web server"

 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create self-signed SSL certificate
resource "tls_self_signed_cert" "web_server_cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.web_server_key.private_key_pem
  subject {
    common_name = "example.com" # Change to your domain
  }
}

resource "tls_private_key" "web_server_key" {
  algorithm = "RSA"
}

# Create EC2 instance
resource "aws_instance" "web_server" {
  ami                    = "AMI_ID" #  AMI ID, change as needed
  instance_type          = "t2.micro" # Change to your desired instance type
  key_name               = "your_key_pair" # Change to your key pair name
  security_groups        = [aws_security_group.web_server_sg.name]
  user_data              = <<-EOF
                              #!/bin/bash
                              apt-get update
                              apt-get install -y apache2
                              cat <<EOF > /var/www/html/index.html
                              <html>
                              <head>
                              <title>Hello World</title>
                              </head><body>
                              <h1>Hello World!</h1>
                              </body></html>
                              systemctl restart apache2
                              EOF
}
resource "aws_autoscaling_group" "example" {
  name                 = "example-asg"
  launch_configuration = "${aws_launch_configuration.example.id}"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2

  vpc_zone_identifier = ["${aws_subnet.example.id}"]  

  tag {
    key                 = "Name"
    value               = "example-server"
    propagate_at_launch = true
  }
}
resource "aws_elb" "example" {
  name               = "example-elb"
  availability_zones = ["us-east-1]  # Enter your desired availability zones

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.example.name}"
  elb                   = "${aws_elb.example.name}"
}
resource "aws_wafv2_web_acl" "example_acl" {
  name        = "example-web-acl"
  description = "Example Web ACL"

  scope = "REGIONAL" # ACL applies to resources in a specific region

  default_action {
    allow {} # Change this to BLOCK or COUNT based on your requirements
  }

}

resource "aws_lb" "example_lb" {
  name               = "example-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet", "subnet"] # Specify your subnets
}

resource "aws_wafv2_web_acl_association" "example_acl_association" {
  resource_arn = aws_lb.example_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.example_acl.arn
}










                              
                              
                            
