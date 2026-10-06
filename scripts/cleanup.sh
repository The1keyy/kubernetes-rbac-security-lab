#!/usr/bin/env bash

set -euo pipefail

echo "=========================================="
echo " Kubernetes RBAC Security Lab Cleanup"
echo "=========================================="
echo

echo "[1/6] Removing NetworkPolicy..."

kubectl delete -f manifests/network-policies/deny-nginx-ingress.yaml \
    --ignore-not-found 2>/dev/null || true

echo
echo "[2/6] Removing ServiceAccount RBAC..."

kubectl delete -f manifests/app-reader-rolebinding.yaml --ignore-not-found
kubectl delete -f manifests/app-reader-role.yaml --ignore-not-found
kubectl delete -f manifests/app-reader-serviceaccount.yaml --ignore-not-found

echo
echo "[3/6] Removing human-user RBAC..."

kubectl delete -f manifests/developer-rolebinding.yaml --ignore-not-found
kubectl delete -f manifests/developer-role.yaml --ignore-not-found

kubectl delete -f manifests/auditor-rolebinding.yaml --ignore-not-found
kubectl delete -f manifests/auditor-role.yaml --ignore-not-found

kubectl delete -f manifests/security-admin-clusterrolebinding.yaml --ignore-not-found
kubectl delete -f manifests/security-admin-clusterrole.yaml --ignore-not-found

echo
echo "[4/6] Removing Nginx workload..."

kubectl delete -f manifests/nginx-deployment.yaml --ignore-not-found

echo
echo "[5/6] Removing lab namespaces..."

kubectl delete -f manifests/namespaces.yaml --ignore-not-found

echo
echo "[6/6] Cleanup summary..."

echo "Lab resources removed."
echo "Minikube was NOT deleted."
echo "Audit configuration files were NOT deleted."
echo "Local project files were NOT deleted."
echo
echo "Recreate the lab with:"
echo "./scripts/setup.sh"

echo
echo "=========================================="
echo " CLEANUP COMPLETE"
echo "=========================================="
