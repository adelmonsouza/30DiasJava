package io.enouveau.testcontainers.order.api;

import io.enouveau.testcontainers.order.Order;
import io.enouveau.testcontainers.order.OrderStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record OrderResponse(
        UUID id,
        String customerEmail,
        BigDecimal amount,
        OrderStatus status,
        Instant createdAt
) {

    public static OrderResponse from(Order order) {
        return new OrderResponse(
                order.getId(),
                order.getCustomerEmail(),
                order.getAmount(),
                order.getStatus(),
                order.getCreatedAt()
        );
    }
}

