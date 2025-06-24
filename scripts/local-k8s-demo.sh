#!/bin/bash
set -e

NAMESPACE=logging-demo

# 1. minikube 클러스터 시작
if ! minikube status >/dev/null 2>&1; then
  echo "[INFO] minikube 클러스터를 시작합니다..."
  minikube start --cpus=4 --memory=6g --driver=docker
else
  echo "[INFO] minikube가 이미 실행 중입니다."
fi

# 2. minikube Docker 데몬 사용
echo "[INFO] minikube Docker 환경으로 전환..."
eval $(minikube docker-env)

# 3. Spring Boot 앱 빌드 및 이미지 생성
for APP in app1 app2; do
  echo "[INFO] $APP 빌드 및 Docker 이미지 생성..."
  (cd $APP && ./gradlew bootJar && docker build -t $APP:latest .)
done

echo "[INFO] kubectl 네임스페이스 생성..."
kubectl get ns $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

# 4. k8s 매니페스트 적용
for YAML in otel-collector-config.yaml otel-collector-serviceaccount.yaml otel-collector-daemonset.yaml app1-deployment.yaml app2-deployment.yaml; do
  echo "[INFO] k8s/$YAML 적용..."
  kubectl apply -f k8s/$YAML
  sleep 1
done

# 5. Loki & Grafana 설치 (Helm)
if ! helm list -n $NAMESPACE | grep loki >/dev/null 2>&1; then
  echo "[INFO] Loki 설치..."
  helm repo add grafana https://grafana.github.io/helm-charts || true
  helm repo update
  helm upgrade --install loki grafana/loki-stack \
    --namespace $NAMESPACE \
    --create-namespace \
    --set grafana.enabled=false
else
  echo "[INFO] Loki가 이미 설치되어 있습니다."
fi

if ! helm list -n $NAMESPACE | grep grafana >/dev/null 2>&1; then
  echo "[INFO] Grafana 설치..."
  helm upgrade --install grafana grafana/grafana \
    --namespace $NAMESPACE \
    --set persistence.enabled=true \
    --set adminPassword=admin
else
  echo "[INFO] Grafana가 이미 설치되어 있습니다."
fi

echo "[INFO] 모든 리소스가 배포되었습니다!"
echo "[INFO] app1 포트포워딩: kubectl port-forward svc/app1 8080:8080 -n $NAMESPACE"
echo "[INFO] Grafana 포트포워딩: kubectl port-forward svc/grafana 3000:80 -n $NAMESPACE" 