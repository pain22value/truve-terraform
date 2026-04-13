#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

log_section "[03] namespace finalizer 정리"

for ns in "${FINALIZER_NAMESPACES[@]}"; do
  log_step "finalizer" "${ns}"

  if namespace_exists "${ns}"; then
    kubectl get namespace "${ns}" -o json \
      | jq '.spec.finalizers = []' \
      | kubectl replace --raw "/api/v1/namespaces/${ns}/finalize" -f - || true

    kubectl delete ns "${ns}" --ignore-not-found=true --timeout=60s || true
    wait_for_namespace_deletion "${ns}" 6 5 || true
  else
    echo "namespace 없음: ${ns}"
  fi

  echo
done

echo "03-clean-finalizers.sh 완료"
