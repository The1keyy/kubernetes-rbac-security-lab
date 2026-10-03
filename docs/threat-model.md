Threat Model

Overview

This threat model evaluates security risks related to Kubernetes authentication, RBAC permissions, namespace isolation, and cluster-scoped access in this lab.

The goal is to identify how misconfigured permissions or compromised credentials could increase risk, and which controls reduce that risk.

Threat 1 — Overprivileged User

Threat

A Kubernetes user is granted more permissions than required for their responsibilities.

Risk

An overprivileged account could create, modify, or delete resources beyond its intended role. If the account is compromised, the attacker would inherit those permissions.

Security Control

Use Kubernetes RBAC and the principle of least privilege.

The lab separates permissions between:

developer

auditor

security-admin

Each identity receives only the access required for its role.

Validation

Permissions were tested using:

kubectl auth can-i

The auditor, for example, can read pods but cannot create or delete them.

Threat 2 — Compromised Kubernetes Credentials

Threat

An attacker obtains a user's Kubernetes private key, certificate, or kubeconfig credentials.

Risk

The attacker could impersonate the compromised identity and perform any actions allowed by that account.

Security Control

Protect private keys

Restrict file permissions

Do not store sensitive credentials in Git

Use least-privilege RBAC

Limit access scope by namespace

Validation

Private keys were stored locally and excluded from Git using .gitignore.

The developer account was also restricted to the security-lab namespace, limiting the impact of credential compromise.

Threat 3 — Excessive ClusterRole Permissions

Threat

A ClusterRole grants unnecessarily broad permissions across the Kubernetes cluster.

Risk

Cluster-scoped permissions can increase blast radius because the identity may gain access to resources across multiple namespaces.

Security Control

The security-admin-readonly ClusterRole was intentionally limited to:

get
list
watch

for pods.

The account was not granted unrestricted cluster-admin access.

Validation

The security-admin identity can list pods across namespaces but cannot delete pods or access Kubernetes Secrets.

Threat 4 — Cross-Namespace Lateral Movement

Threat

A user with access to one namespace gains unauthorized access to another namespace.

Risk

A compromised identity could move from a lower-risk development environment into a more sensitive production environment.

Security Control

Use namespace-scoped Roles and RoleBindings.

The developer Role exists only in:

security-lab

and does not grant permissions inside:

production

Validation

The developer successfully listed pods in security-lab but received a Forbidden response when attempting to list pods in production.

Threat 5 — Misconfigured RoleBinding

Threat

A RoleBinding connects the wrong user or group to a privileged Role.

Risk

An identity could gain permissions that were not intended for it.

Security Control

Explicitly define:

the subject identity

the target Role

the target namespace

RBAC manifests should be reviewed before deployment.

Validation

The developer and auditor were each bound to separate Roles with different permission levels.

Threat 6 — Misconfigured ClusterRoleBinding

Threat

A ClusterRoleBinding assigns cluster-wide permissions to an unintended identity.

Risk

Unlike namespace-scoped access, a ClusterRoleBinding can expand an identity's access across the cluster and significantly increase blast radius.

Security Control

Avoid unnecessary ClusterRoleBindings

Grant narrowly scoped ClusterRoles

Avoid cluster-admin unless absolutely required

Regularly audit cluster-scoped RBAC

Validation

The lab uses a controlled ClusterRoleBinding granting security-admin read-only access to pods instead of unrestricted administrative privileges.

Threat Summary

Threat

Risk

Control

Overprivileged users

Excessive resource access

Least-privilege RBAC

Compromised credentials

Identity impersonation

Credential protection + limited RBAC

Excessive ClusterRole permissions

Cluster-wide blast radius

Narrow ClusterRoles

Cross-namespace movement

Unauthorized environment access

Namespace isolation

Misconfigured RoleBinding

Wrong user gains permissions

Explicit binding review

Misconfigured ClusterRoleBinding

Cluster-wide unauthorized access

Restrict cluster-scoped bindings

Conclusion

The lab demonstrates that Kubernetes security depends on both strong authentication and carefully scoped authorization.

Authentication determines who the user is, while RBAC determines what the authenticated identity can do.

Using least privilege, namespace isolation, and controlled cluster-level access reduces the potential impact of compromised credentials and RBAC misconfiguration.
