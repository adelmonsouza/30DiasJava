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
            .uri("/pricing/{sku}", sku)
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
        this.circuitBreaker = registry.circuitBreaker("pricing");
        this.webClient = webClient;
    }

    public Mono<PricingResponse> fetchPrice(String sku) {
        return Mono.fromCallable(() -> doFetchPrice(sku))
            .transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
            .onErrorResume(throwable -> Mono.just(fallbackPricing(sku)));
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

Fallbacks should degrade gracefully, not lie. Return cached data, a default response, or a "temporarily unavailable" message. Transparency prevents silent data corruption.

## Observability: Seeing the Breaker Work

Resilience4j publishes Micrometer metrics:

- `resilience4j_circuitbreaker_state`
- `resilience4j_circuitbreaker_calls{kind="failed"}`
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

