provider "aws" {
  region = "ap-northeast-1"  # 東京リージョン
}

resource "aws_security_group" "private_isu_sg" {
  name        = "private-isu-sg"
  description = "Security group for private-isu servers"

  # ルールはここでは定義しません。インポート後に追加します。

  tags = {
    Name = "private-isu-sg"
  }
}

# 競技者用サーバーのEC2インスタンス
resource "aws_instance" "competition_server" {
  ami           = "ami-047fdc2b851e73cad"  # 競技者用のAMI ID
  instance_type = "c7a.large"
  key_name      = "private-isu-key"  # 既存のキーペア名を指定

  vpc_security_group_ids = [aws_security_group.private_isu_sg.id]

  tags = {
    Name = "private-isu-competition-server"
  }
}

# ベンチマーク用サーバーのEC2インスタンス
resource "aws_instance" "benchmark_server" {
  ami           = "ami-037be39355baf1f2e"  # ベンチマーク用のAMI ID
  instance_type = "c7a.xlarge"
  key_name      = "private-isu-key"  # 既存のキーペア名を指定

  vpc_security_group_ids = [aws_security_group.private_isu_sg.id]

  tags = {
    Name = "private-isu-benchmark-server"
  }
}

# 出力
output "competition_server_public_ip" {
  value = aws_instance.competition_server.public_ip
}

output "benchmark_server_public_ip" {
  value = aws_instance.benchmark_server.public_ip
}

resource "aws_security_group" "private_isu_sg" {
  name        = "private-isu-sg"
  description = "Security group for private-isu servers"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6060
    to_port     = 6060
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1080
    to_port     = 1080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-isu-sg"
  }
}
