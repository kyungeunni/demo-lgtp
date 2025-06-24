# Makefile for local k8s demo

NAMESPACE=logging-demo

.PHONY: all build images k8s-apply k8s-delete \
        helm-loki helm-grafana helm-tempo helm-prometheus \
        helm-delete-loki helm-delete-grafana helm-delete-tempo helm-delete-prometheus \
        port-forward-app1 port-forward-grafana

all: build images k8s-apply helm-loki helm-grafana helm-tempo helm-prometheus

build:
	cp gradlew app1/ || true
	cp -r gradle app1/ || true
	cd app1 && ./gradlew bootJar
	cp gradlew app2/ || true
	cp -r gradle app2/ || true
	cd app2 && ./gradlew bootJar

images:
	eval $$(minikube docker-env)
	docker build -t app1:latest ./app1
	docker build -t app2:latest ./app2

k8s-apply:
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -f k8s/otel-collector-config.yaml
	kubectl apply -f k8s/otel-collector-serviceaccount.yaml
	kubectl apply -f k8s/otel-collector-daemonset.yaml
	kubectl apply -f k8s/app1-deployment.yaml
	kubectl apply -f k8s/app2-deployment.yaml

k8s-delete:
	kubectl delete -f k8s/app1-deployment.yaml || true
	kubectl delete -f k8s/app2-deployment.yaml || true
	kubectl delete -f k8s/otel-collector-daemonset.yaml || true
	kubectl delete -f k8s/otel-collector-serviceaccount.yaml || true
	kubectl delete -f k8s/otel-collector-config.yaml || true
	kubectl delete namespace $(NAMESPACE) || true

helm-loki:
	helm repo add grafana https://grafana.github.io/helm-charts || true
	helm repo update
	helm upgrade --install loki grafana/loki-stack \
	  --namespace $(NAMESPACE) \
	  --create-namespace \
	  --set grafana.enabled=false

helm-grafana:
	helm upgrade --install grafana grafana/grafana \
	  --namespace $(NAMESPACE) \
	  --set persistence.enabled=true \
	  --set adminPassword=admin

helm-tempo:
	helm upgrade --install tempo grafana/tempo \
	  --namespace $(NAMESPACE) \
	  --set tempo.metricsGenerator.enabled=true \
	  --set persistence.enabled=false

helm-prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm repo update
	helm upgrade --install prometheus prometheus-community/prometheus \
	  --namespace $(NAMESPACE) \
	  --set server.persistentVolume.enabled=false

helm-delete-all: helm-delete-loki helm-delete-grafana helm-delete-tempo helm-delete-prometheus

helm-delete-loki:
	helm uninstall loki -n $(NAMESPACE) || true
helm-delete-grafana:
	helm uninstall grafana -n $(NAMESPACE) || true
helm-delete-tempo:
	helm uninstall tempo -n $(NAMESPACE) || true
helm-delete-prometheus:
	helm uninstall prometheus -n $(NAMESPACE) || true

port-forward-app1:
	kubectl port-forward svc/app1 8080:8080 -n $(NAMESPACE)

port-forward-grafana:
	kubectl port-forward svc/grafana 3000:80 -n $(NAMESPACE) 