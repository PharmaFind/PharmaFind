package com.pharmafind.repository;

import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertThrows;
import org.springframework.jdbc.CannotGetJdbcConnectionException;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class ConexaoRepositoryTest {

    @Test
    void retornaAtivoQuandoConsultaSimplesRetornaUm() {
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        when(jdbcTemplate.queryForObject("SELECT 1", Integer.class)).thenReturn(1);

        assertTrue(new ConexaoRepository(jdbcTemplate).conexaoAtiva());
    }

    @Test
    void propagaFalhaDeConexaoComoExcecaoControladaDoSpring() {
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        var falha = new CannotGetJdbcConnectionException("conexão indisponível");
        when(jdbcTemplate.queryForObject("SELECT 1", Integer.class)).thenThrow(falha);
        assertThrows(CannotGetJdbcConnectionException.class, () -> new ConexaoRepository(jdbcTemplate).conexaoAtiva());
    }
}
