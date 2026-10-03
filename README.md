# Kubernetes RBAC Security Lab

**Author:** [The1keyy](https://github.com/The1keyy)  
**Repository:** https://github.com/The1keyy/kubernetes-rbac-security-lab  
**License:** [MIT](LICENSE)

This project demonstrates Kubernetes authentication with X.509 client certificates and authorization with RBAC. I built it on a local Minikube cluster: three users, two namespaces, an Nginx workload, and tests for both allowed and denied access.

The YAML in `manifests/` is what I applied. The screenshots are from that cluster. This is a learning lab, not a production environment.

The project is MIT licensed. You can fork it, reuse it, or use it to study Kubernetes access control.

## Access model

| User | Scope | Allowed | Denied |
| --- | --- | --- | --- |
| `developer` | `security-lab` only | View, create, and delete pods; manage deployments | `production` access; Secrets |
| `auditor` | `security-lab` only | View pods | Create or delete pods; modify deployments; `production` access |
| `security-admin` | Cluster-wide pod reads | View pods in every namespace | Delete pods; Secrets; `cluster-admin` |

Namespaces: `security-lab` (Nginx, 3 replicas) and `production` (used to verify isolation).

![Nginx in security-lab](screenshots/00-nginx-workload-security-lab.png)

## Authentication vs authorization

Kubernetes login and Kubernetes permissions are not the same thing.

1. A client cert identifies the user (`CN=developer`).
2. A Role or ClusterRole lists verbs and resources.
3. A RoleBinding or ClusterRoleBinding attaches that list to the user.

I authenticated `developer` **before** any RoleBinding. Listing pods failed:

```text
Error from server (Forbidden): pods is forbidden: User "developer" cannot list resource "pods" in API group "" in the namespace "security-lab"
```

![Developer is logged in but not allowed to list pods](screenshots/02-developer-forbidden-before-rbac.png)

After I applied the developer Role and RoleBinding, the same user could list the three Nginx pods:

![Developer listing pods after RBAC](screenshots/03-developer-access-after-rbac.png)

Cert used for `developer`:

![CN=developer issued by minikubeCA](screenshots/01-certificate-identity.png)

Keys, CSRs, and kubeconfig are **not** in this repo. Make your own locally.

## Repository layout

```text
manifests/     RBAC YAML (Roles, RoleBindings, ClusterRole, ClusterRoleBinding)
screenshots/   Terminal captures from the lab
diagrams/      Architecture diagram
docs/          Notes on what I tested and what can go wrong
scripts/       Empty on purpose (cert generation stays on your machine)
LICENSE        MIT
```

## Run the lab locally

You need Docker Desktop, Minikube, kubectl, and OpenSSL.

```bash
minikube start
kubectl get nodes
```

Then, on your machine:

1. Create namespaces `security-lab` and `production`.
2. Deploy Nginx in `security-lab` with 3 replicas.
3. Create certs for `developer`, `auditor`, and `security-admin`. Sign them with the Minikube CA. Add kubeconfig contexts. Do not commit keys.
4. Apply RBAC:

```bash
kubectl apply -f manifests/
```

5. Run the `kubectl auth can-i` checks in the [Validation](#validation) section.

There is no cert-generation script in this repository because that step requires the Minikube CA private key.

## The three users

### Developer

Role + RoleBinding in `security-lab`.

- Pods: get, list, watch, create, delete
- Deployments: get, list, watch, create, update, patch, delete

- [manifests/developer-role.yaml](manifests/developer-role.yaml)
- [manifests/developer-rolebinding.yaml](manifests/developer-rolebinding.yaml)

Same user in `production`:

```text
Error from server (Forbidden): pods is forbidden: User "developer" cannot list resource "pods" in API group "" in the namespace "production"
```

![Developer blocked in production](screenshots/06-developer-denied-production.png)

### Auditor

Read-only pods in `security-lab`: get, list, watch.

- [manifests/auditor-role.yaml](manifests/auditor-role.yaml)
- [manifests/auditor-rolebinding.yaml](manifests/auditor-rolebinding.yaml)

Auditor `kubectl get pods` is not captured as a separate screenshot. Allow and deny results for the auditor are in the [can-i matrix](#validation).

### Security admin

ClusterRole `security-admin-readonly` + ClusterRoleBinding. Pods: get, list, watch, everywhere.

- [manifests/security-admin-clusterrole.yaml](manifests/security-admin-clusterrole.yaml)
- [manifests/security-admin-clusterrolebinding.yaml](manifests/security-admin-clusterrolebinding.yaml)

`kubectl get pods -A` worked. `kubectl get pods -n production` returned `No resources found` (allowed, empty namespace), not Forbidden. Delete was denied:

![Security-admin can list pods across namespaces; delete is no](screenshots/07-security-admin-cross-namespace-access.png)

`08-security-admin-delete-denied.png` is the same capture as `07`. Both filenames are kept so the screenshot list stays consistent.

**Role vs ClusterRole:** a Role stays in one namespace. A ClusterRoleBinding can follow the user across namespaces. That is why security-admin can see `production` and developer cannot.

## Validation

I used `kubectl auth can-i`. These are the results I captured:

| User | Check | Result |
| --- | --- | --- |
| developer | list / create / delete pods in `security-lab` | yes |
| developer | get deployments in `security-lab` | yes |
| developer | list pods in `production` | no |
| auditor | list pods in `security-lab` | yes |
| auditor | create / delete pods, get deployments, list pods in `production` | no |
| security-admin | list pods in `security-lab` and `production` | yes |
| security-admin | delete pods in `security-lab` | no |
| security-admin | get secrets in `security-lab` | no |

![can-i results](screenshots/09-rbac-can-i-matrix.png)

Developer Secret access was not in that screenshot. The developer Role does not include `secrets`.

Additional notes: [docs/security-findings.md](docs/security-findings.md), [docs/threat-model.md](docs/threat-model.md), [diagrams/architecture.md](diagrams/architecture.md), [screenshots/README.md](screenshots/README.md).

## Credentials

`.gitignore` excludes:

- `*.key`, `*.csr`, `certificates/`
- `kubeconfig`, `*.kubeconfig`
- `ca.key`, `sa.key`

Signing client certificates with the Minikube CA is appropriate for this local lab. It is not a production PKI design.

## Possible next steps

ServiceAccounts, NetworkPolicies, Pod Security Admission, and automated `can-i` checks are not in this repository yet.

## License

[MIT](LICENSE). Copyright (c) 2026 [The1keyy](https://github.com/The1keyy).

Reuse and sharing are welcome. Do not commit private keys or kubeconfig files.
