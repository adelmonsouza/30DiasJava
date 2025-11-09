# Day 06 — Resilience4j Playground

This project is part of the **#30DiasJava** challenge. It implements Resilience4j circuit breaker and bulkhead patterns to protect Spring Boot APIs from cascading failures, following the lessons shared in the blog post [Circuit Breakers in Spring Boot: How Resilience4j Protects Your APIs From Cascading Failures](https://enouveau.io/blog/2025/11/06/resilience4j-under-the-hood.html).

## Stack

- Java 21
- Spring Boot 3.2
- Spring WebFlux
- Resilience4j (circuit breaker + bulkhead)
- Micrometer / Actuator
- Docker Compose (optional dependencies)

## Getting Started

```bash
./mvnw spring-boot:run
```

Endpoints:
- `GET /api/pricing/{sku}` — returns product pricing with Resilience4j protection.
- `GET /actuator/health` — Actuator health check.

See `docs/PLAYBOOK.md` for scripts, curl examples, and chaos testing scenarios.

## Content Ecosystem

| Platform | Link |
|----------|------|
| Blog     | https://enouveau.io/blog/2025/11/06/resilience4j-under-the-hood.html |
| GitHub   | https://github.com/adelmonsouza/30DiasJava-Day06-Resilience4j |
| LinkedIn | (soon) |

## License

Apache License 2.0.
