Kubernetes RBAC Security Lab

Author: The1keyy
License: MIT

A hands-on Kubernetes security lab built with Minikube to demonstrate authentication, RBAC, least privilege, workload identity, Pod Security Admission, NetworkPolicy enforcement, audit logging, automated authorization testing, and RBAC security analysis.

This project is designed as a local learning and portfolio environment for Kubernetes Security, Cloud Security, DevSecOps, Platform Security, and Security Engineering roles.

This is a learning lab, not a production Kubernetes environment.

What This Project Demonstrates

X.509 certificate-based Kubernetes users

Authentication vs authorization

Namespace-scoped RBAC

ClusterRole and ClusterRoleBinding

Least privilege

Namespace isolation

Automated RBAC testing

Kubernetes ServiceAccounts

Workload identity

Controlled RBAC misconfiguration and remediation

Pod Security Admission

NetworkPolicy enforcement with Calico

Kubernetes audit logging

RBAC permission analysis with kubectl-who-can

Reproducible setup and cleanup scripts

Architecture

The lab uses two namespaces:

security-lab

production

The primary application is a three-replica Nginx Deployment inside security-lab.

![Three-replica Nginx workload running in security-lab](screenshots/00-nginx-workload-security-lab.png)

Three Nginx pods are Running, and the Deployment and ReplicaSet report 3/3 Ready in security-lab.

Minikube Kubernetes Cluster
│
├── security-lab
│   ├── Nginx Deployment
│   │   ├── Pod
│   │   ├── Pod
│   │   └── Pod
│   │
│   ├── developer
│   ├── auditor
│   ├── app-reader ServiceAccount
│   ├── Pod Security Admission
│   └── NetworkPolicy
│
├── production
│
└── Cluster-wide
    └── security-admin read-only pod access

See diagrams/architecture.md for additional architecture notes.

Access Model

Identity

Scope

Allowed

Denied

developer

security-lab

View, create, and delete pods; manage deployments

Production access; Secrets

auditor

security-lab

Get, list, and watch pods

Pod writes; deployments; production; Secrets

security-admin

Cluster-wide pod reads

Get, list, and watch pods across namespaces

Delete pods; Secrets; cluster-admin

app-reader

security-lab

Get, list, and watch pods

Pod writes; Secrets; production access

The project intentionally avoids granting any lab identity unrestricted cluster-admin privileges.

Authentication vs Authorization

Authentication answers:

Who are you?

Authorization answers:

What are you allowed to do?

The human identities in this lab use X.509 client certificates.

For example, developer authenticated successfully before receiving RBAC permissions, but Kubernetes still denied pod access.

Error from server (Forbidden): pods is forbidden:
User "developer" cannot list resource "pods"
in the namespace "security-lab"

![Authenticated developer forbidden from listing pods before RBAC](screenshots/02-developer-forbidden-before-rbac.png)

The developer certificate authenticates, and Kubernetes still returns Forbidden before a RoleBinding exists.

After applying the developer Role and RoleBinding, the same identity was able to access the workload.

![Developer lists pods after the Role and RoleBinding](screenshots/03-developer-access-after-rbac.png)

The same developer identity lists the three Running Nginx pods after RBAC is applied.

Certificate identity:

![X.509 client certificate for the developer identity](screenshots/01-certificate-identity.png)

The developer certificate subject is CN=developer and the issuer is minikubeCA.

Private keys, CSRs, kubeconfig files, and sensitive certificates are intentionally excluded from this repository.

RBAC Design

Developer

The developer uses a namespace-scoped Role and RoleBinding inside security-lab.

Allowed:

get pods

list pods

watch pods

create pods

delete pods

manage deployments

Denied:

Secrets

equivalent access in production

![Developer denied listing pods in production](screenshots/06-developer-denied-production.png)

Namespace-scoped RBAC stops developer from listing pods in production.

Auditor

The auditor has read-only access to pods inside security-lab.

Allowed:

get pods

list pods

watch pods

Denied:

create pods

delete pods

manage deployments

production access

Secrets

Security Admin

