# this script installs Kubernetes packages on Debian/Ubuntu systems. It is intended to be run as root or with sudo privileges.

#!/usr/bin/env bash
set -euo pipefail
# Check for root and supported OS.
if [[ "$EUID" -ne 0 ]]; then echo "Run with sudo" >&2; exit 1; fi
: "${K8S_MINOR:=v1.36}"
# Check that K8S_MINOR is a valid Kubernetes minor version string (e.g., v1.36).
if [[ ! "$K8S_MINOR" =~ ^v1\.[0-9]+$ ]]; then
  echo 'Set K8S_MINOR like v1.36' >&2; exit 1
fi
# Check for apt-get command.
if ! command -v apt-get >/dev/null; then echo "apt only" >&2; exit 1; fi
export DEBIAN_FRONTEND=noninteractive

# Install Kubernetes packages from the official Kubernetes apt repository.
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg
install -d -m 0755 /etc/apt/keyrings
key_url="https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key"
curl -fsSL "$key_url" | gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
printf 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/%s/deb/ /\n' "$K8S_MINOR" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
# Hold the installed Kubernetes packages to prevent automatic upgrades that could break the cluster.
apt-mark hold kubelet kubeadm kubectl
# Enable and start the kubelet service, which is responsible for managing pods and containers on the node.
systemctl enable --now kubelet
kubeadm version -o short
printf 'Update kubeadm-init-config.yaml to the patch version matching the installed kubeadm.\n'
