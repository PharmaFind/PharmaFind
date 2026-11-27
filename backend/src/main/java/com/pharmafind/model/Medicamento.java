package com.pharmafind.model;

public record Medicamento(
        int id,
        String nome,
        String principioAtivo,
        String categoria,
        String dosagem,
        String descricao,
        String apresentacao) {
}
