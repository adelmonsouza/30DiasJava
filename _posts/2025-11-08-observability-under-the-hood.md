---
layout: post
title: "Observability-Driven Alerting: How Prometheus and Alertmanager Prevent Silent Failures"
date: 2025-11-08 00:00:00 +0000
categories: Operations Spring Boot
permalink: /blog/2025/11/08/observability-under-the-hood.html
---

Hey there! Day 08 of #30DiasJava was all about answering one uncomfortable question: **How do we notice failures before our users do?** After playing with circuit breakers (Day 06) and async pipelines (Day 07), I wanted to dive into the detection layer — namely Prometheus, Alertmanager, and the instrumentation that feeds them.

**Disclaimer**: This is not an exhaustive observability guide. It’s a focused look at how metrics travel from a Spring Boot application to a pager alert, and the architectural choices we make along the way.

## Why I'm Looking at This

**Full disclosure**: I once shipped a feature that silently failed for three days. The service kept returning HTTP 200, but the response body was wrong. Monitoring only tracked JVM heap and CPU, so we missed it. Today I wanted to model a proper alert pipeline that catches both infrastructure and domain failures.

## The Observability Stack I Assembled

1. **Spring Boot Actuator** exporting Micrometer metrics.
2. **Prometheus** scraping `/actuator/prometheus`.
3. **Alertmanager** evaluating rules and routing alerts.
4. **Grafana** dashboards for human-friendly visualization.

## Under the Hood: Instrumenting the Service

### 1. Basic HTTP Metrics

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

This exposes default metrics like `http_server_requests_seconds`. Prometheus scrapes it, giving us latency histograms and status code counts.

### 2. Custom Business Metrics

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

This counter increments every time payment authorization fails. It’s our canary for domain health.

### 3. Prometheus Scrape Configuration

```yaml
scrape_configs:
  - job_name: 'order-service'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['orders-service.internal:8080']
```

Prometheus pulls metrics every 15 seconds, storing them with 1-second resolution for recent data and longer retention for trend analysis.

## Alerting Rules That Matter

### SLO-Oriented Latency Alert

```yaml
groups:
  - name: order-service.rules
    rules:
      - alert: HighCheckoutLatency
        expr: histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket{uri=\"/api/orders\"}[5m])) by (le)) > 0.5
        for: 10m
        labels:
          severity: page
        annotations:
          summary: "Checkout latency is above 500ms (p95)"
          description: "Investigate upstream payments and database load."
```

This alerts when the 95th percentile latency for `/api/orders` stays above 500 ms for 10 minutes. Tuning `for` avoids noisy flapping on short spikes.

### Domain Failure Alert

```yaml
- alert: CheckoutFailuresSpiking
  expr: increase(checkout_failed_total[5m]) > 20
  for: 5m
  labels:
    severity: page
  annotations:
    summary: "Checkout failures exceeded 20 in 5 minutes"
    description: "Potential payment provider outage or regression."
```

This catches spikes even if HTTP responses are still 200. Business KPIs become first-class citizens in our monitoring.

## Alert Routing and Noise Reduction

Alertmanager configuration:

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

- `group_wait`: batches related alerts triggered within 30 seconds.
- `repeat_interval`: avoids spamming on-call every minute.
- `group_by`: ensures all order-service alerts arrive in one page.

## Visualizing the Signals

In Grafana, I built a dashboard with panels for:

- `p95 latency` (PromQL: `histogram_quantile(0.95, sum(rate(...)) by (le))`)
- `checkout_failed_total` counter
- `kafka_consumer_lag` from Day 07’s async flow
- `resilience4j_circuitbreaker_state` from Day 06’s resilience work

This unified view showed how resilience patterns, async pipelines, and alerting reinforce each other.

## What Can We Learn From This?

1. **Unit economics of alerts matter** — only alert when humans must act.
2. **Domain metrics catch silent failures** way before infrastructure metrics do.
3. **Dashboards contextualize alerts** so on-call can respond faster.

## Final Thoughts

Observability is not a one-time setup. It’s a systems design discipline. Today’s experiment convinced me that:

1. Instrumentation should be part of feature acceptance criteria.
2. Alerting rules must encode business SLOs, not just server vitals.
3. Dashboards are storytelling tools for incidents — make them coherent.
4. Pairing resilience (Day 06) and async (Day 07) with observability (Day 08) closes the loop.

---

**Full project:** [Observability Stack (Day 08)](https://github.com/adelmonsouza/30DiasJava-Day08-Observability)

**Next article:** Coming soon — exploring feature flags and progressive delivery (Day 09)

---

**#30DiasJava | #SpringBoot | #Prometheus | #Alertmanager | #Observability**

