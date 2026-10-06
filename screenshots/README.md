# Screenshots

Each capture is used once in the main README, directly under the control it proves. Before/after pairs sit side by side.

| Filename | Section | What the screenshot proves |
| --- | --- | --- |
| `00-nginx-workload-security-lab.png` | Architecture | Three-replica Nginx workload is Ready in `security-lab`. |
| `01-certificate-identity.png` | Authentication | Developer identity is an X.509 certificate: `CN=developer`, issued by `minikubeCA`. |
| `02-developer-forbidden-before-rbac.png` | Authentication vs Authorization | Authenticated developer receives Forbidden when listing pods before RBAC. |
| `03-developer-access-after-rbac.png` | Authentication vs Authorization | Same developer lists the three Nginx pods after the Role and RoleBinding. |
| `06-developer-denied-production.png` | Developer RBAC | Developer is denied listing pods in `production`. |
| `07-security-admin-cross-namespace-access.png` | Security Admin | security-admin can list pods across namespaces and cannot delete pods. |
| `08-security-admin-delete-denied.png` | Omitted from main README | Same capture as `07`. The delete denial is already visible there. |
| `09-rbac-can-i-matrix.png` | RBAC Validation | Manual `kubectl auth can-i` allow and deny results for developer, auditor, and security-admin. |
| `10-reproducible-setup-success.png` | Reproducible Setup | `./scripts/setup.sh` finishes with namespaces, Nginx 3/3, and lab RBAC in place. |
| `11-automated-rbac-pass-matrix.png` | Automated RBAC Testing | 15 authorization checks passed and 0 failed. |
| `12-serviceaccount-readonly.png` | ServiceAccount Security | `app-reader` can list pods and cannot write pods, read Secrets, or reach production. |
| `13-rbac-misconfiguration-before.png` | RBAC Misconfiguration | Secret access is denied before privilege expansion. |
| `14-rbac-misconfiguration-after.png` | RBAC Misconfiguration | Secret access is allowed after the insecure Role is applied. |
| `15-rbac-remediation-after.png` | RBAC Misconfiguration | Secret access is denied again after the insecure RBAC is removed. |
| `16-pod-security-admission-denied.png` | Pod Security Admission | Kubernetes blocks a privileged pod under `baseline:latest`. |
| `17-networkpolicy-before.png` | Network Isolation | Test pod receives HTTP 200 from Nginx before the policy. |
| `18-networkpolicy-after.png` | Network Isolation | The same connection times out after NetworkPolicy enforcement. |
| `19-audit-allowed.png` | Kubernetes Audit Logging | Auditor pod list succeeds and the audit event records allow / HTTP 200. |
| `20-audit-forbidden.png` | Kubernetes Audit Logging | Auditor Secret list is Forbidden and the audit event records 403 / forbid. |
| `21-rbac-scanner-delete-pods.png` | RBAC Security Scanning | `kubectl-who-can` identifies who can delete pods, including the developer RoleBinding. |

Do not screenshot kubeconfig, keys, or tokens.
