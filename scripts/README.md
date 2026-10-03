# Scripts

This directory is reserved for local helper scripts. None are published.

Certificate generation, CSR signing, and kubeconfig context setup were done on the workstation with OpenSSL and the local Minikube CA. Those steps use private keys and CA material that must not be committed.

To reproduce identities, generate keys and certificates locally, keep them under `certificates/` (gitignored), and point kubeconfig at those files. Then apply `manifests/` and run `kubectl auth can-i` as described in the root README.
