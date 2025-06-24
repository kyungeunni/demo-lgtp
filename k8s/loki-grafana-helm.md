# Loki & Grafana 설치 가이드 (Helm)

## 1. Helm 저장소 추가

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## 2. Loki 설치

```bash
helm upgrade --install loki grafana/loki-stack \
  --namespace logging-demo \
  --create-namespace \
  --set grafana.enabled=false
```

## 3. Grafana 설치

```bash
helm upgrade --install grafana grafana/grafana \
  --namespace logging-demo \
  --set persistence.enabled=true \
  --set adminPassword=admin
```

## 4. Grafana 접속

```bash
kubectl port-forward svc/grafana 3000:80 -n logging-demo
```

브라우저에서 http://localhost:3000 접속 (ID: admin / PW: admin)

## 5. Grafana에서 Loki 데이터소스 추가
- URL: http://loki:3100 