# ElastiCache 제거 후 파일 삭제 기능이 없는 코드 PR 경로를 위한 빈 출력 stub.
# 이 파일의 이전 Valkey cache·전용 security group·ingress rule은 Terraform state에서 제거된다.
output "elasticache_endpoint" {
  value = null
}
