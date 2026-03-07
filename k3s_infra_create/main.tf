
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
    from_port   = 8080
    to_port     = 8080
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
              
              # Install Helm
              curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
              
              helm version
              
              helm repo add argo https://argoproj.github.io/argo-helm
              helm repo update
              
              kubectl create namespace argocd || true
              
              helm install argocd argo/argo-cd --namespace argocd --version 7.7.0 --wait
              
              sudo kubectl apply -f - <<< $'apiVersion: v1\nkind: Service\nmetadata:\n  name: argocd-server-nodeport\n  namespace: argocd\nspec:\n  type: NodePort\n  selector:\n    app.kubernetes.io/name: argocd-server\n  ports:\n  - name: http\n    port: 80\n    targetPort: 8080\n    nodePort: 30080\n  - name: https\n    port: 443\n    targetPort: 8080\n    nodePort: 30443'
              
              
              # Deploy your container
              sudo kubectl run nginx-5785977ddb-r9lmz --image=muthummkdh/muthu26:7bb0fb5 --port=80
              
              # Expose service
              sudo kubectl expose pod nginx-5785977ddb-r9lmz --type=NodePort --port=80 --target-port=80
              
              sudo kubectl apply -f - <<< $'apiVersion: networking.k8s.io/v1\nkind: Ingress\nmetadata:\n  name: nginx-ingress\nspec:\n  rules:\n  - http:\n      paths:\n      - path: /\n        pathType: Prefix\n        backend:\n          service:\n            name: nginx-5785977ddb-r9lmz\n            port:\n              number: 80'
              
              EOF

  tags = {
    Name = var.server_name
  }
}