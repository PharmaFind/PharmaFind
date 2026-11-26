package com.pharmafind.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ConexaoRepository {

    private final JdbcTemplate jdbcTemplate;

    public ConexaoRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public boolean conexaoAtiva() {
        Integer resultado = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
        return Integer.valueOf(1).equals(resultado);
    }
}
