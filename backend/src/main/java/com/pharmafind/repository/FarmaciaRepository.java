package com.pharmafind.repository;

import com.pharmafind.model.Farmacia;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Time;
import java.util.List;

@Repository
public class FarmaciaRepository {

    private static final RowMapper<Farmacia> ROW_MAPPER = (resultSet, rowNumber) -> {
        Time abertura = resultSet.getTime("HORARIO_ABERTURA");
        Time fechamento = resultSet.getTime("HORARIO_FECHAMENTO");
        return new Farmacia(
                resultSet.getInt("ID_FARMACIA"),
                resultSet.getString("NOME"),
                resultSet.getString("ENDERECO"),
                resultSet.getString("CEP"),
                resultSet.getBigDecimal("LATITUDE"),
                resultSet.getBigDecimal("LONGITUDE"),
                abertura == null ? null : abertura.toLocalTime(),
                fechamento == null ? null : fechamento.toLocalTime(),
                resultSet.getObject("DELIVERY", Boolean.class));
    };

    private final JdbcTemplate jdbcTemplate;

    public FarmaciaRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Farmacia> listarTodas() {
        String sql = """
                SELECT ID_FARMACIA, NOME, ENDERECO, CEP, LATITUDE, LONGITUDE,
                       HORARIO_ABERTURA, HORARIO_FECHAMENTO, DELIVERY
                FROM FARMACIA
                ORDER BY NOME, ID_FARMACIA
                """;
        return jdbcTemplate.query(sql, ROW_MAPPER);
    }
}
