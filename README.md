# Deploy-K8S-Cluster

A production-style High Availability Kubernetes cluster built with:

- kubeadm
- HAProxy
- Keepalived
- containerd
- Cilium CNI
- Helm

This project documents how to deploy a highly available Kubernetes cluster with three control-plane nodes and multiple worker nodes, using a virtual IP (VIP) for the Kubernetes API and load balancing across control planes.

---

## Architecture Overview

This cluster uses:

- **3 control-plane nodes**
- **5 worker nodes**
- **HAProxy** for TCP load balancing on the Kubernetes API
- **Keepalived** for virtual IP failover
- **kubeadm** for cluster bootstrap
- **Cilium** as the CNI
- **Helm** for package management

### Cluster Nodes

| Server | IP address | Role |
|---|---|---|
| master1 | 192.168.1.10 | Control plane |
| master2 | 192.168.1.11 | Control plane |
| master3 | 192.168.1.12 | Control plane |
| worker1 | 192.168.1.113 | Worker |
| worker2 | 192.168.1.114 | Worker |
| worker3 | 192.168.1.115 | Worker |
| worker4 | 192.168.1.116 | Worker |
| worker5 | 192.168.1.117 | Worker |

### Virtual IP

| Component | Value |
|---|---|
| Kubernetes API VIP | 192.168.150.100 |
| HAProxy bind port | 7443 |
| Kubernetes API port | 6443 |

---

## Request Flow

1. Administrator uses `kubectl` against the VIP `192.168.150.100:7443`
2. Keepalived ensures the VIP always exists on the active control-plane node
3. HAProxy forwards API requests to healthy kube-apiserver instances
4. kubeadm manages control-plane bootstrap and node joining
5. Cilium provides pod networking and service connectivity

---

## Project Structure

```text
Deploy-K8S-Cluster/
├── README.md
├── diagrams/
├── prerequisites/
├── haproxy/
├── keepalived/
├── kubeadm/
│   ├── control-plane/
│   └── worker/
├── cilium/
├── helm/
├── troubleshooting/
└── tests/
    └── ha-failover/