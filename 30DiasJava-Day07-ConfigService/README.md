# Day 07 — Spring Cloud Config Service

Part of the **#30DiasJava** challenge. This repository demonstrates how to externalize configuration using Spring Cloud Config, a Git-backed configuration repository, and secure refresh flows, as described in the blog post [Centralized Configuration in Spring Boot: How Spring Cloud Config Keeps Microservices Aligned](https://enouveau.io/blog/2025/11/07/config-server-under-the-hood.html).

## Modules

- `config-server` — Spring Cloud Config Server exposing properties via HTTPS-ready endpoints.
- `order-service` — Sample Spring Boot client using `spring.config.import` and `@RefreshScope`.
- `config-repo` — Example Git repository structure with encrypted secrets.

## Quickstart

1. Start the config server:
   ```bash
   cd config-server
   ./mvnw spring-boot:run
   ```
2. Start the sample client:
   ```bash
   cd ../order-service
   ./mvnw spring-boot:run
   ```
3. Fetch feature flags:
   ```bash
   curl http://localhost:8081/feature-flags
   ```

## Content Ecosystem

| Platform | Link |
|----------|------|
| Blog     | https://enouveau.io/blog/2025/11/07/config-server-under-the-hood.html |
| GitHub   | https://github.com/adelmonsouza/30DiasJava-Day07-ConfigService |
| LinkedIn | (soon) |

See `docs/SECURITY_CHECKLIST.md` for production hardening steps.
