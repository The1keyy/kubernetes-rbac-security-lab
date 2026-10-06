# RBAC Misconfiguration and Remediation Lab

## Overview

This lab demonstrates how an RBAC misconfiguration can unintentionally expand a Kubernetes workload's permissions.

The `app-reader` ServiceAccount was originally configured with least privilege and could not read Kubernetes Secrets.

## Secure State

Before the misconfiguration:

```bash
kubectl auth can-i get secrets \
  -n security-lab \
  --as=system:serviceaccount:security-lab:app-reader
