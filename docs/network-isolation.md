# Network Isolation

## Overview

This lab demonstrates Kubernetes NetworkPolicy enforcement using Calico.

RBAC controls access to Kubernetes API resources, while NetworkPolicy controls network communication between pods.

## CNI

The Minikube cluster was configured with Calico so NetworkPolicy rules are actually enforced.

## Baseline Test

A test pod named `network-test` was created in the `security-lab` namespace.

Before applying a NetworkPolicy, the test pod could connect directly to an Nginx pod.

The connection returned:

`HTTP/1.1 200 OK`

## NetworkPolicy

A NetworkPolicy named:

`deny-nginx-ingress`

was applied to Nginx pods in the `security-lab` namespace.

The policy selects pods with:

`app=nginx`

and defines an empty ingress rule set.

This means inbound traffic to the selected Nginx pods is denied unless another policy explicitly allows it.

## Validation

After applying the policy, the same curl request was tested again.

The connection timed out.

This confirmed that the NetworkPolicy was actively enforced by Calico.

## Security Impact

Network isolation limits lateral movement between workloads.

If one pod is compromised, NetworkPolicy can reduce the attacker's ability to communicate with other workloads.

## Security Lesson

RBAC and NetworkPolicy protect different layers:

- RBAC controls Kubernetes API permissions.
- NetworkPolicy controls pod-to-pod network traffic.
- Both are needed for stronger defense in depth.

## Evidence

- `17-networkpolicy-before.png`
- `18-networkpolicy-after.png`

