package com.pharmafind.repository;

import com.pharmafind.model.Medicamento;
import com.pharmafind.model.Oferta;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
@EnabledIfEnvironmentVariable(named = "DB_URL", matches = ".+")
@EnabledIfEnvironmentVariable(named = "DB_TEST_EXCLUSIVE", matches = "true")
class ConexaoMySqlIntegrationTest {

    @Autowired private ConexaoRepository conexaoRepository;
    @Autowired private MedicamentoRepository medicamentoRepository;
    @Autowired private FarmaciaRepository farmaciaRepository;
    @Autowired private OfertaRepository ofertaRepository;
    @Autowired private JdbcTemplate jdbcTemplate;
    @Autowired private PlatformTransactionManager transactionManager;

    @BeforeAll
    static void exigeUrlDoBancoDescartavelAntesDasConsultas() {
        assertTrue(System.getenv("DB_URL").matches("jdbc:mysql://[^/?;]+/pharmafind_test(?:\\?.*)?"),
                "A integração exige DB_URL para o banco descartável pharmafind_test");
    }

    @BeforeEach
    void confirmaBancoSelecionado() {
        assertEquals("pharmafind_test", jdbcTemplate.queryForObject("SELECT DATABASE()", String.class));
    }

    @Test
    void pesquisaParcialPreservaDosagemEApresentacaoPorId() {
        var medicamentos = medicamentoRepository.buscarPorNome("dIpI");
        var porId = medicamentos.stream().collect(Collectors.toMap(Medicamento::id, Function.identity()));
        assertEquals(Set.of(1001, 1002), porId.keySet());
        assertEquals("500 mg", porId.get(1001).dosagem());
        assertEquals("20 comprimidos", porId.get(1001).apresentacao());
        assertEquals("1 g", porId.get(1002).dosagem());
        assertEquals("10 comprimidos", porId.get(1002).apresentacao());
        porId.forEach((id, medicamento) -> assertEquals(medicamento,
                medicamentoRepository.buscarPorId(id).orElseThrow()));
        assertTrue(medicamentoRepository.buscarPorNome("termo sem correspondência").isEmpty());
        assertTrue(medicamentoRepository.buscarPorId(9999).isEmpty());
    }

    @Test
    void ordenaMedicamentosPelaDosagemTextualDaSeed() {
        // DOSAGEM é VARCHAR: "1 g" precede "500 mg", sem conversão de unidades.
        assertEquals(List.of(1002, 1001), medicamentoRepository.buscarPorNome("Dipi").stream()
                .map(Medicamento::id).toList());
    }

    @Test
    void entradasInvalidasECuringasNaoAmpliamABusca() {
        assertTrue(medicamentoRepository.buscarPorNome(null).isEmpty());
        assertTrue(medicamentoRepository.buscarPorNome("").isEmpty());
        assertTrue(medicamentoRepository.buscarPorNome("  ").isEmpty());
        assertThrows(IllegalArgumentException.class, () -> medicamentoRepository.buscarPorNome("a".repeat(101)));
        for (var termo : List.of("%", "_", "\\", "Dipi%", "Dipi_", "' OR 1=1 --", "a".repeat(100))) {
            assertTrue(medicamentoRepository.buscarPorNome(termo).isEmpty(), "termo literal: " + termo);
        }
        assertEquals(2, medicamentoRepository.buscarPorNome("Dipi").size());
    }

    @Test
    void ofertasPreservamPrecosDisponibilidadeERelacionamentosPorId() {
        Map<Integer, Integer> totais = Map.of(1001, 3, 1002, 2, 1003, 3, 1004, 0, 1005, 1, 1006, 3);
        totais.forEach((medicamentoId, total) -> {
            var ofertas = ofertaRepository.listarPorMedicamentoId(medicamentoId);
            assertEquals(total, ofertas.size(), "medicamento " + medicamentoId);
            assertTrue(ofertas.stream().allMatch(o -> o.medicamentoId() == medicamentoId));
        });
        var porId = ofertaRepository.listarPorMedicamentoId(1001).stream()
                .collect(Collectors.toMap(Oferta::id, Function.identity()));
        assertEquals(Set.of(3001, 3002, 3003), porId.keySet());
        assertEquals(new Oferta(3001, 1001, 2001, new BigDecimal("8.99"), true,
                Instant.parse("2026-11-12T12:00:00Z")), porId.get(3001));
        assertEquals(new Oferta(3002, 1001, 2002, new BigDecimal("10.99"), true,
                Instant.parse("2026-11-12T12:00:00Z")), porId.get(3002));
        assertEquals(new Oferta(3003, 1001, 2003, new BigDecimal("7.50"), false,
                Instant.parse("2026-11-12T12:00:00Z")), porId.get(3003));
        assertTrue(ofertaRepository.listarPorMedicamentoId(9999).isEmpty());
    }

    @Test
    void preservaOfertasIndisponiveisEDistingueMedicamentoSemOfertas() {
        assertTrue(ofertaRepository.listarPorMedicamentoId(1004).isEmpty());
        var indisponiveis = ofertaRepository.listarPorMedicamentoId(1003);
        assertEquals(Set.of(3006, 3007, 3008), indisponiveis.stream().map(Oferta::id).collect(Collectors.toSet()));
        assertTrue(indisponiveis.stream().noneMatch(Oferta::disponivel));
    }

