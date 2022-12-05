module asg {
    source = "../modules/asg"

    env_code = var.env_code
    vpc_id = data.terraform_remote_state.level1.outputs.vpc_id
    privatesub_id = data.terraform_remote_state.level1.outputs.privatesub_id
    load_balancer_sg = aws_security_group.load_balancer.id
    target_group_arn = aws_alb_target_group.main.id
}
