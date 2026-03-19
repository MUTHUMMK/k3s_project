
resource "aws_security_group" "k3s_sg" {
  name = "k3s-sg"

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
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s_server" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  user_data = <<-EOF
              #!/bin/bash

              sleep 05

              sudo apt update -y
              sudo apt install -y curl docker.io

              sudo systemctl start docker
              sudo systemctl enable docker

              sudo usermod -aG docker ubuntu
              sleep 05
              sudo curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.27.10+k3s1 sh -

              sudo systemctl start k3s
              sudo systemctl enable k3s

              sudo chmod 644 /etc/rancher/k3s/k3s.yaml
              echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /home/ubuntu/.bashrc

              
              export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
              
              
              # Deploy your NGINX SERVER
              sudo kubectl create deployment nginx --image=nginx:trixie-perl --port=80

              # Expose service
              sudo kubectl expose deployment nginx --type=ClusterIP --port=80 --target-port=80 --name=nginx-service

              sudo kubectl apply -f - <<< $'apiVersion: networking.k8s.io/v1\nkind: Ingress\nmetadata:\n  name: nginx-ingress\nspec:\n  rules:\n  - http:\n      paths:\n      - path: /\n        pathType: Prefix\n        backend:\n          service:\n            name: nginx-service\n            port:\n              number: 80'
              
              EOF

  tags = {
    Name = var.server_name
  }
}