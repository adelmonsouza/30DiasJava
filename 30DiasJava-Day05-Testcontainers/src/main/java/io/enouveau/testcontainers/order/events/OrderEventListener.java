package io.enouveau.testcontainers.order.events;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
public class OrderEventListener {

    private static final Logger log = LoggerFactory.getLogger(OrderEventListener.class);

    @EventListener
    public void handle(OrderCreatedEvent event) {
        log.info("Order {} created for {}", event.getSource().getId(), event.getSource().getCustomerEmail());
    }
}

