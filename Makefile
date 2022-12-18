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
	minikube image build -t kubernetes-app-blueprint:latest .

cluster-create:
	@echo "Starting Minikube cluster..."
	minikube start

cluster-destroy:
	@echo "Deleting Minikube cluster..."
	minikube delete

helm-deploy:
	@echo "Deploying or upgrading Helm release..."
	helm upgrade --install kubernetes-app-blueprint ./kubernetes-app-blueprint

helm-undeploy:
	@echo "Uninstalling Helm release..."
	-helm uninstall kubernetes-app-blueprint

call:
	@kubectl rollout status deployment/kubernetes-app-blueprint --timeout=60s
	@curl http://$$(minikube ip):$$(kubectl get svc kubernetes-app-blueprint -o jsonpath='{.spec.ports[0].nodePort}')
