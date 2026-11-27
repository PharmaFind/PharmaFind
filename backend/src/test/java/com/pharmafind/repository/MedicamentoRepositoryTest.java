package com.pharmafind.repository;

import com.pharmafind.model.Medicamento;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.mockito.ArgumentMatchers;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class MedicamentoRepositoryTest {

    @Test
    void buscaPorNomeComParametroVinculado() {
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        Medicamento esperado = new Medicamento(1001, "Dipirona", "Dipirona sódica",
                "Analgésico", "500 mg", "Apresentação fictícia de teste", "20 comprimidos");
        when(jdbcTemplate.query(any(String.class), ArgumentMatchers.<RowMapper<Medicamento>>any(), eq("%Dipi%")))
                .thenReturn(List.of(esperado));

        List<Medicamento> resultado = new MedicamentoRepository(jdbcTemplate).buscarPorNome("Dipi");

        assertEquals(List.of(esperado), resultado);
        verify(jdbcTemplate).query(
                org.mockito.ArgumentMatchers.contains("WHERE LOWER(NOME) LIKE LOWER(?)"),
                ArgumentMatchers.<RowMapper<Medicamento>>any(),
                eq("%Dipi%"));
    }

    @Test
    void entradasVaziasNaoConsultamOBanco() {
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        MedicamentoRepository repository = new MedicamentoRepository(jdbcTemplate);
        org.junit.jupiter.api.Assertions.assertTrue(repository.buscarPorNome(null).isEmpty());
        org.junit.jupiter.api.Assertions.assertTrue(repository.buscarPorNome("  ").isEmpty());
        org.mockito.Mockito.verifyNoInteractions(jdbcTemplate);
    }

    @Test
    void curingasSaoTratadosComoTextoLiteral() {
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        when(jdbcTemplate.query(any(String.class), ArgumentMatchers.<RowMapper<Medicamento>>any(), eq("%100\\%\\_%")))
                .thenReturn(List.of());
        new MedicamentoRepository(jdbcTemplate).buscarPorNome("100%_");
        verify(jdbcTemplate).query(any(String.class), ArgumentMatchers.<RowMapper<Medicamento>>any(), eq("%100\\%\\_%"));
    }
}
