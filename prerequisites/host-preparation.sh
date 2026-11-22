# This script prepares a host for Kubernetes lab deployment. 
# It is intended for Ubuntu Server 22.04/24.04-like apt-based hosts, systemd and containerd. 
# For RHEL/Rocky adapt the package preparation; do not run apt scripts on RHEL.

#!/usr/bin/env bash
set -euo pipefail

# Check for root and supported OS.
if [[ "$EUID" -ne 0 ]]; then echo "Run with sudo" >&2; exit 1; fi
if [[ ! -f /etc/os-release ]]; then echo "Missing /etc/os-release" >&2; exit 1; fi
. /etc/os-release
if [[ "${ID:-}" != ubuntu && "${ID_LIKE:-}" != *debian* ]]; then
  echo "This script targets apt-based Linux; got ${ID:-unknown}" >&2; exit 1
fi

# disable active and persistent swap.
swapoff -a
if [[ -f /etc/fstab ]]; then
  cp -n /etc/fstab /etc/fstab.before-kubernetes || true
  sed -i -E '/^[[:space:]]*[^#[:space:]].*[[:space:]]swap[[:space:]]/s/^/# Kubernetes disabled swap: /' /etc/fstab
fi

# Load kernel modules and sysctl settings for Kubernetes networking.
cat > /etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter
# Set sysctl params without reboot
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system >/dev/null
printf 'Host prepared. Confirm time sync, unique hostname and network ACLs.\n'
