
# AWS EKS Three-Tier Application (Terraform + Kubernetes) Production-grade AWS EKS deployment using Terraform, ALB Ingress, and real-world Kubernetes debugging

![Architecture Diagram](./docs/Three-Tier Cloud-Native Application on AWS EKS)

## Overview
A production-style cloud-native three-tier application deployed on **Amazon EKS**, fully provisioned using **Terraform**, and exposed via **AWS ALB Ingress Controller** with path-based routing.

**Tech Stack**
- AWS EKS, ALB, VPC, IAM
- Terraform (with S3 backend + DynamoDB state locking)
- Kubernetes (Deployments, Services, Ingress)
- React Frontend, Node.js Backend, MongoDB

## 🔥 Key Highlights

- Infrastructure fully provisioned using **Terraform (IaC)**  
- **AWS EKS** with Kubernetes-native deployments and services  
- **Application Load Balancer (ALB) Ingress** with:
  - Path-based routing (`/` → frontend, `/backend` → API)
  - Health checks and target group validation
- **Remote Terraform state** with S3 backend and DynamoDB locking
- Production debugging of:
  - ImagePullBackOff
  - Ingress misconfiguration
  - Deployment rollout failures
  - Target group unhealthy states

## 💡 What This Project Demonstrates

- Real-world AWS + Kubernetes troubleshooting experience
- Ability to design, deploy, and debug cloud-native systems
- Strong understanding of AWS networking and load balancing
- Infrastructure-as-Code discipline using Terraform
- Alignment with AWS Well-Architected best practices

## 🏛 AWS Well-Architected Framework Alignment

- **Operational Excellence**  
  Health checks, rollout monitoring, and structured troubleshooting.

- **Security**  
  IAM roles for ALB controller, Kubernetes secrets for database credentials, least-privilege access.

- **Reliability**  
  ALB health checks, readiness/liveness probes, self-healing Kubernetes deployments.

- **Performance Efficiency**  
  Load-balanced ingress traffic, containerized workloads, scalable EKS architecture.

- **Cost Optimization**  
  Right-sized workloads, ephemeral infrastructure, and teardown after validation.


## Architecture
![Architecture](architecture/aws-well-architected.jpg)

## AWS Well-Architected Principles
**Operational Excellence** – Logging, monitoring, automated rollouts  
**Security** – IAM roles, VPC isolation, least privilege  
**Reliability** – Health checks, ALB, self-healing pods  
**Performance Efficiency** – Autoscaling-ready, ALB routing  
**Cost Optimization** – Right-sized workloads, managed services  

## Setup Instructions
```bash
terraform init
terraform apply
kubectl apply -f k8s_manifests/
```

## Highlights
- ALB path-based routing with rewrite
- Terraform remote state with S3 + DynamoDB
- Real-world debugging: ImagePullBackOff, Ingress routing

## Learning Outcomes
- Deep dive into EKS + ALB integration
- Kubernetes networking & ingress
- Production troubleshooting

| Problem # | Issue Faced                   | Steps Taken to Resolve                              | Final Resolution                |
| --------- | ----------------------------- | --------------------------------------------------- | ------------------------------- |
| 1         | Backend targets unhealthy     | Updated health check path to `/backend`             | Backend target healthy          |
| 2         | Frontend ImagePullBackOff     | Pulled latest Docker image                          | Frontend pod running            |
| 3         | Deployment selector immutable | Deleted old pods                                    | Deployment updated successfully |
| 4         | Ingress path routing          | Configured ALB annotation `actions.backend-rewrite` | `/backend` works as intended    |
| 5         | Port conflicts on dev machine | Stopped local service running on 8080               | Backend accessible              |
