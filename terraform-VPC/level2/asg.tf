resource "aws_launch_configuration" "main" {
  name_prefix     = "${var.env_code}-"
  image_id        = data.aws_ami.amazonlinux.id
  instance_type   = "t2.micro"
  key_name        = "main"
  security_groups = [aws_security_group.private.id]
  user_data       = file("user-data.sh")
}

resource "aws_autoscaling_group" "main" {
  name             = var.env_code
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  target_group_arns    = [aws_alb_target_group.main.arn]
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = data.terraform_remote_state.level1.outputs.privatesub_id

  tags = [
    {
      key                 = "Name"
      value               = var.env_code
      propagate_at_launch = true
    }
  ]
}
