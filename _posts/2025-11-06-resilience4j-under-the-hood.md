---
layout: post
title: "Circuit Breakers in Spring Boot: How Resilience4j Protects Your APIs From Cascading Failures"
date: 2025-11-06 00:00:00 +0000
categories: Architecture Spring Boot
permalink: /blog/2025/11/06/resilience4j-under-the-hood.html
---

Hey there! Day 06 of #30DiasJava dropped me into the middle of a production-style failure. One external dependency slowed to a crawl, threads piled up, and the entire checkout flow started timing out. Today was about dissecting what a **circuit breaker** actually does inside a Spring Boot application, and why Resilience4j is more than just annotations.

**Disclaimer**: This is not a critique of any particular partner API or a silver bullet for stability. It’s an exploration of how architectural decisions either amplify failures or contain them.

## Why I'm Looking at This

**Full disclosure**: I used to assume retries would save the day. But in a real load test, every retry against a degraded dependency made the incident worse. That’s when I realized: a retry without a fuse is a self-inflicted DDoS.

So today’s goal was to wire Resilience4j into a Spring Boot service and trace what happens when we hit slow or failing downstream systems.

## The Anatomy of a Cascading Failure

Without protection:

```java
@Service
public class PricingClient {

    private final WebClient webClient;

    public Mono<PricingResponse> fetchPrice(String sku) {
        return webClient.get()
            .uri(\"/pricing/{sku}\", sku)
            .retrieve()
            .bodyToMono(PricingResponse.class); // ← Blocks until the upstream responds
    }
}
```

- Every slow request ties up a Tomcat thread.
- Retries multiply the pressure.
- Timeouts propagate upstream, collapsing the entire flow.

## Under the Hood: Resilience4j Circuit Breaker

### 1. Wiring the Breaker

```java
@Service
public class PricingClient {

    private final CircuitBreaker circuitBreaker;
    private final WebClient webClient;

    public PricingClient(CircuitBreakerRegistry registry, WebClient webClient) {
        this.circuitBreaker = registry.circuitBreaker(\"pricing\");
        this.webClient = webClient;
    }

    public Mono<PricingResponse> fetchPrice(String sku) {
        return Mono.fromCallable(() -> doFetchPrice(sku))
            .transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
            .onErrorResume(throwable -> Mono.just(fallbackPricing(sku)));
    }

    private PricingResponse doFetchPrice(String sku) {
        return webClient.get()
            .uri(\"/pricing/{sku}\", sku)
            .retrieve()
            .bodyToMono(PricingResponse.class)
            .block(Duration.ofSeconds(2));
    }
}
```

### 2. Sliding Window Metrics

Resilience4j keeps a rolling window of calls (configured in `resilience4j.circuitbreaker.instances.pricing`). It tracks:

- `failureRateThreshold` (e.g., 50%)
- `slowCallRateThreshold` (e.g., >2 seconds)
- `waitDurationInOpenState` (e.g., 30 seconds)

If half the calls in the window fail or exceed the slow threshold, the breaker opens and subsequent calls fail fast.

### 3. Combining With Bulkheads

Circuit breakers alone don’t free up threads. Pair them with a thread pool bulkhead:

```yaml
resilience4j:
  thread-pool-bulkhead:
    instances:
      pricing:
        maxThreadPoolSize: 20
        coreThreadPoolSize: 10
        queueCapacity: 20
```

Now, even if the downstream misbehaves, only a bounded pool of threads is affected.

### 4. Fallbacks That Tell the Truth

Fallbacks should degrade gracefully, not lie. Return cached data, a default response, or a \"temporarily unavailable\" message. Transparency prevents silent data corruption.

## Observability: Seeing the Breaker Work

Resilience4j publishes Micrometer metrics:

- `resilience4j_circuitbreaker_state`
- `resilience4j_circuitbreaker_calls{kind=\"failed\"}`
- `resilience4j_circuitbreaker_not_permitted_calls`

Scrape them with Prometheus, alert when the breaker stays open, and correlate with downstream SLIs.

## What Can We Learn From This?

- **Retries need guardrails** — pair them with circuit breakers or they multiply outages.
- **Bulkheads keep failures local** — isolate risky dependencies into their own pools.
- **Observability is mandatory** — without metrics, circuit breakers hide problems instead of surfacing them.

## Final Thoughts

Resilience patterns are not accessories. They are architectural commitments that keep customer-facing journeys alive when dependencies fail. Today’s experiment reminded me that resilience is about limiting blast radius, not eliminating failure.

---

