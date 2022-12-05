output load_balancer_sg {
  value = aws_security_group.load_balancer.id
}

output target_group_arn {
  value = aws_alb_target_group.main.id
}
