package com.pharmafind.repository;

import com.pharmafind.model.Medicamento;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class MedicamentoRepository {

    private static final RowMapper<Medicamento> ROW_MAPPER = (resultSet, rowNumber) -> new Medicamento(
            resultSet.getInt("ID_MEDICAMENTO"),
            resultSet.getString("NOME"),
            resultSet.getString("PRINCIPIO_ATIVO"),
            resultSet.getString("CATEGORIA"),
            resultSet.getString("DOSAGEM"),
            resultSet.getString("DESCRICAO"),
            resultSet.getString("APRESENTACAO"));

    private final JdbcTemplate jdbcTemplate;

    public MedicamentoRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Medicamento> buscarPorNome(String termo) {
        String sql = """
                SELECT ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, DESCRICAO, APRESENTACAO
                FROM MEDICAMENTO
                WHERE LOWER(NOME) LIKE LOWER(?) ESCAPE '\\\\'
                ORDER BY NOME, DOSAGEM, ID_MEDICAMENTO
                """;
        if (termo == null || termo.isBlank()) return List.of();
        if (termo.length() > 100) throw new IllegalArgumentException("Termo de busca excede 100 caracteres.");
        String literal = termo.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
        return jdbcTemplate.query(sql, ROW_MAPPER, "%" + literal + "%");
    }

    public Optional<Medicamento> buscarPorId(int id) {
        String sql = """
                SELECT ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, DESCRICAO, APRESENTACAO
                FROM MEDICAMENTO
                WHERE ID_MEDICAMENTO = ?
                """;
        return jdbcTemplate.query(sql, ROW_MAPPER, id).stream().findFirst();
    }
}