**Full project:** [Resilience4j Playground (Day 06)](https://github.com/adelmonsouza/30DiasJava-Day06-Resilience4j)

**Next article:** Centralized Configuration in Spring Boot: How Spring Cloud Config Keeps Microservices Aligned (Day 07)

---

**#30DiasJava | #SpringBoot | #Resilience4j | #Architecture | #Reliability**
---
layout: post
title: "Circuit Breakers in Spring Boot: How Resilience4j Protects Your APIs From Cascading Failures"
date: 2025-11-06 00:00:00 +0000
categories: Architecture Spring Boot
permalink: /blog/2025/11/06/resilience4j-under-the-hood.html
---

Hey there! Day 06 of #30DiasJava took me deep into production failure scenarios. I wanted to understand how a single downstream timeout can bring down an entire cluster, and what really happens when we put a circuit breaker between Spring Boot and an unstable dependency.

**Disclaimer**: This is not a critique of any specific vendor or library. It's a reflection on architectural trade-offs when dealing with flaky dependencies, high-latency APIs, and the domino effect they can trigger. My goal is to expose what happens inside the runtime so we can design safer systems.

## Why I'm Looking at This

**Full disclosure**: I used to assume that retries were enough. If an API 500s, we try again, right? Except that's how we accidentally DDoS our own systems. After experiencing cascading failures in a staging environment, I spent this day exploring **Resilience4j** with circuit breaker, bulkhead, and rate limiter patterns to see how they actually intercept traffic.

## The Incident That Sparked This Deep Dive

During a load test, one upstream service (Pricing) started responding in ~8 seconds instead of ~120 ms. Our `order-service` kept calling it, threads piled up, Tomcat’s connection pool saturated, and suddenly the whole checkout flow stalled. Every retry made things worse. That’s when I realized:

> A retry without a fuse is a self-induced denial of service.

So today’s focus was: **How does a circuit breaker clamp down on failing dependencies before the rest of the platform collapses?**

## Under the Hood: What Resilience4j Actually Does

### 1. The Call Flow Without a Circuit Breaker

```java
@Service
public class PricingClient {
    private final WebClient webClient;

    public Mono<PricingResponse> fetchPrice(String sku) {
        return webClient.get()
            .uri("/pricing/{sku}", sku)
            .retrieve()
            .bodyToMono(PricingResponse.class); // ← Blocks until Pricing replies
    }
}
```

Without protection, every slow response occupies a request thread. If 200 requests arrive, Tomcat threads hit max, and the entire service stalls.

### 2. Wiring the Circuit Breaker

```java
@Service
public class PricingClient {
    private final CircuitBreaker circuitBreaker;
    private final WebClient webClient;

    public PricingClient(CircuitBreakerRegistry registry, WebClient webClient) {
        this.circuitBreaker = registry.circuitBreaker("pricing");
        this.webClient = webClient;
    }

    public Mono<PricingResponse> fetchPrice(String sku) {
        return Mono.fromCallable(() -> doFetchPrice(sku))
            .transformDeferred(CircuitBreakerOperator.of(circuitBreaker));
    }

    private PricingResponse doFetchPrice(String sku) {
        return webClient.get()
            .uri("/pricing/{sku}", sku)
            .retrieve()
            .bodyToMono(PricingResponse.class)
            .block(Duration.ofSeconds(2));
    }
}
```

With Resilience4j, every call flows through a state machine: **Closed → Open → Half-Open**. Timeouts and exceptions are recorded, and once a threshold is reached, the breaker flips to protect the downstream.

### 3. The Sliding Window Mechanics

Resilience4j maintains a rolling window:

- Size: e.g., 20 calls
- Failure rate threshold: e.g., 50%
- Slow call threshold: e.g., 2 seconds

When ≥ 10 calls fail or exceed the slow threshold, the breaker opens. Future calls are *short-circuited* (fail fast) for a configured wait duration (e.g., 30 seconds).

### 4. Thread Pools and Bulkheads

Circuit breakers alone don’t protect against thread starvation. So I combined them with a **bulkhead**:

```yaml
resilience4j:
  thread-pool-bulkhead:
    instances:
      pricing:
        maxThreadPoolSize: 20
        coreThreadPoolSize: 10
        queueCapacity: 20
```

This spawns an isolated thread pool. If Pricing goes rogue, it only consumes resources from this sub-pool, leaving the rest of the application responsive.

### 5. Fallbacks Without Lying to the User

```java
return Mono.fromCallable(() -> doFetchPrice(sku))
    .transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
    .onErrorResume(throwable -> Mono.just(defaultPricing(sku)));
```

Fallbacks should degrade gracefully — e.g., provide cached pricing or inform the UI to display “Temporarily unavailable”. The key is being explicit, not silent.

## Observability: Knowing When the Breaker Trips

Resilience4j integrates with Micrometer. Each breaker publishes metrics:

- `resilience4j_circuitbreaker_state`
- `resilience4j_circuitbreaker_calls`
- `resilience4j_circuitbreaker_not_permitted_calls`

With Prometheus + Grafana, I visualized:

1. When the breaker went OPEN
2. How many calls were blocked
3. The recovery window in Half-Open state

This visibility turned out to be crucial — it shows product managers what’s happening instead of leaving them guessing.

## What Can We Learn From This?

| Decision | Result |
|----------|--------|
| No circuit breaker, aggressive retries | Cascading failure, full downtime |
| Circuit breaker + bulkhead | Localized failure, service stays responsive |
| Circuit breaker + fallback | Predictable UX, fewer alerts at midnight |

Lessons:

1. A retry without a breaker amplifies failures.
2. Bulkheads isolate failures to a sub-pool, preserving the rest of the system.
3. Observability must accompany resilience to make incidents understandable.

## Final Thoughts

Circuit breakers are not magic. They add latency, require tuning, and can hide problems if you don’t instrument them. But today’s experiment showed they’re essential once your system talks to anything outside its control — payment gateways, partner APIs, internal microservices.

**Key takeaways:**

1. Circuit breakers protect your threads from being held hostage by slow dependencies.
2. Combine circuit breaker, bulkhead, and rate limiter for layered defense.
3. Always pair resilience patterns with clear fallbacks and metrics.
4. Embrace failure as a first-class scenario in architecture reviews.

---

**Full project:** [Resilience4j Playground (Day 06)](https://github.com/adelmonsouza/30DiasJava-Day06-Resilience4j)

**Next article:** Async Events and Message-Driven Design: How Spring Boot and Kafka Decouple Hot Paths (Day 07)

---

**#30DiasJava | #SpringBoot | #Resilience4j | #Architecture | #Observability**

