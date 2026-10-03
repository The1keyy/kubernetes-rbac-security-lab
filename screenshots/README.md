# Screenshots

This folder is for **security validation evidence**: terminal captures that show authentication succeeded, authorization allowed an expected action, or Kubernetes returned Forbidden / `kubectl auth can-i` returned `no`.

Screenshots are documentation of tests that were run against the local Minikube cluster. They are not a substitute for the RBAC manifests.

## Current status

No screenshot image files are in this folder yet. Do not treat the table below as proof that the captures exist. Add PNG files using the names in the first column so the main README can embed them.

## Intended evidence

| Screenshot | Security concept | What it proves |
| --- | --- | --- |
| Certificate Identity (`01-certificate-identity.png`) | Authentication | X.509 identity is recognized (subject such as `CN=developer`; issuer and validity if shown) |
| Developer Forbidden (`02-developer-forbidden-before-rbac.png`) | AuthN vs AuthZ | Authentication does not automatically grant authorization |
| Developer Access (`03-developer-access-after-rbac.png`) | RBAC | RoleBinding grants expected access (three Nginx pods in `security-lab`) |
| Auditor Read Only (`04-auditor-readonly-access.png`) | Least privilege | Auditor can get/list/watch pods |
| Auditor Denied (`05-auditor-denied-create-delete.png`) | Least privilege | Unauthorized write actions are blocked |
| Production Denied (`06-developer-denied-production.png`) | Namespace isolation | Developer permissions do not cross namespaces |
| Security Admin (`07-security-admin-cross-namespace-access.png`) | ClusterRole | Controlled cross-namespace pod visibility |
| Security Admin Denied (`08-security-admin-delete-denied.png`) | Least privilege | Cluster-scoped identity is still restricted |
| RBAC Matrix (`09-rbac-can-i-matrix.png`) | Validation | Explicit permission testing using `kubectl auth can-i` |

## Naming

Use these filenames so the README can link them without guesswork:

| File | What the capture should show |
| --- | --- |
| `01-certificate-identity.png` | Certificate subject (`CN=developer` or the other lab users), optionally issuer and dates |
| `02-developer-forbidden-before-rbac.png` | `User "developer" cannot list resource "pods"` |
| `03-developer-access-after-rbac.png` | Developer listing the three Nginx pods after Role/RoleBinding |
| `04-auditor-readonly-access.png` | Auditor listing pods successfully |
| `05-auditor-denied-create-delete.png` | `kubectl auth can-i` returning `no` for create and/or delete |
| `06-developer-denied-production.png` | Developer Forbidden in the `production` namespace |
| `07-security-admin-cross-namespace-access.png` | Security-admin listing pods in more than one namespace, or `kubectl get pods -A` succeeding for that user |
| `08-security-admin-delete-denied.png` | Security-admin cannot delete pods |
| `09-rbac-can-i-matrix.png` | Grouped `kubectl auth can-i` results for allow and deny |

## Precautions

Do not capture or commit kubeconfig files, private keys, tokens, passwords, or certificate files. Redact home-directory paths if they appear in the terminal prompt and you do not want them public.
