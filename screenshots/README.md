# Screenshots

This folder holds **security validation evidence**: terminal captures from the local Minikube cluster. They document authentication, allowed RBAC actions, and Forbidden / `kubectl auth can-i` denials. They do not replace the manifests.

## Present

| File | Security concept | What it proves |
| --- | --- | --- |
| `00-nginx-workload-security-lab.png` | Test workload | Nginx Deployment 3/3 and three Running pods in `security-lab` |
| `01-certificate-identity.png` | Authentication | Subject `CN=developer`, issuer `CN=minikubeCA`, validity dates |
| `02-developer-forbidden-before-rbac.png` | AuthN vs AuthZ | User `developer` cannot list pods in `security-lab` before RBAC |
| `03-developer-access-after-rbac.png` | RBAC | Developer lists the three Nginx pods after Role/RoleBinding |
| `06-developer-denied-production.png` | Namespace isolation | User `developer` cannot list pods in `production` |
| `07-security-admin-cross-namespace-access.png` | ClusterRole | `kubectl get pods -A` as security-admin succeeds; production list is empty, not Forbidden |
| `08-security-admin-delete-denied.png` | Least privilege | Same capture as `07`: `kubectl auth can-i delete pods` is `no` |
| `09-rbac-can-i-matrix.png` | Validation | Allow/deny matrix for developer, auditor, and security-admin |

`07` and `08` are copies of one terminal session because that session includes both cross-namespace reads and the delete denial.

## Missing

| File | Security concept | Status |
| --- | --- | --- |
| `04-auditor-readonly-access.png` | Least privilege | No dedicated auditor `kubectl get pods` capture. Auditor `list pods` = `yes` is in `09`. |
| `05-auditor-denied-create-delete.png` | Least privilege | No dedicated screenshot. Auditor `create` / `delete` = `no` is in `09`. |

## Precautions

Do not capture or commit kubeconfig files, private keys, tokens, passwords, or certificate files.
