#!/usr/bin/env bash
set -euo pipefail

APP_NAMESPACES=(
  truve-auth-service
  truve-gateway-service
  truve-musical-service
  truve-payment-service
  truve-queue-service
  truve-ticketing-service
)

STATEFUL_NAMESPACES=(
  truve-kafka
  truve-redis
  kubecost
  observability
  istio-system
  external-secrets
)

delete_namespace_resources() {
  local ns="$1"

  echo "=================================================="
  echo "namespace 삭제 시작: ${ns}"
  echo "=================================================="

  if ! kubectl get ns "${ns}" >/dev/null 2>&1; then
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

  echo
  echo "[2] Ingress 삭제"
  kubectl delete ingress --all -n "${ns}" --timeout=180s || true

  echo
  echo "[3] LoadBalancer Service 삭제"
  LB_SERVICES=$(kubectl get svc -n "${ns}" --no-headers 2>/dev/null | awk '$3=="LoadBalancer" {print $1}')
  if [ -n "${LB_SERVICES:-}" ]; then
    for svc in ${LB_SERVICES}; do
      kubectl delete svc "${svc}" -n "${ns}" --timeout=180s || true
    done
  else
    echo "LoadBalancer Service 없음"
  fi

  echo
  echo "[4] 일반 Service 삭제"
  CLUSTERIP_SERVICES=$(kubectl get svc -n "${ns}" --no-headers 2>/dev/null | awk '$3!="LoadBalancer" && $1!="kubernetes" {print $1}')
  if [ -n "${CLUSTERIP_SERVICES:-}" ]; then
    for svc in ${CLUSTERIP_SERVICES}; do
      kubectl delete svc "${svc}" -n "${ns}" --timeout=120s || true
    done
  else
    echo "일반 Service 없음"
  fi

  echo
  echo "[5] workload 삭제"
  kubectl delete deployment --all -n "${ns}" --timeout=180s || true
  kubectl delete statefulset --all -n "${ns}" --timeout=300s || true
  kubectl delete daemonset --all -n "${ns}" --timeout=180s || true
  kubectl delete job --all -n "${ns}" --timeout=120s || true
  kubectl delete cronjob --all -n "${ns}" --timeout=120s || true
  kubectl delete replicaset --all -n "${ns}" --timeout=120s || true
  kubectl delete pod --all -n "${ns}" --timeout=180s || true

  echo
  echo "[6] PVC 삭제"
  kubectl delete pvc --all -n "${ns}" --timeout=300s || true

  echo
  echo "[7] 리소스 정리 대기"
  sleep 15

  echo
  echo "[8] namespace 삭제"
  kubectl delete ns "${ns}" --timeout=180s || true

  echo
  echo "[9] 삭제 후 namespace 상태 확인"
  kubectl get ns "${ns}" || true

  echo
}

echo "=================================================="
echo "일반 앱 namespace 삭제 시작"
echo "=================================================="
for ns in "${APP_NAMESPACES[@]}"; do
  delete_namespace_resources "${ns}"
done

echo "=================================================="
echo "상태 저장 / 운영성 namespace 삭제 시작"
echo "=================================================="
for ns in "${STATEFUL_NAMESPACES[@]}"; do
  delete_namespace_resources "${ns}"
done

echo "02-delete-app-namespaces.sh 완료"