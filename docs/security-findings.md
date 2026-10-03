Security Findings

Overview

This document summarizes the main security observations identified while building and testing the Kubernetes RBAC Security Lab.

The lab focused on authentication, authorization, least privilege, namespace isolation, and controlled cluster-wide access.

Finding 1 — Authentication Does Not Grant Access

Observation

The developer identity successfully authenticated using an X.509 certificate.

Before any RBAC permissions were assigned, the user attempted to list pods in the security-lab namespace and received a Forbidden response.

Evidence

User "developer" cannot list resource "pods"
in the namespace "security-lab"

Security Impact

This confirms that Kubernetes separates authentication from authorization.

A valid certificate proves who the user is, but does not automatically grant access to cluster resources.

Security Control

Use RBAC to explicitly define which actions authenticated identities are allowed to perform.

Finding 2 — Developer Access Is Namespace Scoped

Observation

The developer user was granted permissions inside the security-lab namespace using a Role and RoleBinding.

The developer could successfully access allowed resources in security-lab.

However, the same user was denied equivalent access in the production namespace.

Evidence

Allowed:

developer -> security-lab -> allowed

Denied:

developer -> production -> Forbidden

Security Impact

Namespace-scoped RBAC reduces the blast radius of compromised developer credentials.

Security Control

Use namespace-specific Roles and RoleBindings instead of broader cluster-wide permissions when possible.

Finding 3 — Auditor Follows Least Privilege

Observation

The auditor identity was granted only read-only pod permissions.

Allowed actions:

get
list
watch

Denied actions included:

create pods
delete pods
modify deployments

Security Impact

The auditor can inspect workloads without being able to change or destroy them.

Security Control

Grant only the minimum permissions required for the user's responsibilities.

Finding 4 — Sensitive Resources Remain Restricted

Observation

The developer and security-admin identities were not granted access to Kubernetes Secrets.

Permission validation showed denied access.

Security Impact

Secrets may contain sensitive values such as credentials, tokens, and application configuration.

Restricting Secret access reduces the risk of credential exposure.

Security Control

Do not include sensitive resource types in RBAC rules unless they are explicitly required.

Finding 5 — Cluster-Wide Access Increases Scope

Observation

A ClusterRole and ClusterRoleBinding were used to grant the security-admin identity read-only pod visibility across namespaces.

The account could view pods across namespaces but could not delete pods.

Security Impact

Cluster-scoped access can increase blast radius compared with namespace-scoped access.

A poorly designed ClusterRole or ClusterRoleBinding could expose multiple namespaces.

Security Control

Use narrow ClusterRoles and avoid unrestricted cluster-admin access unless absolutely necessary.

Finding 6 — RoleBindings Control Who Receives Permissions

Observation

Creating a Role alone did not assign permissions to the developer.

Access was granted only after creating a RoleBinding between:

developer
    |
RoleBinding
    |
developer-role

Security Impact

An incorrect RoleBinding could grant permissions to the wrong identity.

Security Control

Review both the Role permissions and the RoleBinding subjects before deployment.

Finding 7 — ClusterRoleBindings Require Greater Caution

Observation

The security-admin identity gained cross-namespace pod visibility only after a ClusterRoleBinding connected the user to the ClusterRole.

Security Impact

A misconfigured ClusterRoleBinding can provide access across the entire cluster rather than a single namespace.

Security Control

ClusterRoleBindings should be rare, narrowly scoped, and reviewed carefully.

Finding 8 — Authorization Must Be Tested

Observation

Permissions were validated using:

kubectl auth can-i

Both allowed and denied operations were tested.

Examples included:

Developer:
list pods -> yes
delete pods -> yes
get secrets -> no
production access -> no

Auditor:
list pods -> yes
create pods -> no
delete pods -> no

Security Admin:
list pods across namespaces -> yes
delete pods -> no
get secrets -> no

Security Impact

RBAC configuration should not be assumed to work correctly just because YAML manifests deploy successfully.

Security Control

Explicitly test expected permissions and expected denials after configuring RBAC.

Overall Security Assessment

The lab successfully demonstrated several important Kubernetes security principles:

Authentication and authorization are separate controls

Permissions should follow least privilege

Namespace isolation limits blast radius

Cluster-scoped access requires stronger review

RoleBindings and ClusterRoleBindings directly determine who receives permissions

Sensitive resources should remain restricted unless explicitly required

Authorization should be tested using both positive and negative cases

Recommended Improvements

Future improvements to the lab could include:

Kubernetes NetworkPolicies

Pod Security Standards

ServiceAccount security

Admission control

Kyverno or OPA Gatekeeper policies

Kubernetes audit logging

Secrets management

Image vulnerability scanning

Automated RBAC validation in CI/CD
