# Kubernetes RBAC Security Lab

**Author:** [The1keyy](https://github.com/The1keyy)  
**Repo:** https://github.com/The1keyy/kubernetes-rbac-security-lab

I built this lab. The RBAC YAML, kubeconfig contexts, tests, and screenshots come from my local Minikube cluster. It is not a copy of someone else's project. You can fork it and learn from it under [MIT](LICENSE). Keep the copyright. Do not submit it as your own coursework or portfolio.

Local Minikube project for learning how Kubernetes decides **who you are** (X.509 certificates) versus **what you can do** (RBAC).

I set up three users, two namespaces, and an Nginx app, then tested both the permissions that worked and the ones that got Forbidden. The YAML in `manifests/` is what I applied. Screenshots are from that cluster.

This is a learning lab, not a production cluster.

## Who this is for

- People learning Kubernetes security
- Anyone who wants a small example of Role vs ClusterRole
- Recruiters or reviewers who want the short version: three users, least privilege, namespace isolation, `kubectl auth can-i`

If you only have two minutes, read the table below and look at the screenshots.

## What I built

| User | Where | Can do | Cannot do |
| --- | --- | --- | --- |
| `developer` | `security-lab` only | View / create / delete pods; manage deployments | Access `production`; read Secrets |
| `auditor` | `security-lab` only | View pods | Create/delete pods; touch deployments; access `production` |
| `security-admin` | Cluster-wide (pods) | View pods in every namespace | Delete pods; read Secrets; `cluster-admin` |

Namespaces: `security-lab` (Nginx, 3 replicas) and `production` (used to show isolation).

![Nginx in security-lab](screenshots/00-nginx-workload-security-lab.png)

## How access works

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

## Layout

```text
manifests/     RBAC YAML (Roles, RoleBindings, ClusterRole, ClusterRoleBinding)
screenshots/   Terminal captures from the lab
diagrams/      Architecture diagram
docs/          Notes on what I tested and what can go wrong
scripts/       Empty on purpose (cert generation stays on your machine)
LICENSE        MIT — reuse and learn from this
```

## Try it yourself

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

5. Run the `kubectl auth can-i` checks in the [Tests](#tests) section.

I am not publishing a cert-generation script because it needs the Minikube CA private key.

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

I did not take a separate auditor `kubectl get pods` screenshot. Auditor yes/no results are in the [can-i matrix](#tests).

### Security admin

ClusterRole `security-admin-readonly` + ClusterRoleBinding. Pods: get, list, watch, everywhere.

- [manifests/security-admin-clusterrole.yaml](manifests/security-admin-clusterrole.yaml)
- [manifests/security-admin-clusterrolebinding.yaml](manifests/security-admin-clusterrolebinding.yaml)

`kubectl get pods -A` worked. `kubectl get pods -n production` returned `No resources found` (allowed, empty namespace), not Forbidden. Delete was denied:

![Security-admin can list pods across namespaces; delete is no](screenshots/07-security-admin-cross-namespace-access.png)

`08-security-admin-delete-denied.png` is the same screenshot. I kept both names so the list of captures stays easy to follow.

**Role vs ClusterRole:** a Role stays in one namespace. A ClusterRoleBinding can follow the user across namespaces. That is why security-admin can see `production` and developer cannot.

## Tests

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

More write-up: [docs/security-findings.md](docs/security-findings.md) and [docs/threat-model.md](docs/threat-model.md). Diagram: [diagrams/architecture.md](diagrams/architecture.md). Screenshot list: [screenshots/README.md](screenshots/README.md).

## Do not commit

`.gitignore` already ignores:

- `*.key`, `*.csr`, `certificates/`
- `kubeconfig`, `*.kubeconfig`
- `ca.key`, `sa.key`

Signing users with the Minikube CA is fine for this laptop lab. Do not treat that as how production should issue certs.

## What I would add next

ServiceAccounts, NetworkPolicies, Pod Security Admission, and a small script that runs the `can-i` checks. Not in this repo yet.

## License

[MIT](LICENSE). Copyright (c) 2026 [The1keyy](https://github.com/The1keyy).

Use it for class or practice. Keep the copyright notice. Do not commit private keys. Do not copy this repo and claim you wrote it.
