package io.enouveau.testcontainers.order;

import io.enouveau.testcontainers.order.api.OrderRequest;
import io.enouveau.testcontainers.order.api.OrderResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

@Testcontainers
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class OrderControllerIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres =
            new PostgreSQLContainer<>("postgres:16-alpine")
                    .withDatabaseName("orders")
                    .withUsername("demo")
                    .withPassword("demo");

    @DynamicPropertySource
    static void configureDatasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void shouldPersistOrdersAgainstRealPostgresInstance() {
        OrderRequest request = new OrderRequest("checkout@enouveau.io", new BigDecimal("42.90"));

        ResponseEntity<OrderResponse> response =
                restTemplate.postForEntity("/api/orders", request, OrderResponse.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        OrderResponse body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.customerEmail()).isEqualTo("checkout@enouveau.io");
        assertThat(body.amount()).isEqualByComparingTo("42.90");

        OrderResponse[] persisted = restTemplate.getForObject("/api/orders", OrderResponse[].class);
        assertThat(persisted).isNotNull();
        assertThat(persisted).anySatisfy(order -> assertThat(order.customerEmail()).isEqualTo("checkout@enouveau.io"));
    }
}

