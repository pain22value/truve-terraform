#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

log_section "[00] destroy 실행 환경 확인"

log_step "1/9" "필수 명령어 확인"
require_command kubectl
require_command jq
require_command terraform
require_command aws

log_step "2/9" "AWS 자격 증명 확인"
aws sts get-caller-identity

log_step "3/9" "Terraform 환경 디렉터리 확인"
ensure_directory "${PLATFORM_DIR}"
ensure_directory "${INFRA_DIR}"

log_step "4/9" "kubectl context 확인"
kubectl config current-context

log_step "5/9" "cluster 연결 확인"
kubectl cluster-info

log_step "6/9" "kubectl 권한 확인"
kubectl auth can-i '*' '*' --all-namespaces || true

log_step "7/9" "현재 namespace 확인"
kubectl get ns

log_step "8/9" "현재 node / ingress / LoadBalancer service / pvc 확인"
kubectl get nodes -o wide || true
kubectl get ingress -A || true
kubectl get svc -A || true
kubectl get pvc -A || true

log_step "9/9" "Karpenter 관련 리소스 확인"
if resource_type_available "nodepools.karpenter.sh"; then
  kubectl get nodepools.karpenter.sh || true
else
  echo "nodepools.karpenter.sh 없음"
fi

if resource_type_available "ec2nodeclasses.karpenter.k8s.aws"; then
  kubectl get ec2nodeclasses.karpenter.k8s.aws || true
else
  echo "ec2nodeclasses.karpenter.k8s.aws 없음"
fi

echo
echo "사전 확인 완료"
