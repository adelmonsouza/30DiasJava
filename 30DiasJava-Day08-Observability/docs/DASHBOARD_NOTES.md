# Grafana Dashboard Notes

Panels used in the blog article:

1. **Checkout p95 Latency**
   ```promql
   histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket{uri="/api/orders",method="post"}[5m])) by (le))
   ```
2. **Checkout Failures Counter**
   ```promql
   increase(checkout_failed_total[5m])
   ```
3. **Kafka Lag Placeholder**
   Use `kafka_consumer_records_lag_max` if integrating with Kafka (optional).
4. **Circuit Breaker State**
   Combine with Day 06 metrics: `resilience4j_circuitbreaker_state`.

Import the JSON dashboard template in `monitoring/grafana/dashboard.json` (create file when exporting from Grafana).
