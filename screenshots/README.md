# Screenshots

Terminal evidence from the Minikube lab. The main README uses one capture per proof and skips duplicates.

| Filename | Section | What the screenshot proves |
| --- | --- | --- |
| `00-nginx-workload-security-lab.png` | Architecture | Three-replica Nginx workload is Ready in `security-lab`. |
| `01-certificate-identity.png` | Authentication | Developer identity is an X.509 certificate: `CN=developer`, issued by `minikubeCA`. |
| `02-developer-forbidden-before-rbac.png` | Authentication vs Authorization | Authenticated developer receives Forbidden when listing pods before RBAC. |
| `03-developer-access-after-rbac.png` | Authentication vs Authorization | Same developer lists the three Nginx pods after the Role and RoleBinding. |
| `06-developer-denied-production.png` | Namespace Isolation / Developer RBAC | Developer is denied listing pods in `production`. |
| `07-security-admin-cross-namespace-access.png` | Security Admin / ClusterRole | security-admin can list pods across namespaces and cannot delete pods. |
| `08-security-admin-delete-denied.png` | Security Admin (omitted from main README) | Byte-identical to `07`, so the main README does not repeat it. |
| `09-rbac-can-i-matrix.png` | RBAC Validation | Manual `kubectl auth can-i` allow and deny results for developer, auditor, and security-admin. |

`08-security-admin-delete-denied.png` is the same file as `07-security-admin-cross-namespace-access.png`. The delete denial is already visible in that capture.

These filenames are not in this folder, so they are not linked from the main README:

`10-reproducible-setup-success.png`, `11-automated-rbac-pass-matrix.png`, `12-serviceaccount-readonly.png`, `13-rbac-misconfiguration-before.png`, `14-rbac-misconfiguration-after.png`, `15-rbac-remediation-after.png`, `16-pod-security-admission-denied.png`, `17-networkpolicy-before.png`, `18-networkpolicy-after.png`, `19-audit-allowed.png`, `20-audit-forbidden.png`, `21-rbac-scanner-delete-pods.png`.

Do not screenshot kubeconfig, keys, or tokens.
