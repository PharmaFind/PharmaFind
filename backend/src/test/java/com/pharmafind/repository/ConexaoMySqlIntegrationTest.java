package com.pharmafind.repository;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertNotNull;
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

    @Test
    void conectaEExecutaConsultasDeLeituraNoMySqlConfigurado() {
        assertTrue(conexaoRepository.conexaoAtiva());
        assertNotNull(farmaciaRepository.listarTodas());

        var medicamentos = medicamentoRepository.buscarPorNome("Dipi");
        assertNotNull(medicamentos);
        if (!medicamentos.isEmpty()) {
            assertNotNull(ofertaRepository.listarPorMedicamentoId(medicamentos.getFirst().id()));
        }
    }
}
