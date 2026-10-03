Kubernetes RBAC Security Lab

Project Overview

This project demonstrates how Kubernetes authentication and authorization work together to enforce secure access to cluster resources.

Using a local Minikube environment, I created multiple certificate-based Kubernetes users and implemented Role-Based Access Control (RBAC) to demonstrate:

X.509 certificate authentication

Kubernetes authorization

Least-privilege access

Namespace isolation

Role and RoleBinding

ClusterRole and ClusterRoleBinding

Controlled cross-namespace access

Successful and denied authorization attempts

Permission validation using kubectl auth can-i

The lab intentionally includes both allowed and denied actions to show how Kubernetes can limit access based on a user's role.

Security Problem

Giving every Kubernetes user broad administrative permissions increases the potential impact of compromised credentials or user error.

This lab demonstrates how Kubernetes RBAC can reduce that risk by granting each identity only the permissions required for its role.

Three identities were created:

developer — manages selected workloads in the development namespace

auditor — read-only access to pods

security-admin — controlled read-only pod visibility across namespaces

Architecture

                        Kubernetes Cluster
                              |
              +---------------+---------------+
              |                               |
       security-lab                       production
              |                               |
        Nginx Deployment                      |
         3 Replicas                           |
              |                               |
     +--------+---------+                     |
     |                  |                     |
 developer            auditor                 |
     |                  |                     |
 RoleBinding         RoleBinding              |
     |                  |                     |
developer-role       auditor-role             |
     |                  |                     |
Manage selected      Read-only pods           |
workloads                                      |
                                               |
                    security-admin ------------+
                          |
                  ClusterRoleBinding
                          |
               security-admin-readonly
                          |
               Read pods across namespaces

Technologies Used

Kubernetes

Minikube

Docker Desktop

kubectl

OpenSSL

YAML

macOS Terminal

Git

GitHub

Environment

The project was built completely locally with no paid cloud resources.

Host: macOS
Architecture: Apple Silicon
Container Runtime: Docker Desktop
Kubernetes: Minikube
CLI: kubectl
Authentication: X.509 Certificates
Authorization: Kubernetes RBAC

Test Application

A namespace called security-lab was created containing an Nginx Deployment with three replicas.

security-lab
└── nginx Deployment
    └── ReplicaSet
        ├── nginx Pod
        ├── nginx Pod
        └── nginx Pod

This workload serves as the protected resource used throughout the RBAC testing.

Authentication vs Authorization

One of the main goals of this project was demonstrating the difference between authentication and authorization.

Authentication

Authentication answers:

Who are you?

Each Kubernetes user was configured using an X.509 certificate.

For example:

CN=developer

identifies the user as:

developer

Authorization

Authorization answers:

What are you allowed to do?

Kubernetes RBAC determines whether an authenticated identity can perform an action.

Before RBAC permissions were assigned, the authenticated developer received:

Error from server (Forbidden): pods is forbidden:
User "developer" cannot list resource "pods"
in the namespace "security-lab"

This demonstrates that successful authentication does not automatically grant authorization.

Certificate-Based Identities

The following Kubernetes identities were created:

developer
auditor
security-admin

For each identity:

A private key was generated.

A Certificate Signing Request (CSR) was generated.

The CSR was signed by the local Minikube Certificate Authority.

The certificate and private key were configured in kubeconfig.

A Kubernetes context was created.

Authentication was tested before RBAC access was granted.

Sensitive certificate material is not included in this repository.

Kubernetes RBAC

Developer Role

The developer receives namespace-scoped permissions inside:

security-lab

Pod Permissions

get
list
watch
create
delete

Deployment Permissions

get
list
watch
create
update
patch
delete

The developer does not receive unrestricted access to the cluster.

Auditor Role

The auditor demonstrates strict least-privilege access.

The auditor can only:

get pods
list pods
watch pods

The auditor cannot:

create pods
delete pods
modify deployments
access unauthorized resources

This demonstrates a read-only security role.

Namespace Isolation

A second namespace was created:

production

The developer is authorized in:

security-lab

but receives a Forbidden response when attempting equivalent operations in:

production

Example:

Error from server (Forbidden): pods is forbidden:
User "developer" cannot list resource "pods"
in the namespace "production"

Namespace-scoped RBAC helps reduce blast radius because compromised credentials are limited to the namespaces where permissions have explicitly been granted.

Role vs ClusterRole

Role

A Kubernetes Role defines permissions within a specific namespace.

Example:

developer-role
        |
        v
security-lab only

RoleBinding

A RoleBinding connects an identity to a Role.

developer
    |
RoleBinding
    |
developer-role

ClusterRole

A ClusterRole defines reusable permissions that can apply across the cluster.

For this lab, the following ClusterRole was created:

security-admin-readonly

It grants:

get
list
watch

access to pods.

ClusterRoleBinding

A ClusterRoleBinding was used to grant the security-admin identity read-only pod visibility across namespaces.

security-admin
        |
ClusterRoleBinding
        |
security-admin-readonly
        |
Pods across namespaces

The identity was intentionally not granted unrestricted cluster-admin privileges.

Access Control Matrix

Identity

View Pods

Create Pods

Delete Pods

Deployment Access

Production Access

Developer

Yes

Yes

Yes

Yes

No

Auditor

Yes

No

No

No

No

Security Admin

Yes

No

No

No

Read-only pods

Additional sensitive resources such as Kubernetes Secrets were intentionally not granted to these identities.

