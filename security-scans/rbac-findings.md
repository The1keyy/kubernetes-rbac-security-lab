# RBAC Security Scan Findings

## Tool

`kubectl-who-can`

The tool was installed using Krew and used to inspect which Kubernetes identities can perform selected API actions.

## Finding 1 — Pod Deletion

Command:

```bash
kubectl who-can delete pods -n security-lab
