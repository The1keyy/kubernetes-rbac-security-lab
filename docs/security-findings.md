# What I saw in this lab

Notes from the Minikube cluster. Only things I actually tested or that are in the YAML.

## Login is not permission

`developer` had a valid cert. Before any RoleBinding, `kubectl get pods` in `security-lab` returned Forbidden. The cert only names the user. The RoleBinding is what allows the API call.

## Developer stays in `security-lab`

The developer Role is namespaced. Pods in `production` stay Forbidden. If that kubeconfig leaked, it would not automatically become production access.

## Auditor is read-only

`auditor-role` is get/list/watch on pods. Create, delete, and deployments are not in the Role. `kubectl auth can-i` returned yes for list and no for create/delete.

## Secrets are not in these Roles

None of the YAML files grant `secrets`. Security-admin `can-i get secrets` was `no`. Developer Secret access was not in the screenshot; it is also missing from the Role.

## ClusterRole is wider even when it is read-only

Security-admin can list pods in every namespace, including `production`. Delete is still `no`. A typo that added `delete` or `secrets` to that ClusterRole would apply everywhere the binding reaches. This user is not `cluster-admin`.

## The binding is the actual grant

A Role sitting in the cluster does nothing until a RoleBinding (or ClusterRoleBinding) points a user at it. Wrong subject name = wrong person gets the Role.

## Test the nos

`kubectl apply` succeeding is not a permission test. I used `kubectl auth can-i` for both yes and no. Results are in the root README and `screenshots/09-rbac-can-i-matrix.png`.

Not in this lab: NetworkPolicies, Pod Security, admission controllers, audit logs.
