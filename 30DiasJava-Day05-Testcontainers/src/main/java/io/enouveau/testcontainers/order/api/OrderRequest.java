package io.enouveau.testcontainers.order.api;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record OrderRequest(
        @NotBlank String sku,
        @Min(1) Integer quantity
) {
}

