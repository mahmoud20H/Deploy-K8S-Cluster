#!/usr/bin/env bash
set -euo pipefail
if [[ "$EUID" -ne 0 ]]; then echo "Run with sudo" >&2; exit 1; fi
if ! command -v apt-get >/dev/null; then echo "Ubuntu/Debian apt only" >&2; exit 1; fi
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y containerd
install -d -m 0755 /etc/containerd
if [[ -f /etc/containerd/config.toml ]]; then
  cp -n /etc/containerd/config.toml /etc/containerd/config.toml.before-k8s || true
fi
# Containerd 1.x and 2.x have different plugin sections. Generate from the installed binary.
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
# The CRI plugin must not appear in disabled_plugins. An upstream default usually enables it.
if grep -Eq '^disabled_plugins.*"cri"' /etc/containerd/config.toml; then
  echo 'CRI plugin appears disabled; fix /etc/containerd/config.toml first' >&2; exit 1
fi
if ! grep -q 'SystemdCgroup = true' /etc/containerd/config.toml; then
  echo 'No systemd cgroup runtime option found; validate your containerd version' >&2; exit 1
fi
systemctl enable --now containerd
systemctl restart containerd
systemctl --no-pager status containerd | head -15
containerd --version
