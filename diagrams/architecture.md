# Kubernetes RBAC Security Lab Architecture

```mermaid
flowchart TD

    U1[Developer]
    U2[Auditor]
    U3[Security Admin]

    CERT[X.509 Certificate Authentication]

    NS1[security-lab Namespace]
    NS2[production Namespace]

    RB1[Developer RoleBinding]
    RB2[Auditor RoleBinding]
    CRB[ClusterRoleBinding]

    R1[Developer Role]
    R2[Auditor Role]
    CR[Security Admin Read-Only ClusterRole]

    APP[Nginx Deployment - 3 Pods]

    U1 --> CERT
    U2 --> CERT
    U3 --> CERT

    U1 --> RB1
    RB1 --> R1
    R1 --> NS1

    U2 --> RB2
    RB2 --> R2
    R2 --> NS1

    U3 --> CRB
    CRB --> CR
    CR --> NS1
    CR --> NS2

    NS1 --> APP
