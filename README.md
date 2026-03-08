# K3s Infrastructure + CI/CD Deployment Project

This project demonstrates a complete DevOps workflow including:

1.Infrastructure provisioning using Terraform

2.Kubernetes cluster setup using K3s

3.Containerization using Docker

4.CI/CD automation using GitHub Actions

5.Cloud infrastructure on Amazon Web Services

# The pipeline automatically:

* Creates a K3s server

* Builds Docker images

* Pushes images to Docker registry

* Deploys the application into Kubernetes

# Project Structure
.
├── .github
│   └── workflows
│          └── CI-CD.yml
│
├── k3s_infra_create
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── variables.tf
│
├── k3s-manifest
│   ├── deploy.yml
│   ├── ingress.yml
│   └── svc.yml
│
├── Dockerfile
└── index.html

# Prerequisites

Before running this project, install the following tools on your local machine or server.

=> Install Git :(Ubuntu)
sudo apt update
sudo apt install git -y

* Verify installation:
git --version

=> Install Terraform :(Ubuntu)
-- sudo apt update
-- sudo apt install -y gnupg software-properties-common curl
-- curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
-- sudo apt-add-repository "deb https://apt.releases.hashicorp.com $(lsb_release -cs) main"

-- sudo apt update
-- sudo apt install terraform

* Verify installation:
-- terraform --version

=> Install AWS CLI :(Ubuntu)
-- sudo apt install awscli -y

* Verify installation:
-- aws --version

# Configure AWS Access

1.Login to the AWS console in Amazon Web Services.

2.Create an IAM user with permissions:
*EC2 Full Access
*Security Group creation
*S3 access
*DynamoDB access

* After creating the user, obtain: (Access Key, Secret Key)
Run:
-- aws configure

Enter:
AWS Access Key
AWS Secret Key
Region
Output format

* Verify configuration:
-- aws configure list

Ensure both Access Key and Secret Key are configured correctly.

# Clone the Repository

Clone the project:

-- git clone https://github.com/yourusername/k3s_project.git
-- cd k3s_project

* Create K3s Infrastructure

* Go to the Terraform folder:
-- cd k3s_infra_create

* Verify Terraform installation:
-- terraform --version
-- Initialize Terraform

* Run:
-- terraform init

* This will:
1.Initialize Terraform dependencies
2.Configure backend
3.Create state storage in S3
4.Enable state locking using DynamoDB
5.Validate Infrastructure Plan

* Run:
-- terraform plan

* This checks whether the infrastructure configuration is valid.
* Ensure the plan completes without errors.

* Create K3s Server

* Run:
-- terraform apply --auto-approve

* Terraform will create:
1.EC2 instance
2.Security groups
3.K3s installation
4.Docker installation

* After completion, Terraform will output:
1.Public IP
2.Connect to the K3s Server

* Use SSH to connect.
-- ssh -i your-key.pem ubuntu@K3S_PUBLIC_IP

# Verify installations 

* Check K3s:
-- sudo kubectl get nodes

* Check Docker:
-- docker --version

* Setup GitHub New Self-Hosted Runner

* Create a working directory:
-- sudo mkdir K3s_Project
-- cd K3s_Project

* Follow the commands provided by GitHub to install the runner on your K3s server.
* After installation, start the runner.
* Verify status in GitHub.
* Runner status should show: (Idle)
* This means the runner is ready to execute workflows.

# CI/CD Workflow

* Create GitHub Secrets
* Repository Settings → Secrets and Variables → Actions → New Repository Secret

* Create the following three secrets:
DOCKER_USERNAME	-> Your Docker Hub username
DOCKER_PASSWORD	-> Your Docker Hub access token
IMAGE_NAME	-> DockerHub repository and image name (e.g username/k3s-html-app)

* These secrets will be used inside the workflow file.
* GitHub Workflow File (.github/workflows/CI-CD.yml)

# Deployment 

* When a developer pushes code to the repository:
* git push origin main

* The CI/CD pipeline will:
1.Build the Docker image
2.Tag the image using the commit ID
3.Push the image to Docker Hub
4.Update the Kubernetes deployment
5.Deploy Kubernetes Manifests

* Once deployment is complete, open your browser.

==> http://K3S_PUBLIC_IP:80

* You should see the deployed application.

** If the developer updates index.html and pushes new code, the pipeline will automatically **

### Deployment Workflow ###

Developer Push Code
        │
        ▼
GitHub Repository
        │
        ▼
GitHub Actions Pipeline
        │
        ├ Build Docker Image
        ├ Push Image to Docker Hub
        └ Deploy to K3s Cluster
                │
                ▼
Kubernetes Deployment Updated
                │
                ▼
Application Available via Ingress

### Technologies Used ###

Infrastructure Provisioning ---> Terraform

Containerization ---> Docker

Container Orchestration ---> K3s

CI/CD Automation ---> GitHub Actions

Cloud Platform ---> AWS