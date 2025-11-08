package io.enouveau.testcontainers.order.api;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

public record OrderRequest(
        @Email @NotBlank String customerEmail,
        @NotNull @Positive BigDecimal amount
) {
}

