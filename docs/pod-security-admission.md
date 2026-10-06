# Pod Security Admission

## Overview

This lab demonstrates Kubernetes Pod Security Admission using the `baseline` security standard.

Pod Security Admission helps prevent workloads with unsafe security settings from being created.

## Policy

The `security-lab` namespace was configured with:

```bash
kubectl label namespace security-lab \
  pod-security.kubernetes.io/enforce=baseline \
  --overwrite

