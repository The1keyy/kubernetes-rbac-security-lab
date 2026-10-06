# ServiceAccount Security

## Overview

Kubernetes ServiceAccounts provide identities for workloads running inside a cluster.

Unlike human users such as `developer`, `auditor`, and `security-admin`, the `app-reader` ServiceAccount represents an application or workload identity.

## ServiceAccount

Name:

`app-reader`

Namespace:

`security-lab`

## Permissions

The ServiceAccount is intentionally limited to:

- get pods
- list pods
- watch pods

It cannot:

- create pods
- delete pods
- read Secrets
- access pods in the production namespace
- perform cluster-wide actions

## RBAC Design

The `app-reader-role` Role grants read-only access to pods inside the `security-lab` namespace.

The `app-reader-rolebinding` RoleBinding connects the `app-reader` ServiceAccount to that Role.

Because a namespace-scoped Role and RoleBinding are used, the permissions do not automatically extend into other namespaces.

## Validation

Permissions were validated using:

```bash
kubectl auth can-i list pods \
  -n security-lab \
  --as=system:serviceaccount:security-lab:app-reader

