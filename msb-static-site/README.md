
# DevOps-Lab

A comprehensive DevOps and Kubernetes learning lab designed for modern cloud-native applications. This repository contains infrastructure components, observability tools, messaging systems, storage solutions, and real-world application examples — all ready to deploy on Kubernetes.

---

## 📌 Purpose

This repository serves as a hands-on guide for learning and building production-grade Kubernetes environments. It enables developers, DevOps engineers, and SREs to:

- Deploy microservices with proper observability
- Configure secure, reliable messaging systems
- Manage storage solutions for cloud-native apps
- Implement monitoring, tracing, and logging
- Apply GitOps and Infrastructure-as-Code best practices

---

## 🏗️ Repository Structure

```
## Master1
/data
├─ my-k8s-deployments/            
│   ├─ apps/ …                    
│   ├─ infra/ …                   
│   └─ README.md
├─ msb-static-site/               
│   ├─ Dockerfile
│   └─ site/
│      ├─ index.html
│      └─ assets/ …
├─ jenkins/                       
│   ├─ Dockerfile
│   └─ jenkins-entrypoint.sh
├─ jenkins-bin/                   
└─ (ops.) charts/                 

## Worker1

/data
├─ my-k8s-deployments/            
│   ├─ apps/ …                    
│   ├─ infra/ …                   
│   └─ README.md
├─ msb-static-site/               
│   ├─ Dockerfile
│   └─ site/
│      ├─ index.html
│      └─ assets/ …
├─ jenkins/                       
│   ├─ Dockerfile
│   └─ jenkins-entrypoint.sh
├─ jenkins-bin/                   
└─ (ops.) charts/                 

```

---

## 🗺️ High-Level Architecture

```


                                       │    Clients/Users   │
                                       └──────────┬─────────┘
                                                  │  HTTP
                                   ┌──────────────▼──────────────┐
                                   │  Ingress / NodePort Service │
                                   │  (nginx-static-site svc)    │
                                   └──────────────┬──────────────┘
                                                  │
                                 ┌────────────────▼────────────────┐
                                 │  Application Layer (namespace:  │
                                 │  default)                        │
                                 │  ─ Pod: nginx-static-site        │
                                 │     Image: msbblttt/nginx…:N     │
                                 │     Volumes: (none; image-based) │
                                 └────────────────┬─────────────────┘
                                                  │
                    ┌─────────────────────────────▼─────────────────────────────┐
                    │                    CI / CD Pipeline                       │
                    │                                                           │
                    │  ┌────────────────────────┐     ┌──────────────────────┐  │
  Git push (main) ──┼──►  GitHub (Repo: IaC &   │     │ GitHub Webhook       │  │
                    │  │  App sources/manifests)│────►│ http://JENKINS:8080/ │  │
                    │  └────────────────────────┘     │ github-webhook/      │  │
                    │                                 └───────────┬──────────┘  │
                    │                                             │ triggers    │
                    │  ┌──────────────────────────────────────────▼───────────┐ │
                    │  │ Jenkins (ns: jenkins, Pod: jenkins)                  │ │
                    │  │  - Pipeline stages:                                  │ │
                    │  │    1) Checkout (Git)                                 │ │
                    │  │    2) Build image (docker/nerdctl)                   │ │
                    │  │    3) Push image → Docker Hub                        │ │
                    │  │    4) Bump manifest (image tag or msb-cd-trigger)    │ │
                    │  │       & git commit/push                              │ │
                    │  │  - Secrets: GITHUB_TOKEN, DOCKERHUB_TOKEN            │ │
                    │  └───────────────┬──────────────────────────────────────┘ │
                    │                  │ updates manifests                      │
                    │  ┌───────────────▼──────────────────────────────────────┐ │
                    │  │ GitHub (Manifests branch/main)                       │ │
                    │  └───────────────┬──────────────────────────────────────┘ │
                    │                  │ watched by                             │
                    │  ┌───────────────▼──────────────────────────────────────┐ │
                    │  │ Argo CD (ns: argocd)                                 │ │
                    │  │  - repo-server, controller, server                   │ │
                    │  │  - App: nginx-static-site                            │ │
                    │  │  - Sync policy: Auto (optional), Prune/Replace opt.  │ │
                    │  └───────────────┬──────────────────────────────────────┘ │
                    │                  │ applies to cluster                     │
                    └──────────────────▼────────────────────────────────────────┘
                                                  │
                                ┌─────────────────▼───────────────────┐
                                │   Kubernetes Cluster (kube-system)  │
                                │   Nodes:                            │
                                │    - master1 (control-plane)        │
                                │    - worker1 (workloads: Jenkins,   │
                                │      nginx-static-site, monitoring) │
                                └─────────────────┬───────────────────┘
                                                  │
                       ┌──────────────────────────▼──────────────────────────┐
                       │    Monitoring & Observability (namespace:           │
                       │    monitoring)                                      │
                       │    - Prometheus (scrape: kube-state-metrics,        │
                       │      node-exporter, cAdvisor/kubelet, app endpoints)│
                       │    - Grafana (Dashboards; datasource=Prometheus)    │
                       │    - Optional: Alertmanager                         │
                       └─────────────────────────────────────────────────────┘

                       Optional/Artifacts:
                       - MinIO (ns: default or minio) for S3-like storage (e.g.,
                         build çıktıları, statik dosya arşivi, yedekler).
```

