# Day 08 — Observability Stack

Repository for the **#30DiasJava** challenge, highlighting Prometheus + Alertmanager + Grafana with Spring Boot Actuator metrics, as detailed in the blog post [Observability-Driven Alerting: How Prometheus and Alertmanager Prevent Silent Failures](https://enouveau.io/blog/2025/11/08/observability-under-the-hood.html).

## Components

- `orders-service` — Spring Boot app with custom Micrometer counters.
- `monitoring/docker-compose.yml` — Prometheus, Alertmanager, and Grafana stack.
- `monitoring/prometheus` — Scrape configs and alerting rules aligned with the blog.

## Quickstart

```bash
# terminal 1
cd orders-service
./mvnw spring-boot:run

# terminal 2
cd monitoring
docker compose up
```

Access:
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- Grafana: http://localhost:3000 (admin/admin)

## Content Ecosystem

| Platform | Link |
|----------|------|
| Blog     | https://enouveau.io/blog/2025/11/08/observability-under-the-hood.html |
| GitHub   | https://github.com/adelmonsouza/30DiasJava-Day08-Observability |
| LinkedIn | (soon) |

See `docs/DASHBOARD_NOTES.md` for Grafana panel queries.
