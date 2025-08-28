# Prometheus & Grafana Deployment on Kubernetes

This project configures **Prometheus** and **Grafana** to run on a Kubernetes cluster for monitoring and visualization purposes.  
- **Prometheus** collects metrics from Kubernetes components, nodes, and applications.  
- **Grafana** provides customizable dashboards to visualize these metrics in real time.  


---

## Getting Started

Follow these steps to deploy Prometheus and Grafana on your Kubernetes environment.

### 1. Deploy Prometheus
Apply the Prometheus YAML file:
```bash
kubectl apply -f prometheus.yaml
```
### 1. Deploy Grafana
Apply the Grafana YAML file:

```bash
kubectl apply -f grafana.yaml
```
