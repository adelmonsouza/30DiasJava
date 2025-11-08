package io.enouveau.testcontainers.order.events;

import io.enouveau.testcontainers.order.Order;
import org.springframework.context.ApplicationEvent;

public class OrderCreatedEvent extends ApplicationEvent {

    public OrderCreatedEvent(Order order) {
        super(order);
    }

    @Override
    public Order getSource() {
        return (Order) super.getSource();
    }
}

