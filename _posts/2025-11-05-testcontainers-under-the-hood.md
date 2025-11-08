---
layout: post
title: "Integration Tests Without Flaky Environments: How Testcontainers Keeps Spring Boot Reproducible"
date: 2025-11-05 00:00:00 +0000
categories: Testing Spring Boot
permalink: /blog/2025/11/05/testcontainers-under-the-hood.html
---

Hey there! Day 05 of #30DiasJava was all about banishing the phrase “works on my machine” from our integration tests. I wanted to understand how **Testcontainers** actually spins up disposable infrastructure for Spring Boot, and what happens under the hood when we swap mocks for real PostgreSQL + Kafka instances during the build.

**Disclaimer**: This isn’t a sponsored take on Testcontainers or a promise that Docker solves every testing problem. It’s a look at the trade-offs when we rely on containerized dependencies for reliable integration tests.

## Why I'm Looking at This

**Full disclosure**: I’ve shipped features that passed CI but failed in staging because mocks hid subtle schema issues. After the third “surprise” bug, I promised myself to make integration tests use the same stack production does. Today’s focus: wiring Testcontainers into a Spring Boot app and measuring the developer experience.

## The Baseline: Mocked Data Sources

Typical test setup:

```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class OrderServiceTest {

    @Autowired
    private OrderService orderService;

    @Test
    void shouldCreateOrder() {
        OrderRequest request = new OrderRequest("SKU-123", 2);
        Order order = orderService.createOrder(request);
        assertThat(order.getStatus()).isEqualTo(OrderStatus.CREATED);
    }
}
```

- Uses H2 in-memory database.
- Perfect for fast tests, but it doesn’t catch migration or dialect issues (e.g., JSONB columns in PostgreSQL).

## Under the Hood: Testcontainers + Spring Boot

### 1. Spinning Up PostgreSQL

```java
@Testcontainers
@SpringBootTest
class OrderServiceIT {

    @Container
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:16-alpine")
            .withDatabaseName("orders")
            .withUsername("tester")
            .withPassword("tester");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
```

- `@Container` starts PostgreSQL before tests run.
- `@DynamicPropertySource` injects the container’s runtime URL/credentials into Spring Boot.
- No need to check in docker-compose or maintain local DB scripts.

### 2. Lifecycle Details

1. Testcontainers launches a lightweight control container (Ryuk) to manage cleanup.
2. It pulls `postgres:16-alpine` if not cached.
3. Starts PostgreSQL, waits for readiness via health check.
4. Injects connection parameters into the test context.
5. Automatically tears down the container at the end of the test run.

### 3. Adding Kafka for Event Tests

```java
@Container
static KafkaContainer kafka = new KafkaContainer("confluentinc/cp-kafka:7.6.0");

@DynamicPropertySource
static void kafkaProps(DynamicPropertyRegistry registry) {
    registry.add("spring.kafka.bootstrap-servers", kafka::getBootstrapServers);
}
```

This lets us assert against actual topics:

```java
Awaitility.await()
    .atMost(Duration.ofSeconds(5))
    .untilAsserted(() ->
        assertThat(kafkaTestConsumer.poll()).contains("order-created"));
```

## Developer Experience: Speed vs. Fidelity

| Scenario | Duration | Confidence |
|----------|----------|------------|
| In-memory H2 + mocks | ~3 seconds | Low (dialect drift) |
| Testcontainers PostgreSQL | ~12 seconds | High |
| Testcontainers PostgreSQL + Kafka | ~18 seconds | High |

> The startup cost is visible but manageable. We can run the full suite in CI and a smoke subset locally using tags.

### Optimising Runtime

- Reuse containers across tests with `@Testcontainers` + static fields.
- Enable Ryuk to auto-clean resources (default).
- Use `testcontainers.reuse.enable=true` for local dev to keep containers alive between runs (requires opt-in).

## CI/CD Considerations

1. **Docker availability**: CI agents must have Docker or a compatible runtime.
2. **Caching images**: Pre-pull images (`postgres`, `confluentinc/cp-kafka`) in the pipeline to cut cold start time.
3. **Resource limits**: Configure memory/CPU thresholds if running multiple suites in parallel.
4. **Secrets**: Use environment variables or CI secret providers for credentials even in test containers.

## What Can We Learn From This?

1. **Parity beats mocks**: Running against PostgreSQL+Kafka uncovers issues before staging.
2. **Startup cost is predictable**: We can budget 15–20 seconds for high-fidelity tests.
3. **Infrastructure as code extends to tests**: Container definitions become part of our testing policy.

## Final Thoughts

Testcontainers isn’t just a testing library; it’s a discipline. We accept slightly longer test runs in exchange for catching broken migrations, misconfigured serializers, and integration bugs early. For Day 05, that trade-off is worth it.

**Key takeaways:**

1. Disposable containers ensure each test run starts from a clean slate.
2. Dynamic property injection keeps Spring Boot unaware of the orchestration behind it.
3. CI pipelines must be Docker-aware to fully benefit from Testcontainers.
4. Document which containers are required and how to update their versions.

---

**Full project:** [Testcontainers Playbook (Day 05)](https://github.com/adelmonsouza/30DiasJava-Day05-Testcontainers)

**Next article:** Circuit Breakers in Spring Boot: How Resilience4j Protects Your APIs From Cascading Failures (Day 06)

---

**#30DiasJava | #SpringBoot | #Testcontainers | #IntegrationTesting | #DevOps**

