# Kubernetes App Blueprint

A production-style blueprint for a containerised Python application deployed with Docker, Kubernetes, and Helm.

This project is intentionally simple (prints "Hello World") but demonstrates cloud-native best practices, including containerisation, Kubernetes manifests, Helm charts, and local Minikube deployment.

## Prerequisites

- [Docker](https://www.docker.com) >= 20.x
- [Helm](https://helm.sh) >= 3.10.x
- [Minikube](https://minikube.sigs.k8s.io) >= 1.28.x
- [Python](https://www.python.org) >= 3.12 (for local development)

## Start the Cluster & Build

```bash
make cluster-create
make build
helm-deploy
```

### Call the Application

```bash
make call
```

### Destroy All Resources

```bash
make helm-undeploy
make cluster-destroy
```

## Code Quality

This project uses [pre-commit](https://pre-commit.com) to enforce code quality, formatting, and security checks before each commit. It includes:

- Detecting private keys and AWS credentials
- Fixing line endings, trailing whitespace, and end-of-file
- Checking JSON, TOML, and YAML syntax
- Spell-checking and repository hygiene (large files, symlinks, merge conflicts)

### Install Hooks

```bash
pip install pre-commit
pre-commit install
```

### Run Hooks Manually

```bash
pre-commit run --all-files
```