    @Test
    void ordenaOfertasPorPrecoEDesempataPorFarmacia() {
        var ordem = Comparator.comparing(Oferta::preco).thenComparingInt(Oferta::farmaciaId);
        for (int id : List.of(1001, 1002, 1003, 1005, 1006)) {
            var ofertas = ofertaRepository.listarPorMedicamentoId(id);
            assertEquals(ofertas.stream().sorted(ordem).toList(), ofertas, "ordenação do medicamento " + id);
        }
        assertEquals(List.of(3003, 3001, 3002), ofertaRepository.listarPorMedicamentoId(1001).stream()
                .map(Oferta::id).toList());
        var empate = ofertaRepository.listarPorMedicamentoId(1006).stream()
                .filter(o -> new BigDecimal("15.90").equals(o.preco())).toList();
        assertEquals(List.of(2001, 2002), empate.stream().map(Oferta::farmaciaId).toList());
    }

    @Test
    void mapeiaFarmaciasCoordenadasHorariosECamposAusentes() {
        var farmacias = farmaciaRepository.listarTodas();
        assertEquals(4, farmacias.size());
        var farmacia2001 = farmacias.stream().filter(f -> f.id() == 2001).findFirst().orElseThrow();
        assertEquals(new BigDecimal("-15.9960000"), farmacia2001.latitude());
        assertEquals(new BigDecimal("-48.0560000"), farmacia2001.longitude());
        assertEquals("72429005", farmacia2001.cep());
        assertEquals(LocalTime.of(8, 0), farmacia2001.horarioAbertura());
        assertEquals(LocalTime.of(20, 0), farmacia2001.horarioFechamento());
        assertEquals(Boolean.FALSE, farmacia2001.delivery());
        var farmacia2004 = farmacias.stream().filter(f -> f.id() == 2004).findFirst().orElseThrow();
        assertNull(farmacia2004.cep());
        assertNull(farmacia2004.latitude());
        assertNull(farmacia2004.longitude());
        assertNull(farmacia2004.horarioAbertura());
        assertNull(farmacia2004.horarioFechamento());
    }

    @Test
    void conectaComUtcEModoEstrito() {
        assertTrue(conexaoRepository.conexaoAtiva());
        var sessao = jdbcTemplate.queryForMap("SELECT @@SESSION.time_zone AS time_zone, @@SESSION.sql_mode AS sql_mode");
        assertEquals("+00:00", sessao.get("time_zone"));
        assertTrue(List.of(sessao.get("sql_mode").toString().split(",")).contains("STRICT_ALL_TABLES"));
        assertEquals(Instant.parse("2026-11-12T12:00:00Z"), oferta3001().dataAtualizacao());
    }

    @Test
    void preservaDataEDeliveryNulosEReverteFixtures() {
        var ofertaAntes = oferta3001();
        var farmaciasAntes = farmaciaRepository.listarTodas();
        try {
            new TransactionTemplate(transactionManager).executeWithoutResult(status -> {
                status.setRollbackOnly();
                assertEquals(1, jdbcTemplate.update("UPDATE MEDICAMENTO_FARMACIA SET DATA_ATUALIZACAO = NULL WHERE ID_MEDICAMENTO_FARMACIA = ?", 3001));
                assertEquals(1, jdbcTemplate.update("UPDATE FARMACIA SET DELIVERY = NULL WHERE ID_FARMACIA = ?", 2004));
                assertNull(oferta3001().dataAtualizacao());
                assertNull(farmaciaRepository.listarTodas().stream().filter(f -> f.id() == 2004)
                        .findFirst().orElseThrow().delivery());
            });
        } finally {
            assertEquals(ofertaAntes, oferta3001(), "data restaurada após rollback");
            assertEquals(farmaciasAntes, farmaciaRepository.listarTodas(), "farmácias restauradas após rollback");
        }
    }

    @Test
    void ct17AtualizacaoDaOfertaEVisivelERevertidaNoBancoDescartavel() {
        var antes = ofertaRepository.listarPorMedicamentoId(1001);
        assertEquals(new BigDecimal("8.99"), oferta3001().preco());
        try {
            new TransactionTemplate(transactionManager).executeWithoutResult(status -> {
                status.setRollbackOnly();
                assertEquals(1, jdbcTemplate.update("UPDATE MEDICAMENTO_FARMACIA SET PRECO = ?, DISPONIVEL = ? WHERE ID_MEDICAMENTO_FARMACIA = ?",
                        new BigDecimal("9.49"), false, 3001));
                var depois = oferta3001();
                assertEquals(new BigDecimal("9.49"), depois.preco());
                assertFalse(depois.disponivel());
                assertTrue(depois.dataAtualizacao().isAfter(Instant.parse("2026-11-12T12:00:00Z")));
                var agora = jdbcTemplate.queryForObject("SELECT UNIX_TIMESTAMP()", Long.class);
                assertTrue(Math.abs(agora - depois.dataAtualizacao().getEpochSecond()) <= 5,
                        "data automática deve representar o instante atual do servidor");
            });
        } finally {
            assertEquals(antes, ofertaRepository.listarPorMedicamentoId(1001),
                    "CT17 deve restaurar preço, disponibilidade, data e relacionamentos após rollback");
        }
    }

    private Oferta oferta3001() {
        return ofertaRepository.listarPorMedicamentoId(1001).stream()
                .filter(o -> o.id() == 3001).findFirst().orElseThrow();
    }
}
