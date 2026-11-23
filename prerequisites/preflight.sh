# This script checks for common prerequisites on a host before initializing a Kubernetes cluster with kubeadm. It verifies kernel modules, sysctl settings, and the presence of required commands. 
# It is intended to be run as root or with sudo privileges.

#!/usr/bin/env bash
set -euo pipefail
warn=0
check() {
  if "$@" >/dev/null 2>&1; then printf '[OK]   %s\n' "$*";
  else printf '[WARN] %s\n' "$*"; warn=1; fi
}
printf '=== K8s host preflight %s ===\n' "$(date -Is)"
hostnamectl --static 2>/dev/null || hostname
ip -br -4 addr
printf 'Kernel: '; uname -r
check test "$(swapon --noheadings | wc -l)" -eq 0
check test -d /sys/module/overlay
check test -d /sys/module/br_netfilter
check test "$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 0)" = 1
check test "$(sysctl -n net.bridge.bridge-nf-call-iptables 2>/dev/null || echo 0)" = 1
check systemctl is-active --quiet containerd
check command -v kubeadm
check command -v kubelet
check command -v kubectl
check command -v ss
check test "$(timedatectl show -p NTPSynchronized --value 2>/dev/null || echo no)" = yes
printf '\nA successful command presence check does not confirm firewall/VIP/Cilium compatibility.\n'
if [[ "$warn" -eq 1 ]]; then echo 'Review WARN lines before kubeadm init'; exit 1; fi
