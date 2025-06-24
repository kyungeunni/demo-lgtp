# Tempo & Prometheus 설치 가이드 (Helm)

## 1. Tempo 설치

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install tempo grafana/tempo \
  --namespace logging-demo \
  --set tempo.metricsGenerator.enabled=true \
  --set persistence.enabled=false
```

## 2. Prometheus 설치

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace logging-demo \
  --set server.persistentVolume.enabled=false
```

## 3. Grafana에서 데이터소스 추가
- Tempo: URL http://tempo:3100
- Prometheus: URL http://prometheus-server:80 