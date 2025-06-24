# Spring Boot + OpenTelemetry + Loki + Grafana 로그/트레이싱 데모

## 1. 구성도

- app1 → app2 호출 (Spring Boot)
- STDOUT(JSON, traceID 포함) 로그 출력
- Otel Collector(filelog receiver)가 /var/log/containers/*.log 수집
- Loki로 로그 전송, Grafana에서 traceID로 검색

## 2. 준비 사항
- JDK 21, Docker, kubectl, Helm 필요

## 3. 빌드 및 이미지 생성

```bash
cd app1 && ./gradlew bootJar && docker build -t app1:latest .
cd ../app2 && ./gradlew bootJar && docker build -t app2:latest .
```

## 4. 쿠버네티스 배포

```bash
kubectl create ns logging-demo
kubectl apply -f k8s/otel-collector-config.yaml
kubectl apply -f k8s/otel-collector-serviceaccount.yaml
kubectl apply -f k8s/otel-collector-daemonset.yaml
kubectl apply -f k8s/app1-deployment.yaml
kubectl apply -f k8s/app2-deployment.yaml
```

## 5. Loki & Grafana 설치

`k8s/loki-grafana-helm.md` 참고

## 6. 데모 확인

1. app1의 /hello 엔드포인트 호출 (예: port-forward 또는 Ingress)
2. Grafana에서 Loki 데이터소스 추가 (URL: http://loki:3100)
3. 로그에서 traceID로 검색

예시 쿼리:
```
{app="app1"} | json | traceId!=""
```

---

궁금한 점이나 추가 요청은 언제든 말씀해 주세요!
# demo-lgtp
