package io.enouveau.orderservice;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RefreshScope
@RestController
public class FeatureFlagController {

    @Value("${feature.checkout.express:false}")
    private boolean expressCheckout;

    @Value("${checkout.currency:EUR}")
    private String currency;

    @GetMapping("/feature-flags")
    public Map<String, Object> flags() {
        return Map.of(
                "expressCheckout", expressCheckout,
                "currency", currency
        );
    }
}
