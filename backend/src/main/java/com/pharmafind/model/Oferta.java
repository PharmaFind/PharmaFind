package com.pharmafind.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record Oferta(
        int id,
        int medicamentoId,
        int farmaciaId,
        BigDecimal preco,
        boolean disponivel,
        LocalDateTime dataAtualizacao) {
}
