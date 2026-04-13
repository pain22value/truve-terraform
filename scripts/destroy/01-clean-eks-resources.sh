#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

cleanup_argocd_apps() {
  local argocd_ns="argocd"

  log_step "1" "ArgoCD Application / ApplicationSet 정리"
  if ! namespace_exists "${argocd_ns}"; then
    echo "namespace ${argocd_ns} 없음 - 스킵"
    return 0
  fi

  if resource_type_available "applicationsets.argoproj.io"; then
    kubectl get applicationsets.argoproj.io -n "${argocd_ns}" || true
    kubectl delete applicationsets.argoproj.io --all \
      -n "${argocd_ns}" \
      --ignore-not-found=true \
      --wait=true \
      --timeout=180s || true
  else
    echo "applicationsets.argoproj.io 리소스 타입 없음"
  fi

  if resource_type_available "applications.argoproj.io"; then
    kubectl get applications.argoproj.io -n "${argocd_ns}" || true
    kubectl delete applications.argoproj.io --all \
      -n "${argocd_ns}" \
      --ignore-not-found=true \
      --wait=true \
      --timeout=180s || true
  else
    echo "applications.argoproj.io 리소스 타입 없음"
  fi

  sleep 30
}

delete_namespace_resources() {
  local ns="$1"
  local lb_services
  local general_services
  local resource

  log_section "namespace 삭제 시작: ${ns}"

  if ! namespace_exists "${ns}"; then
    echo "namespace 없음: ${ns}"
    echo
    return 0
  fi

  echo "[1] 현재 리소스 확인"
  kubectl get ingress -n "${ns}" || true
  kubectl get svc -n "${ns}" || true
  kubectl get deploy -n "${ns}" || true
  kubectl get statefulset -n "${ns}" || true
  kubectl get daemonset -n "${ns}" || true
  kubectl get pvc -n "${ns}" || true

  log_step "2" "Ingress 삭제"
  kubectl delete ingress --all -n "${ns}" --ignore-not-found=true --timeout=180s || true

  log_step "3" "LoadBalancer Service 삭제"
  lb_services="$(kubectl get svc -n "${ns}" -o json 2>/dev/null \
    | jq -r '.items[] | select(.spec.type == "LoadBalancer") | .metadata.name')"
  if [ -n "${lb_services:-}" ]; then
    for resource in ${lb_services}; do
      kubectl delete svc "${resource}" -n "${ns}" --ignore-not-found=true --timeout=180s || true
    done
  else
    echo "LoadBalancer Service 없음"
  fi

  log_step "4" "일반 Service 삭제"
  general_services="$(kubectl get svc -n "${ns}" -o json 2>/dev/null \
    | jq -r '.items[]
      | select(.spec.type != "LoadBalancer")
      | select(.metadata.name != "kubernetes")
      | .metadata.name')"
  if [ -n "${general_services:-}" ]; then
    for resource in ${general_services}; do
      kubectl delete svc "${resource}" -n "${ns}" --ignore-not-found=true --timeout=120s || true
    done
  else
    echo "일반 Service 없음"
  fi

  log_step "5" "workload 삭제"
  kubectl delete deployment --all -n "${ns}" --ignore-not-found=true --timeout=180s || true
  kubectl delete statefulset --all -n "${ns}" --ignore-not-found=true --timeout=300s || true
  kubectl delete daemonset --all -n "${ns}" --ignore-not-found=true --timeout=180s || true
  kubectl delete job --all -n "${ns}" --ignore-not-found=true --timeout=120s || true
  kubectl delete cronjob --all -n "${ns}" --ignore-not-found=true --timeout=120s || true
  kubectl delete replicaset --all -n "${ns}" --ignore-not-found=true --timeout=120s || true
  kubectl delete pod --all -n "${ns}" --ignore-not-found=true --timeout=180s || true

  log_step "6" "PVC 삭제"
  kubectl delete pvc --all -n "${ns}" --ignore-not-found=true --timeout=300s || true

  log_step "7" "리소스 정리 대기"
  sleep 15

  log_step "8" "namespace 삭제"
  kubectl delete ns "${ns}" --ignore-not-found=true --timeout=180s || true

  log_step "9" "삭제 후 namespace 상태 확인"
  kubectl get ns "${ns}" || true

  echo
}

log_section "[01] EKS 내부 리소스 정리"
cleanup_argocd_apps

log_section "일반 앱 namespace 삭제 시작"
for ns in "${APP_NAMESPACES[@]}"; do
  delete_namespace_resources "${ns}"
done

log_section "상태 저장 / 운영성 namespace 삭제 시작"
for ns in "${STATEFUL_NAMESPACES[@]}"; do
  delete_namespace_resources "${ns}"
done

echo "01-clean-eks-resources.sh 완료"
