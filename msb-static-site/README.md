
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
<img width="2379" height="1580" alt="1_94cFpaKKYRNuhCYWYCipsg" src="https://github.com/user-attachments/assets/a5842fcc-4d65-4587-bf23-fab71893c46a" />



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

### 🔥 Deployment Steps

1. Clone the repository:

```bash
git clone https://github.com/muhammedsalihbulut/DevOps.git
```
If you’d like to learn more about the steps and the project, feel free to check out my article on Medium.
https://medium.com/@salihbulut417/jenkins-argocd-pipeline-project-9d8b4238ad8a

---

## 🧠 Learnings & Best Practices

- ✅ GitOps with clean directory structure
- ✅ Declarative Kubernetes YAML files
- ✅ Observability baked into the applications (tracing, metrics, logging)
- ✅ Microservices communication with Ingress Controller (Traefik)
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