The security-admin identity uses a read-only ClusterRole.

Allowed:

get pods across namespaces

list pods across namespaces

watch pods across namespaces

Denied:

delete pods

read Secrets

unrestricted cluster administration

![security-admin lists pods across namespaces and is denied pod deletion](screenshots/07-security-admin-cross-namespace-access.png)

security-admin can list pods in security-lab and production, and kubectl auth can-i delete pods returns no.

RBAC Validation

![Manual kubectl auth can-i results for developer, auditor, and security-admin](screenshots/09-rbac-can-i-matrix.png)

Manual can-i checks allow developer pod and deployment actions in security-lab, keep auditor read-only, and deny security-admin delete and Secret access.

Automated RBAC Testing

The project includes:

scripts/test-rbac.sh

The script automatically validates expected permissions using:

kubectl auth can-i

It compares:

identity

action

resource

namespace

expected result

actual result

The current test suite validates 15 authorization checks.

Passed: 15
Failed: 0

ALL RBAC TESTS PASSED



This makes the RBAC configuration repeatable and easier to regression-test after security changes.

ServiceAccount Security

The lab includes a workload identity:

system:serviceaccount:security-lab:app-reader

The app-reader ServiceAccount can:

get pods

list pods

watch pods

It cannot:

create pods

delete pods

read Secrets

access production workloads

Example:

list pods:   yes
create pods: no
get secrets: no
production:  no



See docs/service-account-security.md.

RBAC Misconfiguration and Remediation

The project includes a controlled, intentionally insecure RBAC scenario.

The app-reader ServiceAccount initially cannot read Secrets:

no

An intentionally insecure Role and RoleBinding are then applied:

misconfigurations/app-reader-secret-access.yaml

After the misconfiguration:

yes

The insecure RBAC is removed and Secret access returns to:

no

This demonstrates:

privilege expansion

excessive permissions

RBAC misconfiguration

detection

remediation

validation

Evidence:

13-rbac-misconfiguration-before.png

14-rbac-misconfiguration-after.png

15-rbac-remediation-after.png

See docs/rbac-misconfiguration-lab.md.

Pod Security Admission

The security-lab namespace enforces the Kubernetes:

baseline

Pod Security Standard.

An intentionally insecure pod attempts to use:

securityContext:
  privileged: true

Kubernetes blocks the workload before it can run.

Error from server (Forbidden):
violates PodSecurity "baseline:latest"



This demonstrates preventive workload security.

See docs/pod-security-admission.md.

Network Isolation

The Minikube cluster uses Calico so Kubernetes NetworkPolicy rules are actually enforced.

Before applying the NetworkPolicy:

HTTP/1.1 200 OK

The test pod could communicate with the Nginx workload.



A NetworkPolicy was then applied to deny ingress traffic to the selected Nginx pods.

After the policy:

curl: (28) Connection timed out



This demonstrates that RBAC and NetworkPolicy protect different layers:

RBAC controls Kubernetes API actions.

NetworkPolicy controls workload network traffic.

See docs/network-isolation.md.

Kubernetes Audit Logging

Kubernetes API audit logging is enabled at the Metadata level.

This captures important security information without recording full request or response bodies.

Audit records include:

requesting identity

impersonated identity

requested resource

namespace

action

response status

authorization decision

Allowed Request

The auditor identity successfully listed pods.

The audit event recorded:

resource: pods
code: 200
decision: allow



Forbidden Request

The auditor attempted to list Secrets.

Kubernetes returned:

Forbidden

The audit event recorded:

resource: secrets
code: 403
decision: forbid



Audit configuration:

audit/audit-policy.yaml

RBAC Security Scanning

The project uses:

kubectl-who-can

to identify Kubernetes subjects capable of performing selected API actions.

Example:

kubectl who-can delete pods -n security-lab

The scanner correctly identified the developer RoleBinding as granting pod deletion permission.



This complements kubectl auth can-i.

kubectl auth can-i asks:

Can this identity perform this action?

kubectl who-can asks:

Which identities can perform this action?

See security-scans/rbac-findings.md.

