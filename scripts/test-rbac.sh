#!/usr/bin/env bash

set -euo pipefail

PASS_COUNT=0
FAIL_COUNT=0

run_test() {
    local identity="$1"
    local verb="$2"
    local resource="$3"
    local namespace="$4"
    local expected="$5"

    actual=$(kubectl auth can-i "$verb" "$resource" \
        -n "$namespace" \
        --as="$identity" || true)

    if [[ "$actual" == "$expected" ]]; then
        result="PASS"
        ((PASS_COUNT+=1))
    else
        result="FAIL"
        ((FAIL_COUNT+=1))
    fi

    printf "%-16s %-10s %-15s %-15s %-10s %-10s %s\n" \
        "$identity" "$verb" "$resource" "$namespace" "$expected" "$actual" "$result"
}

echo "=========================================================================================="
echo " Kubernetes RBAC Automated Authorization Test"
echo "=========================================================================================="
printf "%-16s %-10s %-15s %-15s %-10s %-10s %s\n" \
    "IDENTITY" "VERB" "RESOURCE" "NAMESPACE" "EXPECTED" "ACTUAL" "RESULT"
echo "------------------------------------------------------------------------------------------"

run_test developer list pods security-lab yes
run_test developer create pods security-lab yes
run_test developer delete pods security-lab yes
run_test developer get deployments security-lab yes
run_test developer get secrets security-lab no
run_test developer list pods production no

run_test auditor list pods security-lab yes
run_test auditor create pods security-lab no
run_test auditor delete pods security-lab no
run_test auditor get deployments security-lab no
run_test auditor list pods production no

run_test security-admin list pods security-lab yes
run_test security-admin list pods production yes
run_test security-admin delete pods security-lab no
run_test security-admin get secrets security-lab no

echo "=========================================================================================="
echo "RESULTS"
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "=========================================================================================="

if [[ "$FAIL_COUNT" -eq 0 ]]; then
    echo "ALL RBAC TESTS PASSED"
    exit 0
else
    echo "ONE OR MORE RBAC TESTS FAILED"
    exit 1
fi
