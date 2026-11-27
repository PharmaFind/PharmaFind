package com.pharmafind.model;

import java.math.BigDecimal;
import java.time.Instant;

public record Oferta(
        int id,
        int medicamentoId,
        int farmaciaId,
        BigDecimal preco,
        boolean disponivel,
        Instant dataAtualizacao) {
}