Reproducible Setup

The repository includes:

scripts/setup.sh

The setup script:

verifies required tools

checks Minikube

applies namespaces

deploys Nginx

applies human-user RBAC

creates the ServiceAccount

applies workload RBAC

enables Pod Security Admission

applies NetworkPolicy

waits for rollout completion

prints a security summary

Run:

./scripts/setup.sh

Safe Cleanup

The project also includes:

scripts/cleanup.sh

The cleanup script removes only resources belonging to this lab.

It does not:

delete Minikube

delete unrelated namespaces

remove local project files

delete audit configuration files

Run:

./scripts/cleanup.sh

Repository Structure

kubernetes-rbac-security-lab/
├── README.md
├── LICENSE
├── manifests/
│   ├── namespaces.yaml
│   ├── nginx-deployment.yaml
│   ├── developer-role.yaml
│   ├── developer-rolebinding.yaml
│   ├── auditor-role.yaml
│   ├── auditor-rolebinding.yaml
│   ├── security-admin-clusterrole.yaml
│   ├── security-admin-clusterrolebinding.yaml
│   ├── app-reader-serviceaccount.yaml
│   ├── app-reader-role.yaml
│   ├── app-reader-rolebinding.yaml
│   └── network-policies/
│       └── deny-nginx-ingress.yaml
├── misconfigurations/
│   ├── app-reader-secret-access.yaml
│   └── privileged-pod.yaml
├── scripts/
│   ├── setup.sh
│   ├── cleanup.sh
│   └── test-rbac.sh
├── audit/
│   └── audit-policy.yaml
├── security-scans/
│   └── rbac-findings.md
├── docs/
│   ├── security-findings.md
│   ├── threat-model.md
│   ├── service-account-security.md
│   ├── rbac-misconfiguration-lab.md
│   ├── pod-security-admission.md
│   └── network-isolation.md
├── diagrams/
│   └── architecture.md
└── screenshots/

Security Controls Demonstrated

Control

Security Purpose

X.509 authentication

Establish user identity

RBAC

Restrict Kubernetes API permissions

Namespace isolation

Reduce access scope and blast radius

Least privilege

Limit permissions to required actions

ServiceAccounts

Provide workload identity

Pod Security Admission

Block unsafe pod configurations

NetworkPolicy

Restrict pod-to-pod network communication

Audit logging

Record API and authorization activity

Automated RBAC tests

Detect unexpected authorization changes

RBAC scanning

Identify identities with sensitive privileges

Threats Addressed

The lab explores risks including:

overprivileged users

overprivileged ServiceAccounts

compromised credentials

cross-namespace lateral movement

excessive ClusterRole permissions

accidental Secret exposure

privileged workloads

unrestricted pod-to-pod traffic

incorrect RoleBindings

privilege expansion through RBAC changes

See docs/threat-model.md.

Security Practices

Sensitive files must never be committed.

The .gitignore excludes items such as:

*.key
*.csr
certificates/
kubeconfig
*.kubeconfig
ca.key
sa.key

Do not commit:

private keys

cluster CA private keys

Kubernetes Secrets

bearer tokens

kubeconfig credentials

passwords

cloud credentials

Tools

Kubernetes

Minikube

Docker Desktop

Calico

kubectl

kubectl-who-can

Krew

OpenSSL

Bash

YAML

Git

GitHub

macOS Terminal

Key Security Lessons

Authentication does not automatically provide authorization.

Namespace-scoped RBAC can reduce blast radius.

Cluster-wide permissions should be narrowly defined.

ServiceAccounts should follow least privilege.

Small RBAC changes can create meaningful privilege expansion.

Pod Security Admission can prevent unsafe workloads before execution.

NetworkPolicy provides isolation that RBAC alone cannot provide.

Audit logs provide evidence for successful and denied activity.

Automated validation makes security controls easier to maintain.

Security scanning can expose unexpected or excessive permissions.

License

MIT

This repository is intended for learning, security experimentation, and portfolio demonstration.

Do not commit sensitive Kubernetes credentials or private keys.
