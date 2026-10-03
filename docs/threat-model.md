# What can go wrong (this lab only)

This is about the RBAC in this Minikube project. It is not a full cluster threat model.

| If this happens | Why it matters | What this lab does | How I checked |
| --- | --- | --- | --- |
| User gets more verbs than they need | They (or whoever stole the cert) can change or delete too much | Separate Roles; nobody is `cluster-admin`; no Secrets in the YAML | `kubectl auth can-i` — auditor can list, cannot create/delete |
| Private key / kubeconfig leaks | Attacker is that user | Keys gitignored; developer/auditor limited to `security-lab`; security-admin is read-only pods | Developer is Forbidden in `production` |
| ClusterRole is too wide (`*`, delete, secrets) | One binding hits every namespace | `security-admin-readonly` is get/list/watch on pods only | List yes across namespaces; delete and get secrets no |
| Access in `security-lab` used to reach `production` | Dev access becomes prod access | Developer and auditor Roles are only in `security-lab` | Developer list pods in production = Forbidden |
| RoleBinding names the wrong user | Auditor might get developer permissions | Bindings name one User, one Role, namespace `security-lab` | Auditor cannot create/delete or manage deployments |
| ClusterRoleBinding is wrong or uses `cluster-admin` | Mistake is cluster-wide | One binding: `security-admin` → `security-admin-readonly` | Delete and secrets still no |

Not covered here: breaking into a node, etcd, cloud IAM, or stealing the Minikube CA key on the laptop. That CA key can mint any client cert, which is why it stays off Git.
