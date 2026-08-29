# dev 전용 ElastiCache: 생성이 빠르고 최소 과금인 Valkey serverless cache를 사용한다.
# 앱 연결(환경변수 주입·클라이언트 구성)은 이 리소스 생성 범위에 포함하지 않는다.
locals {
  elasticache_enabled = local.enabled * (var.environment == "dev" ? 1 : 0)
}

resource "aws_security_group" "elasticache" {
  count       = local.elasticache_enabled
  name        = "${local.name}-elasticache"
  description = "Valkey ingress from app EC2 only"
  vpc_id      = data.aws_vpc.foundation.id
  tags        = { Name = "${local.name}-elasticache" }
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_from_ec2" {
  count                        = local.elasticache_enabled
  security_group_id            = aws_security_group.elasticache[0].id
  referenced_security_group_id = aws_security_group.ec2[0].id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  description                  = "Valkey from app EC2"
}

resource "aws_elasticache_serverless_cache" "this" {
  count                = local.elasticache_enabled
  name                 = "${local.name}-cache"
  engine               = "valkey"
  major_engine_version = "7"
  subnet_ids           = aws_subnet.private[*].id
  security_group_ids   = [aws_security_group.elasticache[0].id]

  cache_usage_limits {
    data_storage {
      maximum = 1
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 1000
      minimum = 1000
    }
  }

  tags = { Name = "${local.name}-cache" }
}

output "elasticache_endpoint" {
  value = try(aws_elasticache_serverless_cache.this[0].endpoint[0].address, null)
}
