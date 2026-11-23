-- U01 / #10. Executar UMA vez, somente apos 001 e revisao de cada oferta.
-- Preencher DISPONIVEL com 0/1 e corrigir precos invalidos antes desta etapa.
-- Datas sem evidencia devem continuar NULL. Nao preencher com a data da migracao.
SET SESSION time_zone = '+00:00';
SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES');

-- Em InnoDB/MySQL >= 8.0.16, este ALTER falha se houver NULL em DISPONIVEL,
-- disponibilidade diferente de 0/1 ou preco <= 0; nao corrige valores silenciosamente.
-- Mudar o default da data nao preenche as datas NULL ja existentes.
ALTER TABLE MEDICAMENTO_FARMACIA
    MODIFY COLUMN DISPONIVEL BOOLEAN NOT NULL,
    MODIFY COLUMN DATA_ATUALIZACAO TIMESTAMP NULL
        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ADD CONSTRAINT CK_OFERTA_PRECO_POSITIVO CHECK (PRECO > 0),
    ADD CONSTRAINT CK_OFERTA_DISPONIVEL CHECK (DISPONIVEL IN (0, 1));
