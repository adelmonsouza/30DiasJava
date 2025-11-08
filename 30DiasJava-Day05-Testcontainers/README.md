# 🚀 Testcontainers Playbook

**Day 05 of #30DiasJava — Integration tests with real infrastructure**

---

## 📌 Overview

This repository is part of the **#30DiasJava** challenge: 30 production-grade Java/Spring Boot projects inspired by real-world architecture patterns.

- **Day:** 05
- **Project:** Testcontainers Playbook
- **Blog article:** [Integration Tests Without Flaky Environments: How Testcontainers Keeps Spring Boot Reproducible](https://enouveau.io/blog/2025/11/05/testcontainers-under-the-hood.html)
- **Tech Focus:** Spring Boot, Testcontainers, PostgreSQL

---

## 🧠 Problem Statement

Legacy integration tests often rely on shared QA databases that drift from production, making regressions hard to reproduce and eroding trust in the deployment pipeline. We need a repeatable way to provision disposable infrastructure so every developer, PR, and CI job can verify behaviour against a real PostgreSQL instance—without maintaining brittle scripts or manual set-up steps.

---

## 🏗️ Architecture Highlights

- Spring Boot API that persists `Order` aggregates in PostgreSQL using JPA, keeping production parity with the service we test.
- Testcontainers-powered integration tests spin up PostgreSQL 16 on-demand and wire its connection details via `@DynamicPropertySource`, eliminating environment drift.
- Docker Compose mirrors the same topology for local runs, so developers and CI observe the exact same infrastructure contract.

> Detailed explanations and architectural decisions are documented in the companion blog post.

---

## 🧪 Running Locally

```bash
# 1. Clone the repo
git clone https://github.com/adelmonsouza/30DiasJava-Day05-Testcontainers.git
cd 30DiasJava-Day05-Testcontainers

# 2. Start PostgreSQL (optional if you already have a local instance)
docker compose up -d

# 3. Run the Spring Boot API
./mvnw spring-boot:run

# 4. Run the Testcontainers-powered integration tests
./mvnw test
```

> Tip: CI can rely on `./mvnw test` without provisioning Docker in advance because Testcontainers manages the lifecycle of PostgreSQL automatically.
>
> You need a container runtime (Docker Desktop, Colima, Rancher Desktop, or Podman with Docker compatibility) running locally for the integration tests to pass.

---

## ✅ Quality Gates

| Check | Status | Command |
|-------|--------|---------|
| Tests | ☐ Pending | `./mvnw test` |
| Lint / Static Analysis | ☐ Pending | `./mvnw verify` |
| Security Scan | ☐ Pending | `../pre-golive.sh 30DiasJava-Day05-Testcontainers` |

> Before publishing the article, ensure all quality checks are green.

---

## 📚 References

- Blog article: [Integration Tests Without Flaky Environments: How Testcontainers Keeps Spring Boot Reproducible](https://enouveau.io/blog/2025/11/05/testcontainers-under-the-hood.html)
- Tech docs:
  - [Testcontainers for Java](https://testcontainers.com/guides/getting-started-with-testcontainers-for-java/)
  - [Spring Boot + Testcontainers documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#features.testing.testcontainers)
  - [PostgreSQL JDBC Driver](https://jdbc.postgresql.org/)
- Challenge hub: [30DiasJava](https://github.com/adelmonsouza/30DiasJava)

---

## 🤝 Contributing

This repository is part of a learning journey. Issues and suggestions are welcome via the main hub: [30DiasJava](https://github.com/adelmonsouza/30DiasJava).

---

## 📄 License

MIT License. See `LICENSE` for details (add the file if needed).


