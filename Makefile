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
	minikube image build -t $(APP_NAME):$(APP_VERSION) .

cluster-create:
	@echo "Starting Minikube cluster..."
	minikube start

cluster-destroy:
	@echo "Deleting Minikube cluster..."
	minikube delete

helm-deploy:
	@echo "Deploying or upgrading Helm release..."
	helm upgrade --install $(APP_NAME) "./$(APP_NAME)"

helm-undeploy:
	@echo "Uninstalling Helm release..."
	-helm uninstall $(APP_NAME)

call:
	@kubectl rollout status deployment/$(APP_NAME) --timeout=60s
	@curl http://$$(minikube ip):$$(kubectl get svc $(APP_NAME) -o jsonpath='{.spec.ports[0].nodePort}')
