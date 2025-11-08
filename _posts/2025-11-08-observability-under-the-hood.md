---
layout: post
title: "Observability-Driven Alerting: How Prometheus and Alertmanager Prevent Silent Failures"
date: 2025-11-08 00:00:00 +0000
categories: Operations Spring Boot
permalink: /blog/2025/11/08/observability-under-the-hood.html
---

Hey there! Day 08 of #30DiasJava was about answering one uncomfortable question: **How do we spot failures before customers tweet about them?** After exploring circuit breakers (Day 06) and async workflows (Day 07), I turned to the detection layer — Prometheus, Alertmanager, and the instrumentation that feeds them.

**Disclaimer**: This is not a full observability guide. It’s a focused look at how Spring Boot metrics become actionable alerts, with everything based on the official Spring documentation and Prometheus best practices.

## Why I'm Looking at This

**Full disclosure**: I once deployed a feature that returned HTTP 200 with the wrong payload for three days. CPU, memory, and uptime were green. We only noticed when users complained. So today I wanted to build alerting around **domain health**, not just infrastructure.

## The Observability Stack

1. Spring Boot Actuator exporting Micrometer metrics (`/actuator/prometheus`).
2. Prometheus scraping metrics on a 15-second cadence.
3. Alertmanager evaluating rules and triggering PagerDuty.
4. Grafana dashboards stitching everything together.

## Under the Hood: Instrumenting the Service

### 1. Spring Boot Configuration

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
  metrics:
    tags:
      application: order-service
```

This exposes HTTP metrics (`http_server_requests_seconds`) with an `application` tag for multi-service environments.

### 2. Custom Domain Metrics

```java
@Component
public class CheckoutMetrics {

    private final Counter failedOrders;

    public CheckoutMetrics(MeterRegistry registry) {
        failedOrders = Counter.builder("checkout_failed_total")
            .tag("reason", "payment")
            .description("Number of failed checkouts")
            .register(registry);
    }

    public void onPaymentFailure() {
        failedOrders.increment();
    }
}
```

Now we can alert when payment failures spike, even if HTTP status codes stay 200.

### 3. Prometheus Scrape Job

```yaml
scrape_configs:
  - job_name: 'order-service'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['order-service.internal:8080']
```

Prometheus persists metrics with timestamped samples, enabling both real-time alerts and historical investigations.

## Alert Rules That Matter

### SLO-Based Latency Alert

```yaml
- alert: HighCheckoutLatency
  expr: histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket{uri="/api/orders"}[5m])) by (le)) > 0.5
  for: 10m
  labels:
    severity: page
  annotations:
    summary: "Checkout p95 latency above 500ms"
    description: "Investigate upstream payment latency or database contention."
```

### Business-Failure Alert

```yaml
- alert: CheckoutFailuresSpiking
  expr: increase(checkout_failed_total[5m]) > 20
  for: 5m
  labels:
    severity: page
  annotations:
    summary: "Checkout failures exceeded 20 in 5 minutes"
    description: "Potential payment outage or regression."
```

### Alert Routing Discipline

```yaml
route:
  receiver: 'oncall'
  group_by: ['service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 2h

receivers:
  - name: 'oncall'
    pagerduty_configs:
      - routing_key: ${PAGERDUTY_KEY}
```

Grouping and repeat intervals prevent alert storms while keeping on-call informed.

## Dashboards as Incident Maps

In Grafana, I built panels for:

- `p95 latency` per endpoint.
- `checkout_failed_total` (domain health).
- `kafka_consumer_lag` (from Day 07 experiments).
- `resilience4j_circuitbreaker_state` (Day 06).

This cross-links resilience, async processing, and alerting into a single incident map.

## What Can We Learn From This?

1. **Metrics without alerting are passive.** Alerts codify what matters for the business.
2. **Domain metrics detect silent failures** before infrastructure metrics react.
3. **Dashboards tell the story** — they stitch resilience, async workloads, and alerts together.

## Final Thoughts

Observability is an architectural decision. It’s part of the product, not just operations. Today drove home that resilience patterns (Day 06) and async pipelines (Day 07) only work if we can **see** when they fail.

**Key takeaways:**

1. Expose Micrometer metrics via Actuator and enrich them with domain tags.
2. Alert on SLOs and domain signals, not just CPU and memory.
3. Route alerts responsibly — reduce noise, increase clarity.
4. Document dashboards and runbooks as part of the release.

---

**Full project:** [Observability Stack (Day 08)](https://github.com/adelmonsouza/30DiasJava-Day08-Observability)

**Next article:** Coming soon — Feature Flags and Progressive Delivery in Spring Boot (Day 09)

---

**#30DiasJava | #SpringBoot | #Prometheus | #Alertmanager | #Observability**

