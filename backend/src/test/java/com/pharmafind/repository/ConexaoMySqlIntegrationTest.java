package com.pharmafind.repository;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
@EnabledIfEnvironmentVariable(named = "DB_URL", matches = ".+")
class ConexaoMySqlIntegrationTest {

    @Autowired
    private ConexaoRepository conexaoRepository;

    @Autowired
    private MedicamentoRepository medicamentoRepository;

    @Autowired
    private FarmaciaRepository farmaciaRepository;

    @Autowired
    private OfertaRepository ofertaRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void conectaEExecutaConsultasDeLeituraNoMySqlConfigurado() {
        assertTrue(conexaoRepository.conexaoAtiva());
        var medicamentos = medicamentoRepository.buscarPorNome("Dipi");
        assertEquals(java.util.List.of(1001, 1002), medicamentos.stream().map(m -> m.id()).toList());
        assertTrue(medicamentos.getFirst().apresentacao().contains("20 comprimidos"));
        assertTrue(medicamentos.getLast().apresentacao().contains("10 comprimidos"));
        assertEquals(medicamentos.getFirst(), medicamentoRepository.buscarPorId(1001).orElseThrow());
        assertTrue(medicamentoRepository.buscarPorNome("termo sem correspondência").isEmpty());
        assertTrue(medicamentoRepository.buscarPorId(9999).isEmpty());

        Map<Integer, Integer> totais = Map.of(1001, 3, 1002, 2, 1003, 3, 1004, 0, 1005, 1, 1006, 3);
        totais.forEach((medicamentoId, total) -> assertEquals(total,
                ofertaRepository.listarPorMedicamentoId(medicamentoId).size(), "medicamento " + medicamentoId));
        var ofertas1001 = ofertaRepository.listarPorMedicamentoId(1001);
        assertEquals(new BigDecimal("8.99"), ofertas1001.get(0).preco());
        assertEquals(new BigDecimal("10.99"), ofertas1001.get(1).preco());
        assertEquals(new BigDecimal("7.50"), ofertas1001.get(2).preco());
        assertTrue(ofertas1001.get(0).disponivel());
        assertTrue(ofertas1001.get(1).disponivel());
        assertTrue(!ofertas1001.get(2).disponivel());
        assertEquals(2, ofertaRepository.listarPorMedicamentoId(1006).stream()
                .filter(o -> new BigDecimal("15.90").compareTo(o.preco()) == 0).count());

        var farmacias = farmaciaRepository.listarTodas();
        assertEquals(4, farmacias.size());
        var farmacia2001 = farmacias.stream().filter(f -> f.id() == 2001).findFirst().orElseThrow();
        assertEquals(new BigDecimal("-15.9960000"), farmacia2001.latitude());
        assertEquals(new BigDecimal("-48.0560000"), farmacia2001.longitude());
        assertEquals(Boolean.FALSE, farmacia2001.delivery());
        var farmacia2004 = farmacias.stream().filter(f -> f.id() == 2004).findFirst().orElseThrow();
        assertNull(farmacia2004.cep());
        assertNull(farmacia2004.latitude());
        assertNull(farmacia2004.longitude());
        assertNull(farmacia2004.horarioAbertura());
        assertNull(farmacia2004.horarioFechamento());

        var sessao = jdbcTemplate.queryForMap("SELECT @@SESSION.time_zone AS time_zone, @@SESSION.sql_mode AS sql_mode");
        assertEquals("+00:00", sessao.get("time_zone"));
        assertTrue(sessao.get("sql_mode").toString().contains("STRICT_ALL_TABLES"));
        assertEquals(Instant.parse("2026-11-12T12:00:00Z"), ofertas1001.get(0).dataAtualizacao());
    }

    @Test
    @Transactional
    @EnabledIfEnvironmentVariable(named = "DB_TEST_EXCLUSIVE", matches = "true")
    void atualizacaoDaOfertaEVisivelERevertidaNoBancoDescartavel() {
        assertEquals("pharmafind_test", jdbcTemplate.queryForObject("SELECT DATABASE()", String.class),
                "CT17 só pode executar no banco descartável pharmafind_test");
        var antes = ofertaRepository.listarPorMedicamentoId(1001).stream()
                .filter(oferta -> oferta.id() == 3001).findFirst().orElseThrow();
        assertEquals(new BigDecimal("8.99"), antes.preco());

        jdbcTemplate.update("UPDATE MEDICAMENTO_FARMACIA SET PRECO = ?, DISPONIVEL = ? WHERE ID_MEDICAMENTO_FARMACIA = ?",
                new BigDecimal("9.49"), false, 3001);

        var depois = ofertaRepository.listarPorMedicamentoId(1001).stream()
                .filter(oferta -> oferta.id() == 3001).findFirst().orElseThrow();
        assertEquals(new BigDecimal("9.49"), depois.preco());
        assertTrue(!depois.disponivel());
        assertTrue(depois.dataAtualizacao().isAfter(antes.dataAtualizacao()));
    }
}
