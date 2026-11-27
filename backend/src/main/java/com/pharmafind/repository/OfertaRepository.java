package com.pharmafind.repository;

import com.pharmafind.model.Oferta;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.Calendar;
import java.util.TimeZone;
import java.util.List;

@Repository
public class OfertaRepository {

    private static final RowMapper<Oferta> ROW_MAPPER = (resultSet, rowNumber) -> {
        Timestamp atualizacao = resultSet.getTimestamp("DATA_ATUALIZACAO", Calendar.getInstance(TimeZone.getTimeZone("UTC")));
        return new Oferta(
                resultSet.getInt("ID_MEDICAMENTO_FARMACIA"),
                resultSet.getInt("ID_MEDICAMENTO"),
                resultSet.getInt("ID_FARMACIA"),
                resultSet.getBigDecimal("PRECO"),
                resultSet.getBoolean("DISPONIVEL"),
                atualizacao == null ? null : atualizacao.toInstant());
    };

    private final JdbcTemplate jdbcTemplate;

    public OfertaRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Oferta> listarPorMedicamentoId(int medicamentoId) {
        String sql = """
                SELECT ID_MEDICAMENTO_FARMACIA, ID_MEDICAMENTO, ID_FARMACIA,
                       PRECO, DISPONIVEL, DATA_ATUALIZACAO
                FROM MEDICAMENTO_FARMACIA
                WHERE ID_MEDICAMENTO = ?
                ORDER BY PRECO, ID_FARMACIA
                """;
        return jdbcTemplate.query(sql, ROW_MAPPER, medicamentoId);
    }
}
