SHELL := /bin/bash

APP_NAME := kubernetes-app-blueprint
APP_VERSION := $(shell grep '^appVersion' $(APP_NAME)/Chart.yaml | awk '{print $$2}' | tr -d '"' )

.PHONY: help build cluster-create cluster-destroy helm-deploy helm-undeploy call

help:
	@echo "Makefile commands:"
	@echo "  make build            Build the Docker image and load into Minikube"
	@echo "  make cluster-create   Start a Minikube cluster"
	@echo "  make cluster-destroy  Delete the Minikube cluster"
	@echo "  make helm-deploy      Deploy or upgrade the Helm release"
	@echo "  make helm-undeploy    Uninstall the Helm release"
	@echo "  make call             Wait for the app and curl the service"

build:
	@echo "Building Docker image..."
	export DOCKER_BUILDKIT=1
	minikube image build --tag $(APP_NAME):$(APP_VERSION) .

cluster-create:
	@echo "Starting Minikube cluster..."
	minikube start --driver=docker --wait=true
	minikube addons enable ingress

	# Create a TLS private key secret for the ingress if it doesn't already exist
	kubectl get secret $(APP_NAME)-ingress-tls-key >/dev/null 2>&1 || \
		kubectl create secret generic $(APP_NAME)-ingress-tls-key --from-file=private.pem=<(openssl genrsa 4096)

	# Generate a self-signed TLS certificate from the private key and store it in a ConfigMap
	@kubectl get configmap $(APP_NAME)-ingress-tls-cert >/dev/null 2>&1 || \
		{ \
			CERT=$$(kubectl get secret $(APP_NAME)-ingress-tls-key \
					-o jsonpath='{.data.private\.pem}' | \
					base64 --decode | \
					openssl req -x509 -new -nodes \
						-key /dev/stdin \
						-subj '/CN=my-web-app' \
						-days 365); \
			kubectl create configmap $(APP_NAME)-ingress-tls-cert \
				--from-literal=cert.pem="$$CERT"; \
		}

cluster-destroy:
	@echo "Deleting Minikube cluster..."
	minikube delete

helm-deploy:
	@echo "Deploying or upgrading Helm release..."
	helm upgrade --install $(APP_NAME) "./$(APP_NAME)" \
		--values $(APP_NAME)/values/common.yaml \
		--values $(APP_NAME)/values/env/local.yaml \
		--set gitCommit="$$(git rev-parse HEAD)"

helm-undeploy:
	@echo "Uninstalling Helm release..."
	-helm uninstall $(APP_NAME)

call:
	@kubectl rollout status deployment/$(APP_NAME) --timeout=60s
	@curl -k https://localhost/ --resolve localhost:443:$$(minikube ip)

dashboard:
	@minikube dashboard
