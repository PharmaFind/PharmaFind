package com.pharmafind.repository;

import com.pharmafind.model.Oferta;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.mockito.ArgumentMatchers;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class OfertaRepositoryTest {

    @Test
    void listaSomenteOfertasDoMedicamentoInformadoUsandoParametro() {
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        Oferta esperada = new Oferta(5001, 1001, 2001, new BigDecimal("8.99"), true, null);
        when(jdbcTemplate.query(any(String.class), ArgumentMatchers.<RowMapper<Oferta>>any(), eq(1001)))
                .thenReturn(List.of(esperada));

        List<Oferta> resultado = new OfertaRepository(jdbcTemplate).listarPorMedicamentoId(1001);

        assertEquals(List.of(esperada), resultado);
        verify(jdbcTemplate).query(
                org.mockito.ArgumentMatchers.contains("WHERE ID_MEDICAMENTO = ?"),
                ArgumentMatchers.<RowMapper<Oferta>>any(),
                eq(1001));
    }
}
