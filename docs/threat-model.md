# Threat model

This model covers authentication, RBAC, namespace isolation, and cluster-scoped access **in this Minikube lab**. It is not a full production cluster threat model (no cloud IAM, etcd encryption, or node compromise scenarios).

Goal: show how overbroad permissions or leaked credentials increase impact, and which lab controls reduce that impact.

## Threat 1 — Overprivileged user

| | |
| --- | --- |
| **Threat** | A Kubernetes user is granted more permissions than the job requires. |
| **Risk** | The user — or anyone using that account — can create, change, or delete resources outside the intended role. |
| **Security control** | Least-privilege RBAC. `developer`, `auditor`, and `security-admin` each have a dedicated Role or ClusterRole. No identity is bound to `cluster-admin`. Secret resources are omitted. |
| **Validation** | `kubectl auth can-i` for each identity. Example: auditor can list pods and cannot create or delete them. |

## Threat 2 — Compromised Kubernetes credentials

| | |
| --- | --- |
| **Threat** | An attacker obtains a user’s private key, client certificate, or kubeconfig. |
| **Risk** | The attacker impersonates that user and inherits every RBAC grant. |
| **Security control** | Keep keys and kubeconfig off Git (see `.gitignore`). Limit developer and auditor access to `security-lab`. Limit security-admin to read-only pods. |
| **Validation** | Local `certificates/` material is gitignored. Developer listing pods in `production` is Forbidden, so a stolen developer credential does not become production write access. |

## Threat 3 — Excessive ClusterRole permissions

| | |
| --- | --- |
| **Threat** | A ClusterRole grants verbs or resources that are not needed cluster-wide (wildcards, Secrets, delete, `cluster-admin`). |
| **Risk** | One binding then applies that power in every namespace. Blast radius is cluster-wide. |
| **Security control** | ClusterRole `security-admin-readonly` allows only `get`, `list`, and `watch` on `pods`. No `*` verbs, no Secrets, no delete. |
| **Validation** | Security-admin can list pods in `security-lab` and `production`, and `kubectl auth can-i delete pods` / `get secrets` are expected `no`. |

## Threat 4 — Cross-namespace lateral movement

| | |
| --- | --- |
| **Threat** | Access in one namespace is reused to reach another (for example `security-lab` → `production`). |
| **Risk** | A compromised developer identity could inspect or change a more sensitive namespace. |
| **Security control** | Developer and auditor use namespace-scoped Roles and RoleBindings in `security-lab` only. There is no developer Role in `production`. |
| **Validation** | Developer can list pods in `security-lab` and receives Forbidden when listing pods in `production`. |

## Threat 5 — RoleBinding misconfiguration

| | |
| --- | --- |
| **Threat** | A RoleBinding points at the wrong User, Role, or namespace. |
| **Risk** | An identity receives a Role meant for someone else (for example auditor bound to `developer-role`). |
| **Security control** | Bindings name a single User (`developer` or `auditor`), a specific Role, and namespace `security-lab`. Manifests are reviewed before apply. |
| **Validation** | Developer and auditor are separate RoleBindings. Auditor cannot use developer verbs (create/delete pods, manage deployments). |

## Threat 6 — ClusterRoleBinding misconfiguration

| | |
| --- | --- |
| **Threat** | A ClusterRoleBinding attaches a powerful ClusterRole to the wrong user, or attaches the right user to `cluster-admin`. |
| **Risk** | Unlike a RoleBinding, the mistake is not confined to one namespace. |
| **Security control** | One ClusterRoleBinding: user `security-admin` → ClusterRole `security-admin-readonly`. No `cluster-admin` binding in this lab. |
| **Validation** | Security-admin has cross-namespace pod reads and is denied pod delete and Secret get. |

## Summary

| Threat | Risk | Security control | Validation method |
| --- | --- | --- | --- |
| Overprivileged users | Actions beyond the job | Least-privilege Roles / ClusterRole | `kubectl auth can-i` allow and deny |
| Compromised credentials | Impersonation of that user | Git exclusion + scoped RBAC | gitignore + Forbidden outside granted scope |
| Excessive ClusterRole permissions | Cluster-wide blast radius | Read-only pods ClusterRole | Cross-namespace list yes; delete/secrets no |
| Cross-namespace movement | Unauthorized environment access | Namespace-scoped RoleBindings | Developer Forbidden in `production` |
| Misconfigured RoleBinding | Wrong user gets a Role | Explicit User, Role, namespace | Separate developer vs auditor tests |
| Misconfigured ClusterRoleBinding | Cluster-wide grant to the wrong identity | Narrow ClusterRole; no `cluster-admin` | Security-admin deny tests |

## Scope note

This lab does not model node compromise, etcd access, stolen Minikube CA keys on the host, or cloud IAM. Those are real risks outside the RBAC objects stored in this repository. The Minikube CA private key on the workstation could mint arbitrary client certificates; that is why CA material must stay local and uncommitted.
