echo "=== Install base packages ==="
sudo dnf update -y
sudo dnf install -y \
  unzip \
  tar \
  gzip \
  git \
  jq \
  wget \
  curl \
  mysql \
  bash-completion