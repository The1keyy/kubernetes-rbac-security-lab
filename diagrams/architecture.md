# Architecture

Minikube. Two namespaces. Three cert users. Nginx with 3 pods in `security-lab`.

```mermaid
flowchart TD
    D[Developer]
    A[Auditor]
    S[Security Admin]

    AUTH[X.509 Authentication]

    D --> AUTH
    A --> AUTH
    S --> AUTH

    AUTH --> DRB[RoleBinding]
    AUTH --> ARB[RoleBinding]
    AUTH --> CRB[ClusterRoleBinding]

    DRB --> DR[Developer Role]
    ARB --> AR[Auditor Role]
    CRB --> CR[Read-Only ClusterRole]

    DR --> SL[security-lab]
    AR --> SL
    CR --> SL
    CR --> PR[production]

    SL --> NGINX[Nginx Deployment]
    NGINX --> PODS[3 Pods]

    PR --> DENY[Developer denied]
    PR --> RO[Security Admin read-only pod visibility]
```

| User | Binding | Role | Reach |
| --- | --- | --- | --- |
| Developer | RoleBinding | Developer Role | `security-lab`: pods get/list/watch/create/delete, deployments get/list/watch/create/update/patch/delete |
| Auditor | RoleBinding | Auditor Role | `security-lab`: pods get/list/watch |
| Security Admin | ClusterRoleBinding | Read-only ClusterRole | Pods get/list/watch in all namespaces |

`production` has no developer or auditor Role. Security-admin can still list pods there because of the ClusterRoleBinding. No Secrets. No `cluster-admin`.
