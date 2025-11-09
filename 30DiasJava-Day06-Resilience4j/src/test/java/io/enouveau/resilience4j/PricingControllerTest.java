package io.enouveau.resilience4j;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.reactive.server.WebTestClient;

@SpringBootTest
@AutoConfigureWebTestClient
class PricingControllerTest {

    @Autowired
    WebTestClient webTestClient;

    @Test
    @DisplayName("Should return 200 for pricing endpoint")
    void shouldReturnPrice() {
        webTestClient.get()
                .uri("/api/pricing/test")
                .exchange()
                .expectStatus().is2xxSuccessful();
    }
}
