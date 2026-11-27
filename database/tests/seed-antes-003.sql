-- Snapshot U01 anterior a #33, HEAD 2045c94; somente bancos descartaveis.
-- U01 / #10. Dados FICTICIOS, sem valor comercial ou recomendacao clinica.
-- Executar em banco de desenvolvimento com esquema U01, fora de outra transacao.
-- Reexecucao identica nao duplica nem altera registros; conflito gera erro 3819.
-- Nao apaga usuarios, registros de outra origem ou HISTORICO_PRECO.
SET NAMES utf8mb4;
SET SESSION time_zone = '+00:00';
SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES');

-- Tabelas temporarias pertencem somente a esta sessao, inclusive apos uma tentativa recusada.
DROP TEMPORARY TABLE IF EXISTS u01_seed_medicamentos, u01_seed_farmacias, u01_seed_ofertas, u01_seed_validacao;
CREATE TEMPORARY TABLE u01_seed_medicamentos ENGINE=InnoDB AS SELECT * FROM MEDICAMENTO WHERE FALSE;
CREATE TEMPORARY TABLE u01_seed_farmacias ENGINE=InnoDB AS SELECT * FROM FARMACIA WHERE FALSE;
CREATE TEMPORARY TABLE u01_seed_ofertas ENGINE=InnoDB AS SELECT * FROM MEDICAMENTO_FARMACIA WHERE FALSE;
CREATE TEMPORARY TABLE u01_seed_validacao (
    COMPATIVEL BOOLEAN NOT NULL,
    CONSTRAINT CK_U01_SEED_CONFLITO CHECK (COMPATIVEL = 1)
) ENGINE=InnoDB;

INSERT INTO u01_seed_medicamentos
    (ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, DESCRICAO) VALUES
    (1001, 'Dipirona', 'Dipirona sódica', 'Analgésico', '500 mg', 'Apresentação demonstrativa fictícia: 20 comprimidos.'),
    (1002, 'Dipirona', 'Dipirona sódica', 'Analgésico', '1 g', 'Apresentação demonstrativa fictícia: 10 comprimidos.'),
    (1003, 'Paracetamol', 'Paracetamol', 'Analgésico', '750 mg', 'Apresentação demonstrativa fictícia: 20 comprimidos.'),
    (1004, 'Ibuprofeno', 'Ibuprofeno', 'Anti-inflamatório', '400 mg', 'Apresentação demonstrativa fictícia: 10 cápsulas.'),
    (1005, 'Loratadina', 'Loratadina', 'Antialérgico', '10 mg', 'Apresentação demonstrativa fictícia: 12 comprimidos.'),
    (1006, 'Omeprazol', 'Omeprazol', 'Categoria demonstrativa', '20 mg', 'Apresentação demonstrativa fictícia: 28 cápsulas.');

-- Pontos sinteticos para a demonstracao regional; nao sao estabelecimentos reais.
-- As fontes dos CEPs e a origem dos pontos estao em README.md e ceps-teste.json.
INSERT INTO u01_seed_farmacias
    (ID_FARMACIA, NOME, ENDERECO, CEP, LATITUDE, LONGITUDE, HORARIO_ABERTURA, HORARIO_FECHAMENTO, DELIVERY) VALUES
    (2001, 'Farmácia Demo Ponte Alta', 'Endereço fictício 01 - Ponte Alta, Gama/DF', '72429005', -15.9960000, -48.0560000, '08:00:00', '20:00:00', 0),
    (2002, 'Farmácia Demo Gama Leste', 'Endereço fictício 02 - Setor Leste, Gama/DF', '72444240', -15.9910000, -48.0440000, '09:00:00', '21:00:00', 0),
    (2003, 'Farmácia Demo Recanto', 'Endereço fictício 03 - Recanto das Emas/DF', '72620100', -15.9190000, -48.0830000, '08:00:00', '18:00:00', 0),
    (2004, 'Farmácia Demo Gama Sul', 'Endereço fictício 04 - Setor Sul, Gama/DF', NULL, NULL, NULL, NULL, NULL, 0);

-- Data fixa de fixture em UTC: nao representa coleta ou atualizacao comercial real.
INSERT INTO u01_seed_ofertas
    (ID_MEDICAMENTO_FARMACIA, ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL, DATA_ATUALIZACAO) VALUES
    (3001, 1001, 2001,  8.99, 1, '2026-11-12 12:00:00'),
    (3002, 1001, 2002, 10.99, 1, '2026-11-12 12:00:00'),
    (3003, 1001, 2003,  7.50, 0, '2026-11-12 12:00:00'),
    (3004, 1002, 2001, 14.00, 1, '2026-11-12 12:00:00'),
    (3005, 1002, 2004, 16.00, 1, '2026-11-12 12:00:00'),
    (3006, 1003, 2001,  6.50, 0, '2026-11-12 12:00:00'),
    (3007, 1003, 2002,  7.25, 0, '2026-11-12 12:00:00'),
    (3008, 1003, 2003,  5.99, 0, '2026-11-12 12:00:00'),
    (3009, 1005, 2002, 12.00, 1, '2026-11-12 12:00:00'),
    (3010, 1006, 2001, 15.90, 1, '2026-11-12 12:00:00'),
    (3011, 1006, 2002, 15.90, 1, '2026-11-12 12:00:00'),
    (3012, 1006, 2004, 18.50, 1, '2026-11-12 12:00:00');

