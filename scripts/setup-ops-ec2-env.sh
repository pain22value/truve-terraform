#!/usr/bin/env bash
set -euxo pipefail

echo "=== Install AWS CLI v2 ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update

echo "=== Install kubectl ==="
KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
curl -L -o kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "=== Install Helm ==="
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "=== Install Terraform ==="
TERRAFORM_VERSION="1.11.4"
curl -L -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip -q terraform.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/

echo "=== Setup alias ==="
cat <<'EOF' | sudo tee /etc/profile.d/ops-tools.sh
export PATH=$PATH:/usr/local/bin
alias k=kubectl
EOF

echo "=== Done ==="