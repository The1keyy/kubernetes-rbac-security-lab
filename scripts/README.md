# Scripts

Nothing in here on purpose.

Certs and kubeconfig were created on my machine with OpenSSL and the Minikube CA. That uses private keys, so it stays off Git.

If you are following along: generate your own certs under `certificates/` (ignored), point kubeconfig at them, apply `manifests/`, then run `kubectl auth can-i` from the root README.