> ✅ **All components communicate securely via Kubernetes internal networking.**

---

## 🚀 Getting Started

### ✅ Prerequisites

- Kubernetes cluster is installed and running (e.g., minikube, kind, k3s, or production-grade cluster).

- **If you are running outside a cloud environment (e.g., on-premises or local VM):**

- `kubectl` CLI installed and configured to access your cluster.

- Optional but recommended: `helm` installed for easier package management.

  - Deploy **MetalLB** to provide LoadBalancer IPs in your cluster:
    ```bash
    kubectl apply -f infrastructure/core/metallb/
    ```

  - Deploy **Traefik** as your Ingress Controller to manage incoming traffic:
    ```bash
    kubectl apply -f infrastructure/core/traefik/
    ```

  - To access services routed by Traefik from your local machine, you need to update your OS's `hosts` file:

    1. Find the external IP assigned to Traefik LoadBalancer service:
       ```bash
       kubectl get svc -n traefik
       ```

    2. Edit the hosts file on your local machine:

       - **Windows:**  
         Edit `C:\Windows\System32\drivers\etc\hosts` as Administrator.

       - **Linux/macOS:**  
         Edit `/etc/hosts` with root privileges (e.g., `sudo nano /etc/hosts`).

    3. Add an entry like:
       ```
       <Traefik_LoadBalancer_IP>  your-service-hostname.local
       ```

    4. Save the file. Now you can access your services in the browser using `http://your-service-hostname.local`.


### 🔥 Deployment Steps

1. Clone the repository:

```bash
git clone https://github.com/ozancakar/DevOps-Lab.git
cd DevOps-Lab
```

2. Apply the core infrastructure:

```bash
kubectl apply -f infrastructure/core/
```

3. Deploy observability stack:

```bash
kubectl apply -f infrastructure/observability/
```

4. Deploy messaging systems:

```bash
kubectl apply -f infrastructure/messaging/
```

5. Deploy storage:

```bash
kubectl apply -f infrastructure/storage/
```

6. Deploy your applications:

```bash
kubectl apply -f applications/observability-demos/dotnet-otel-complete/k8s/
```

---

## 🧠 Learnings & Best Practices

- ✅ GitOps with clean directory structure
- ✅ Declarative Kubernetes YAML files
- ✅ Observability baked into the applications (tracing, metrics, logging)
- ✅ Microservices communication with Ingress Controller (Traefik)
- ✅ Secure and scalable message brokers (RabbitMQ, Redis Sentinel)
- ✅ Local or cloud-native storage with MinIO

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

---

---

> ✨ If you find this repository useful, give it a ⭐ star and share it!
