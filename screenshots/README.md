# Screenshots

Terminal output from the Minikube lab. Use these to see what passed and what was Forbidden.

| File | What you are looking at |
| --- | --- |
| `00-nginx-workload-security-lab.png` | Nginx Deployment, 3 pods in `security-lab` |
| `01-certificate-identity.png` | `CN=developer`, issuer `minikubeCA` |
| `02-developer-forbidden-before-rbac.png` | Logged in, no RoleBinding yet, list pods fails |
| `03-developer-access-after-rbac.png` | Same user lists the 3 pods after RBAC |
| `06-developer-denied-production.png` | Developer cannot list pods in `production` |
| `07-security-admin-cross-namespace-access.png` | `kubectl get pods -A` as security-admin; production is empty, not Forbidden |
| `08-security-admin-delete-denied.png` | Same capture as `07` (`can-i delete pods` = `no`) |
| `09-rbac-can-i-matrix.png` | Allow/deny checks for all three users |

I do not have a separate auditor `kubectl get pods` screenshot. Auditor permissions are in `09`.

Do not screenshot kubeconfig, keys, or tokens.