Security Validation

Permissions were tested using:

kubectl auth can-i

Developer

kubectl auth can-i list pods --context=developer-context -n security-lab

Expected:

yes

kubectl auth can-i create pods --context=developer-context -n security-lab

Expected:

yes

kubectl auth can-i delete pods --context=developer-context -n security-lab

Expected:

yes

kubectl auth can-i get secrets --context=developer-context -n security-lab

Expected:

no

kubectl auth can-i list pods --context=developer-context -n production

Expected:

no

Auditor

kubectl auth can-i list pods --context=auditor-context -n security-lab

Expected:

yes

kubectl auth can-i create pods --context=auditor-context -n security-lab

Expected:

no

kubectl auth can-i delete pods --context=auditor-context -n security-lab

Expected:

no

kubectl auth can-i get deployments --context=auditor-context -n security-lab

Expected:

no

Security Admin

kubectl auth can-i list pods --context=security-admin-context -n security-lab

Expected:

yes

kubectl auth can-i list pods --context=security-admin-context -n production

Expected:

yes

kubectl auth can-i delete pods --context=security-admin-context -n security-lab

Expected:

no

kubectl auth can-i get secrets --context=security-admin-context -n security-lab

Expected:

no

Security Findings

1. Authentication Does Not Equal Authorization

An X.509 certificate successfully authenticated the developer identity, but Kubernetes denied access until RBAC permissions were explicitly assigned.

Security Value

Compromised or newly created credentials do not automatically gain access to cluster resources.

2. Least Privilege Limits Capabilities

The auditor was intentionally restricted to viewing pods.

The identity could inspect workloads but could not create, delete, or modify them.

Security Value

Limiting permissions reduces the damage that can occur if credentials are misused or compromised.

3. Namespace Isolation Reduces Blast Radius

Developer permissions assigned in security-lab did not automatically apply to production.

Security Value

A compromised developer identity would not automatically provide access to workloads in other namespaces.

4. Cluster-Wide Permissions Require Additional Care

ClusterRole and ClusterRoleBinding can grant permissions across namespaces.

The security-admin example was intentionally limited to read-only pod access rather than unrestricted cluster administration.

Security Value

Cluster-scoped access should be narrowly defined because incorrect ClusterRoleBindings can significantly increase blast radius.

Threat Model

The detailed threat model is available in:

docs/threat-model.md

Primary threats considered include:

Overprivileged users

Compromised Kubernetes credentials

Excessive ClusterRole permissions

Cross-namespace lateral movement

Incorrect RoleBinding configuration

Incorrect ClusterRoleBinding configuration

Screenshots / Evidence

Recommended security evidence captured during the lab includes:

Authentication without authorization

Developer authenticated but receives Forbidden before RBAC

Developer authorization

Developer successfully lists Nginx pods after RoleBinding

Auditor least privilege

Auditor can list pods
Auditor cannot create pods
Auditor cannot delete pods

Namespace isolation

Developer receives Forbidden when accessing production

ClusterRole validation

Security-admin can view pods across namespaces
Security-admin cannot delete pods

Permission validation

kubectl auth can-i

results showing both allowed and denied operations.

Repository Structure

kubernetes-rbac-security-lab/
├── README.md
├── manifests/
│   ├── developer-role.yaml
│   ├── developer-rolebinding.yaml
│   ├── auditor-role.yaml
│   ├── auditor-rolebinding.yaml
│   ├── security-admin-clusterrole.yaml
│   └── security-admin-clusterrolebinding.yaml
├── screenshots/
├── diagrams/
├── scripts/
├── docs/
│   ├── security-findings.md
│   └── threat-model.md
└── .gitignore

Security Note

Private keys, Certificate Signing Requests, kubeconfig credentials, cluster CA private keys, and other sensitive authentication material are intentionally excluded from this repository.

The following types of files should never be committed:

*.key
*.csr
kubeconfig
*.kubeconfig
ca.key
sa.key
certificates/

Production Kubernetes environments should use secure certificate lifecycle management and should not expose Certificate Authority private keys to normal administrators or developers.

Reproducing the Lab

The safe portions of this lab can be reproduced locally using:

Docker Desktop

Minikube

kubectl

OpenSSL

Kubernetes YAML manifests

Start a local cluster:

minikube start

Verify:

kubectl get nodes

Apply the included RBAC manifests after creating the required identities:

kubectl apply -f manifests/

Certificate private keys and kubeconfig credentials are intentionally not included and should be generated locally.

Lessons Learned

This project reinforced several important Kubernetes security concepts:

Authentication identifies a user but does not determine permissions.

RBAC should follow the principle of least privilege.

Roles can restrict access to specific namespaces.

RoleBindings connect identities to namespace-scoped permissions.

ClusterRoles can define permissions usable across namespaces.

ClusterRoleBindings should be used carefully because they increase access scope.

Authorization should be explicitly tested instead of assumed.

Both successful and failed access attempts provide useful security validation.

Sensitive credentials should never be stored in public Git repositories.

Future Improvements

Potential extensions to this project include:

Kubernetes ServiceAccount security

NetworkPolicies

Pod Security Standards

Secrets management

Admission control

OPA Gatekeeper or Kyverno policies

Kubernetes audit logging

Container image scanning

CI/CD security validation

Automated RBAC testing

Disclaimer

This project was created in a local Minikube environment for educational and security testing purposes.

It is not intended to represent a production Kubernetes PKI or certificate-management architecture.
