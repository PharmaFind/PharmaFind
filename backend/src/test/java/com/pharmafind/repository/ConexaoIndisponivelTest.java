package com.pharmafind.repository;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;
import org.springframework.jdbc.CannotGetJdbcConnectionException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import java.net.InetAddress;
import java.net.ServerSocket;
import java.sql.SQLException;
import java.time.Duration;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class ConexaoIndisponivelTest {

    @Test
    void driverMySqlRealPropagaFalhaSemServidorNemResultadosFicticios() throws Exception {
        // Socket só de loopback, sem protocolo MySQL. Reserva a porta durante o teste.
        try (var semMySql = new ServerSocket(0, 16, InetAddress.getByName("127.0.0.1"))) {
            var dataSource = new DriverManagerDataSource(
                    "jdbc:mysql://127.0.0.1:" + semMySql.getLocalPort()
                            + "/pharmafind_test?connectTimeout=1000&socketTimeout=1000", "teste", "");
            var jdbc = new JdbcTemplate(dataSource);
            List<Executable> consultas = List.of(
                    () -> new ConexaoRepository(jdbc).conexaoAtiva(),
                    () -> new MedicamentoRepository(jdbc).buscarPorNome("Dipi"),
                    () -> new FarmaciaRepository(jdbc).listarTodas(),
                    () -> new OfertaRepository(jdbc).listarPorMedicamentoId(1001));
            assertTimeoutPreemptively(Duration.ofSeconds(10), () -> {
                for (var consulta : consultas) {
                    var falha = assertThrows(CannotGetJdbcConnectionException.class, consulta);
                    var causa = assertInstanceOf(SQLException.class, falha.getCause());
                    assertTrue(causa.getSQLState().startsWith("08"), "SQLState de falha de conexão");
                }
            });
        }
    }
}
