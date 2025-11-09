package io.enouveau.observability;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/orders")
public class CheckoutController {

    private final Counter checkoutFailed;

    public CheckoutController(MeterRegistry meterRegistry) {
        this.checkoutFailed = Counter.builder("checkout_failed_total")
                .tag("reason", "payment")
                .description("Number of failed checkouts")
                .register(meterRegistry);
    }

    @PostMapping
    public ResponseEntity<?> checkout(@RequestBody Map<String, Object> payload) {
        if (Boolean.TRUE.equals(payload.get("forceFailure"))) {
            checkoutFailed.increment();
            return ResponseEntity.status(502).body(Map.of("status", "failed"));
        }
        return ResponseEntity.ok(Map.of("status", "ok"));
    }
}
