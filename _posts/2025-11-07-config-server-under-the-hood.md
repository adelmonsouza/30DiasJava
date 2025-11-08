---
layout: post
title: "Centralized Configuration in Spring Boot: How Spring Cloud Config Keeps Microservices Aligned"
date: 2025-11-07 00:00:00 +0000
categories: Architecture Spring Boot
permalink: /blog/2025/11/07/config-server-under-the-hood.html
---

Hey there! Day 07 of #30DiasJava pushed me into one of those hidden architectural puzzles: **How do we keep configuration consistent across multiple Spring Boot services without leaking secrets or burning out ops teams?** Today I explored Spring Cloud Config, Git-backed properties, dynamic refresh, and the security guardrails we need to make it production-grade.

**Disclaimer**: This post is not a tutorial on how to copy Oracle Cloud or Netflix OSS setups. It’s a look at the trade-offs and inner workings of externalized configuration based on Spring’s official documentation and my own hands-on experiments.

## Why I'm Looking at This

**Full disclosure**: I used to manage properties per service. It was fine until the third microservice. Then we started versioning YAML with copy/paste, setting feature flags manually, and forgetting to revert temporary overrides. Production drifted from staging — not fun. So today I wanted to see how a centralized configuration server actually changes the runtime story.

## Architecture at a Glance

1. **Spring Cloud Config Server** serving YAML via HTTP-backed Git.
2. **Private configuration repository** with `application.yml` + profile-specific files.
3. **Clients loading config via `spring.config.import=optional:configserver:`**.
4. **Runtime refresh** with `@RefreshScope` and Spring Boot Actuator.
5. **Secret handling** using Docker/Kubernetes secrets and encrypted storage.

## Under the Hood: Spring Cloud Config Server

### 1. Bootstrapping the Server

```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
```

The server exposes endpoints like `/application/default` or `/order-service/prod`. Spring Cloud Config pulls files from Git on demand (or caches them based on `spring.cloud.config.server.git.cloneOnStart`).

### 2. Git-Backed Configuration

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: git@github.com:adelmonsouza/config-repo.git
          default-label: main
          private-key: ${CONFIG_GIT_PRIVATE_KEY}
          search-paths: order-service, inventory-service
server:
  port: 8888
```

Key detail: the server never stores credentials. The repo remains private; access is enforced via deploy keys or GitHub App tokens.

### 3. Serving Profiles

Given a repo structure like:

```
config-repo/
  order-service/
    application.yml
    application-dev.yml
    application-prod.yml
```

A GET request to `/order-service/dev` returns a merged document. Spring Cloud Config uses the same property resolution rules as Spring Boot (see [Spring Cloud Config docs](https://docs.spring.io/spring-cloud-config/docs/current/reference/html/)).

## Client-Side Integration

### Using `spring.config.import`

```yaml
spring:
  application:
    name: order-service
  config:
    import: "optional:configserver:http://config-server:8888"
```

This tells the Spring Boot client to fetch remote properties during startup. If the server is unavailable, the `optional:` flag allows booting with local defaults.

### Dynamic Refresh with `@RefreshScope`

```java
@RefreshScope
@RestController
public class FeatureFlagController {

    @Value("${feature.checkout.express:false}")
    private boolean expressCheckout;

    @GetMapping("/feature-flags")
    public Map<String, Object> flags() {
        return Map.of("expressCheckout", expressCheckout);
    }
}
```

When we update `feature.checkout.express` in Git and trigger `POST /actuator/refresh`, Spring Cloud Config repopulates the bean without a restart. This uses Spring Boot Actuator under the hood (see [Spring Boot Reference Guide](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)).

## Security and Secret Hygiene

### 1. Secure Transport

- Enforce HTTPS between clients and Config Server (`server.ssl.*` settings).
- Restrict exposure with network policies or service mesh mTLS.
- Authentication options: HTTP Basic, OAuth2, or mutual TLS.

### 2. Secret Storage

- Store credentials in Docker/Kubernetes secrets; mount them as environment variables.
- Reference them in `bootstrap.yml` via `${ENV_VAR}` placeholders.
- For encrypted values, use Spring Cloud Config’s [encrypt/decrypt endpoints](https://docs.spring.io/spring-cloud-config/docs/current/reference/html/#_encryption_and_decryption). Example:

```bash
echo 'mySecretValue' | curl -X POST --data-binary @- http://config-server:8888/encrypt
```

### 3. Production Hardening Checklist

1. Limit Actuator exposure: only expose `health` and `info` publicly.
2. Lock down `/actuator/refresh` behind authentication.
3. Enable Git commit signing to ensure config integrity.
4. Automate scans for plaintext secrets before pushing to the config repo.

## Docker Compose Setup

```yaml
services:
  config-server:
    build: ./config-server
    ports:
      - "8888:8888"
    environment:
      CONFIG_GIT_PRIVATE_KEY: /run/secrets/config_git_key
    secrets:
      - config_git_key

  order-service:
    build: ./order-service
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://config-server:8888
      SPRING_PROFILES_ACTIVE: dev
```

With Docker secrets, the private key never touches the image; it’s provided at runtime.

## Observability Hooks

- Add Prometheus metrics for refresh events: monitor `spring.cloud.config.requests`.
- Use log correlation (trace IDs) to audit config changes. Combine with Git commit metadata.
- Alert when config server availability drops or when property refresh fails.

## What Can We Learn From This?

1. **Centralized configs turn change management into version control.** Every change is traceable.
2. **Security is a process**, not a checkbox — encrypted secrets, TLS, and limited endpoints are mandatory.
3. **Dynamic refresh requires discipline**: only mark beans with `@RefreshScope` when safe to reload at runtime.

## Final Thoughts

Externalizing configuration is about more than convenience. It’s an architectural play: consistency across environments, safer rollouts, and less human error.

**Key takeaways:**

1. Spring Cloud Config leverages Git semantics for configuration drift control.
2. Dynamic refresh empowers teams to toggle features without redeploying.
3. Secrets must remain outside Git history — use Docker/Kubernetes secrets or dedicated vaults.
4. Document changes; treat configuration as part of your release notes.

---

**Full project:** [Centralized Config Service (Day 07)](https://github.com/adelmonsouza/30DiasJava-Day07-ConfigService)

**Next article:** Observability-Driven Alerting: How Prometheus and Alertmanager Prevent Silent Failures (Day 08)

---

**#30DiasJava | #SpringBoot | #ConfigServer | #DevOps | #Security | #Microservices**
