# Resilience4j Chaos Playbook

## 1. Start services

```bash
./mvnw spring-boot:run
```

## 2. Happy-path request

```bash
curl http://localhost:8080/api/pricing/sku-123
```

## 3. Simulate load

```bash
hey -n 200 -c 20 http://localhost:8080/api/pricing/sku-999
```

Watch metrics:
- `resilience4j_circuitbreaker_state{}`
- `resilience4j_circuitbreaker_not_permitted_calls{}`

## 4. Grafana/Prometheus integration

See blog article for dashboard queries. Export metrics via `/actuator/prometheus`.
