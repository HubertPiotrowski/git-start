module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.env_code}-private"
  description = "Allow port 80 and 3306 TCP inbound to ec2 ASG instances within the VPC"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule = "http-80-tcp"
      source_security_group_id = module.external_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "https to ELB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  version = "5.0.0"

  name = "${var.env_code}-asg"
  max_size = 5
  min_size = 2
  desired_capacity = 4
  health_check_type = "EC2"
  health_check_grace_period = 400
  vpc_zone_identifier = data.terraform_remote_state.level1.outputs.privatesub_id
  target_group_arns = [module.elb.target_group_arns[0]]
  force_delete = true

  launch_template_name = var.env_code
  launch_template_description = "Launch template for ${var.env_code} ASG"
  update_default_version = true
  launch_template_version = "$Latest"

  image_id = data.aws_ami.amazonlinux.id
  instance_type = "t2.micro"
  key_name = "main"
  security_groups = [module.private_sg.security_group_id]
  user_data = filebase64("user-data.sh")

  create_iam_instance_profile = {
  iam_role_name = var.env.code
  iam_role_path = "/ec2/"
  iam_role_description = "IAM role for Session Manager"
  iam_role_tags = {
    CustomIamRole = "No"
  }
  iam_role_policies = {
    "AmazonSSMManagedInstanceCore" = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
  }
  }
}
