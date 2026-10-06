#!/usr/bin/env bash

set -euo pipefail

echo "=========================================="
echo " Kubernetes RBAC Security Lab Setup"
echo "=========================================="
echo

echo "[1/8] Checking required tools..."

REQUIRED_TOOLS=("docker" "minikube" "kubectl" "openssl")

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: $tool is not installed or not in PATH."
        exit 1
    fi

    echo "  [OK] $tool"
done

echo
echo "[2/8] Checking Minikube cluster..."

if minikube status >/dev/null 2>&1; then
    echo "  [OK] Minikube is already running."
else
    echo "  Minikube is not running. Starting Minikube..."
    minikube start --driver=docker --cni=calico
fi

echo
echo "[3/8] Applying namespaces..."

kubectl apply -f manifests/namespaces.yaml

echo
echo "[4/8] Applying Nginx workload..."

kubectl apply -f manifests/nginx-deployment.yaml

echo
echo "[5/8] Applying human-user RBAC..."

kubectl apply -f manifests/developer-role.yaml
kubectl apply -f manifests/developer-rolebinding.yaml
kubectl apply -f manifests/auditor-role.yaml
kubectl apply -f manifests/auditor-rolebinding.yaml
kubectl apply -f manifests/security-admin-clusterrole.yaml
kubectl apply -f manifests/security-admin-clusterrolebinding.yaml

echo
echo "[6/8] Applying ServiceAccount security..."

kubectl apply -f manifests/app-reader-serviceaccount.yaml
kubectl apply -f manifests/app-reader-role.yaml
kubectl apply -f manifests/app-reader-rolebinding.yaml

echo
echo "[7/8] Applying security controls..."

kubectl label namespace security-lab \
    pod-security.kubernetes.io/enforce=baseline \
    --overwrite

if [[ -f manifests/network-policies/deny-nginx-ingress.yaml ]]; then
    kubectl apply -f manifests/network-policies/deny-nginx-ingress.yaml
fi

echo
echo "[8/8] Waiting for Nginx rollout..."

kubectl rollout status deployment/nginx \
    -n security-lab \
    --timeout=120s

echo
echo "=========================================="
echo " SETUP COMPLETE"
echo "=========================================="

echo
echo "Namespaces:"
kubectl get namespaces security-lab production

echo
echo "Nginx workload:"
kubectl get deployment nginx -n security-lab

echo
echo "Human RBAC:"
kubectl get role,rolebinding -n security-lab
kubectl get clusterrole security-admin-readonly

echo
echo "ServiceAccount:"
kubectl get serviceaccount app-reader -n security-lab

echo
echo "ServiceAccount permissions:"
echo -n "  List pods: "
kubectl auth can-i list pods \
    -n security-lab \
    --as=system:serviceaccount:security-lab:app-reader

echo -n "  Read secrets: "
kubectl auth can-i get secrets \
    -n security-lab \
    --as=system:serviceaccount:security-lab:app-reader

echo
echo "Pod Security:"
kubectl get namespace security-lab \
    -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}{"\n"}'

echo
echo "Network Policies:"
kubectl get networkpolicy -n security-lab 2>/dev/null || true

echo
echo "=========================================="
echo " Lab environment is ready."
echo "=========================================="
