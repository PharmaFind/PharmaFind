package com.pharmafind.model;

import java.math.BigDecimal;
import java.time.LocalTime;

public record Farmacia(
        int id,
        String nome,
        String endereco,
        String cep,
        BigDecimal latitude,
        BigDecimal longitude,
        LocalTime horarioAbertura,
        LocalTime horarioFechamento,
        Boolean delivery) {
}
