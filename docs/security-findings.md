# Security findings

Observations from building and testing this Minikube RBAC lab. Each finding matches something the manifests or documented tests actually demonstrate. Nothing here is inferred from a production cluster.

## Finding 1 — Authentication does not equal authorization

The `developer` identity authenticated with an X.509 client certificate. Before RBAC was applied, listing pods in `security-lab` returned Forbidden:

```text
User "developer" cannot list resource "pods"
in the namespace "security-lab"
```

A valid certificate answers *who the user is*. It does not grant API access. Access starts only after a RoleBinding (or ClusterRoleBinding) exists.

## Finding 2 — Developer permissions are namespace-scoped

`developer-role` and `developer-rolebinding` are namespaced to `security-lab`. The developer can use the granted pod and deployment verbs there. The same user is Forbidden for equivalent pod listing in `production`.

Namespace-scoped RBAC contains blast radius: a stolen developer kubeconfig does not automatically become production access.

## Finding 3 — Auditor follows least privilege

`auditor-role` allows only `get`, `list`, and `watch` on pods in `security-lab`. Create pod, delete pod, and deployment access are not in the Role.

The auditor can inspect workloads in that namespace and cannot change or delete them through these RBAC rules.

## Finding 4 — Secrets remain restricted

None of the Roles or the ClusterRole list `secrets` as a resource. Developer, auditor, and security-admin are therefore not granted Secret get/list by these manifests.

The documented `kubectl auth can-i get secrets` checks are expected to return `no` for developer and security-admin. Restricting Secrets reduces the chance that a stolen user context can read credentials stored in the API.

## Finding 5 — Cluster-scoped access increases blast radius

`security-admin` is bound with a ClusterRoleBinding to `security-admin-readonly`. That grant is only pod `get`/`list`/`watch`, but it applies across namespaces, including `production`.

Read-only cluster scope is still broader than a namespace Role. A ClusterRole that accidentally included `delete` or `secrets` would apply everywhere the binding reaches. This identity is not `cluster-admin` and cannot delete pods under these rules.

## Finding 6 — RoleBindings determine who receives Roles

Creating `developer-role` did not authorize the developer by itself. Authorization appeared after `developer-rolebinding` attached User `developer` to that Role in `security-lab`.

If the subject name or `roleRef` is wrong, a different user inherits the Role. Review the binding as carefully as the rule list.

## Finding 7 — ClusterRoleBindings require additional caution

`security-admin` received cross-namespace pod visibility only after `security-admin-readonly-binding` attached the user to the ClusterRole.

A mistaken ClusterRoleBinding is not limited to one namespace. In this lab the binding is narrow (pods, read verbs, named user). That pattern should stay the exception, not the default.

## Finding 8 — Authorization should be explicitly tested

Manifests applying successfully does not prove the permission model. This lab uses `kubectl auth can-i` for expected allows and expected denies, including:

| Identity | Check | Expected |
| --- | --- | --- |
| Developer | list pods in `security-lab` | yes |
| Developer | delete pods in `security-lab` | yes |
| Developer | get secrets in `security-lab` | no |
| Developer | list pods in `production` | no |
| Auditor | list pods in `security-lab` | yes |
| Auditor | create pods in `security-lab` | no |
| Auditor | delete pods in `security-lab` | no |
| Security Admin | list pods across namespaces | yes |
| Security Admin | delete pods | no |
| Security Admin | get secrets | no |

Test the denies. They are the least-privilege proof.

## Assessment

Within the scope of this lab:

- Authentication and authorization are separate.
- Developer access is namespace-scoped.
- Auditor access is read-only on pods.
- Secrets are not granted.
- Cluster-scoped pod reads increase visibility and need extra care.
- Bindings, not Role objects alone, grant access.
- `kubectl auth can-i` is the validation method used here.

## Out of scope

NetworkPolicies, Pod Security Standards, admission controllers, audit log pipelines, and image scanning are listed as future work. They were not demonstrated in this repository and are not claimed as findings.