START TRANSACTION;
SET @u01_seed_compativel = NOT EXISTS (
        SELECT 1 FROM MEDICAMENTO m JOIN u01_seed_medicamentos s ON s.ID_MEDICAMENTO = m.ID_MEDICAMENTO
        WHERE NOT ((CAST(m.NOME AS BINARY) <=> CAST(s.NOME AS BINARY))
            AND (CAST(m.PRINCIPIO_ATIVO AS BINARY) <=> CAST(s.PRINCIPIO_ATIVO AS BINARY))
            AND (CAST(m.CATEGORIA AS BINARY) <=> CAST(s.CATEGORIA AS BINARY))
            AND (CAST(m.DOSAGEM AS BINARY) <=> CAST(s.DOSAGEM AS BINARY))
            AND (CAST(m.DESCRICAO AS BINARY) <=> CAST(s.DESCRICAO AS BINARY)))
    );
SET @u01_seed_compativel = @u01_seed_compativel AND NOT EXISTS (
        SELECT 1 FROM FARMACIA f JOIN u01_seed_farmacias s ON s.ID_FARMACIA = f.ID_FARMACIA
        WHERE NOT ((CAST(f.NOME AS BINARY) <=> CAST(s.NOME AS BINARY)) AND (CAST(f.ENDERECO AS BINARY) <=> CAST(s.ENDERECO AS BINARY))
            AND (f.CEP <=> s.CEP) AND (f.LATITUDE <=> s.LATITUDE) AND (f.LONGITUDE <=> s.LONGITUDE)
            AND (f.HORARIO_ABERTURA <=> s.HORARIO_ABERTURA) AND (f.HORARIO_FECHAMENTO <=> s.HORARIO_FECHAMENTO)
            AND (f.DELIVERY <=> s.DELIVERY))
    );
SET @u01_seed_compativel = @u01_seed_compativel AND NOT EXISTS (
        SELECT 1 FROM MEDICAMENTO_FARMACIA o JOIN u01_seed_ofertas s
            ON o.ID_MEDICAMENTO_FARMACIA = s.ID_MEDICAMENTO_FARMACIA
            OR (o.ID_MEDICAMENTO = s.ID_MEDICAMENTO AND o.ID_FARMACIA = s.ID_FARMACIA)
        WHERE NOT ((o.ID_MEDICAMENTO_FARMACIA = s.ID_MEDICAMENTO_FARMACIA)
            AND (o.ID_MEDICAMENTO = s.ID_MEDICAMENTO) AND (o.ID_FARMACIA = s.ID_FARMACIA)
            AND (o.PRECO <=> s.PRECO) AND (o.DISPONIVEL <=> s.DISPONIVEL)
            AND (o.DATA_ATUALIZACAO <=> s.DATA_ATUALIZACAO))
    );
SET @u01_seed_compativel = @u01_seed_compativel AND NOT EXISTS (
        -- Uma oferta extra de medicamento da seed mudaria os cenarios, inclusive "sem ofertas".
        SELECT 1 FROM MEDICAMENTO_FARMACIA o JOIN u01_seed_medicamentos m ON m.ID_MEDICAMENTO = o.ID_MEDICAMENTO
        LEFT JOIN u01_seed_ofertas s ON s.ID_MEDICAMENTO_FARMACIA = o.ID_MEDICAMENTO_FARMACIA
        WHERE s.ID_MEDICAMENTO_FARMACIA IS NULL
    );

-- Erro identificavel se um ID, par ou conteudo conflitar. Nenhum UPDATE/REPLACE/IGNORE.
INSERT INTO u01_seed_validacao (COMPATIVEL) VALUES (@u01_seed_compativel);
INSERT INTO MEDICAMENTO (ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, DESCRICAO)
    SELECT s.* FROM u01_seed_medicamentos s
    WHERE @u01_seed_compativel = 1
        AND NOT EXISTS (SELECT 1 FROM MEDICAMENTO m WHERE m.ID_MEDICAMENTO = s.ID_MEDICAMENTO);
INSERT INTO FARMACIA
    (ID_FARMACIA, NOME, ENDERECO, CEP, LATITUDE, LONGITUDE, HORARIO_ABERTURA, HORARIO_FECHAMENTO, DELIVERY)
    SELECT s.* FROM u01_seed_farmacias s
    WHERE @u01_seed_compativel = 1
        AND NOT EXISTS (SELECT 1 FROM FARMACIA f WHERE f.ID_FARMACIA = s.ID_FARMACIA);
INSERT INTO MEDICAMENTO_FARMACIA
    (ID_MEDICAMENTO_FARMACIA, ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL, DATA_ATUALIZACAO)
    SELECT s.* FROM u01_seed_ofertas s
    WHERE @u01_seed_compativel = 1
        AND NOT EXISTS (SELECT 1 FROM MEDICAMENTO_FARMACIA o WHERE o.ID_MEDICAMENTO_FARMACIA = s.ID_MEDICAMENTO_FARMACIA);
COMMIT;

DROP TEMPORARY TABLE u01_seed_medicamentos, u01_seed_farmacias, u01_seed_ofertas, u01_seed_validacao;
SELECT IF(@u01_seed_compativel = 1, 'U01: demonstracao carregada ou ja identica (6 medicamentos, 4 farmacias, 12 ofertas).',
    'U01: conflito; carga nao aplicada.') AS resultado;
