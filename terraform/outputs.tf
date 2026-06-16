output "ecr_url" {
  value = aws_ecr_repository.runner.repository_url
}

output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}