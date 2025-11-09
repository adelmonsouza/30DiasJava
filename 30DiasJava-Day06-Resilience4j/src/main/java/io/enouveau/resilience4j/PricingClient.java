package io.enouveau.resilience4j;

import io.github.resilience4j.bulkhead.annotation.Bulkhead;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.timelimiter.annotation.TimeLimiter;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.Random;

@Component
public class PricingClient {

    private final Random random = new Random();

    @CircuitBreaker(name = "pricing")
    @TimeLimiter(name = "pricing")
    @Bulkhead(name = "pricing")
    public Mono<PricingResponse> fetchPrice(String sku) {
        return simulateExternalCall(sku);
    }

    private Mono<PricingResponse> simulateExternalCall(String sku) {
        return Mono.defer(() -> {
            int latency = random.nextInt(1500);
            if (latency > 1000) {
                return Mono.delay(Duration.ofMillis(latency))
                        .then(Mono.error(new RuntimeException("Upstream timeout")));
            }
            return Mono.delay(Duration.ofMillis(latency))
                    .thenReturn(new PricingResponse(sku, latency / 100.0));
        });
    }

    public record PricingResponse(String sku, double price) {}
}
