resource "aws_efs_file_system" "media" {
    encrypted = true

    tags = {
      Name = "${local.prefix}-media"
    } 
}

resource "aws_security_group" "efs" {
    name = "${local.prefix}-efs"

    ingress {
        from_port = 2049
        to_port = 2049
        protocol = "tcp"

        security_groups = [
            aws_security_group.ecs_service.id
        ]
    }
}