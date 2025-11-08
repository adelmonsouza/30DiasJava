package io.enouveau.testcontainers.order.events;

import java.time.OffsetDateTime;

public record OrderCreatedEvent(Long orderId, String sku, Integer quantity, OffsetDateTime createdAt) {
}

