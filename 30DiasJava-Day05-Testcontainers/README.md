# 🚀 Testcontainers Playbook

**Day 05 of #30DiasJava — Integration tests with real infrastructure**

---

## 📌 Overview

This repository is part of the **#30DiasJava** challenge: 30 production-grade Java/Spring Boot projects inspired by real-world architecture patterns.

- **Day:** 05
- **Project:** Testcontainers Playbook
- **Blog article:** [Integration Tests Without Flaky Environments: How Testcontainers Keeps Spring Boot Reproducible](https://enouveau.io/blog/2025/11/05/testcontainers-under-the-hood.html)
- **Tech Focus:** Spring Boot, Testcontainers, PostgreSQL, Kafka

---

## 🧠 Problem Statement

Integration tests that rely on in-memory databases or mocks often miss issues that surface in staging: incompatible SQL, missing migrations, serializers that fail against real brokers. This project demonstrates how to run Spring Boot integration tests against disposable PostgreSQL and Kafka instances using Testcontainers, keeping the feedback loop fast while matching production infrastructure.

---

## 🏗️ Architecture Highlights

- Runs PostgreSQL 16 and Kafka 7.x in disposable containers for every test suite.
- Uses `@DynamicPropertySource` to inject runtime connection details into Spring Boot without hardcoding URLs.
- Provides a sample domain (`OrderService`) plus integration tests that verify persistence and messaging end-to-end.

> Detailed explanations and architectural decisions are documented in the companion blog post.

---

## 🧪 Running Locally

```bash
# 1. Pre-requisites: Docker running + Java 21 + Maven 3.9+

# 2. Clone the repo
git clone https://github.com/adelmonsouza/30DiasJava-Day05-Testcontainers.git
cd 30DiasJava-Day05-Testcontainers

# 3. Run the full integration test suite (starts Testcontainers)
mvn clean verify

# 4. Optional: Run the application
docker compose up -d postgres
SPRING_PROFILES_ACTIVE=local mvn spring-boot:run
```

- The `local` profile starts the app against the Docker Compose PostgreSQL instance (see `docker-compose.yml`).
- Integration tests spin up their own containers automatically; no manual services are required.

---

## ✅ Quality Gates

| Check | Status | Command |
|-------|--------|---------|
| Tests | ☐ Pending | `mvn clean verify` |
| Lint / Static Analysis | ☐ Pending | `mvn -Pcode-quality verify` |
| Security Scan | ☐ Pending | `./pre-golive.sh 30DiasJava-Day05-Testcontainers` |

> Before publishing the article, ensure all quality checks are green.

---

## 📚 References

- Blog article: [Integration Tests Without Flaky Environments: How Testcontainers Keeps Spring Boot Reproducible](https://enouveau.io/blog/2025/11/05/testcontainers-under-the-hood.html)
- Testcontainers Docs: https://testcontainers.com/guides/getting-started-with-testcontainers-for-java/
- Spring Boot Testing: https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#testing
- PostgreSQL JDBC Driver: https://jdbc.postgresql.org/documentation/
- Challenge hub: [30DiasJava](https://github.com/adelmonsouza/30DiasJava)

---

## 🤝 Contributing

This repository is part of a learning journey. Issues and suggestions are welcome via the main hub: [30DiasJava](https://github.com/adelmonsouza/30DiasJava).

---

## 📄 License

MIT License. See `LICENSE` for details (add the file if needed).


