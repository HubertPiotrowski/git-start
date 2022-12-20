data "aws_route53_zone" "main" {
  name = "www.hubertgroup.click"
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"
  version = "3.5.0"

  domain_name = "www.hubertgroup.click"
  zone_id     = data.aws_route53_zone.main.zone_id

  wait_for_validation = true

}


module "external_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name   = "${var.env_code}-external"
  vpc_id = data.terraform_remote_state.level1.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https to ELB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

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

module "elb" {
  source = "terraform-aws-modules/alb/aws"
  version = "7.0.0"
  
  name = "${var.env_code}-elb"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.level1.outputs.vpc_id
  internal        = false
  subnets         = data.terraform_remote_state.level1.outputs.privatesub_id
  security_groups = [module.external_sg.security_group_id]

  target_groups = [
    {
      name_prefix          = "${var.env_code}-tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.this_acm_certificate_arn
      default_action = {
        type             = "forward"
        target_group_arn = module.elb.this_lb_target_group_arns[0]
      }
    }
  ]
}

module "dns" {
  source = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.10.1"

  zone_id = data.aws_route53_zone.main.zone_id

  records = [
    {
      name    = "www"
      type    = "CNAME"
      ttl     = 3600
      records = [module.elb.lb_dns_name]
    }
  ]
}
