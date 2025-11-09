package io.enouveau.resilience4j;

import io.github.resilience4j.circuitbreaker.CallNotPermittedException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.util.Map;

@RestController
@RequestMapping("/api/pricing")
public class PricingController {

    private final PricingClient pricingClient;

    public PricingController(PricingClient pricingClient) {
        this.pricingClient = pricingClient;
    }

    @GetMapping("/{sku}")
    public Mono<ResponseEntity<?>> getPrice(@PathVariable String sku) {
        return pricingClient.fetchPrice(sku)
                .map(ResponseEntity::ok)
                .onErrorResume(CallNotPermittedException.class,
                        ex -> Mono.just(ResponseEntity.status(503)
                                .body(Map.of("message", "Circuit breaker open", "sku", sku))))
                .onErrorResume(ex -> Mono.just(ResponseEntity.status(502)
                        .body(Map.of("message", ex.getMessage(), "sku", sku))));
    }
}
