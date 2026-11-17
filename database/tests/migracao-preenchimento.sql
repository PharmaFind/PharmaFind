CALL u01_assert((SELECT COUNT(*) = 2 FROM MEDICAMENTO_FARMACIA
    WHERE DISPONIVEL IS NULL AND DATA_ATUALIZACAO IS NULL), 'Migracao nao presume disponibilidade nem data');
CALL u01_esperar_erro('CALL u01_consolidar_em_teste()', '1048,1138,1265',
    'Consolidacao recusa disponibilidade desconhecida');
CALL u01_assert((SELECT COUNT(*) = 2 FROM MEDICAMENTO_FARMACIA
    WHERE DISPONIVEL IS NULL AND DATA_ATUALIZACAO IS NULL), 'Consolidacao recusada preserva os NULL sem conversao');
CALL u01_assert((SELECT IS_NULLABLE = 'YES' FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'MEDICAMENTO_FARMACIA'
    AND column_name = 'DISPONIVEL'), 'Consolidacao recusada preserva a coluna ainda anulavel');

-- Valores avaliados explicitamente apenas para estas fixtures.
UPDATE MEDICAMENTO_FARMACIA SET DISPONIVEL = 1 WHERE ID_MEDICAMENTO_FARMACIA = 1;
UPDATE MEDICAMENTO_FARMACIA SET DISPONIVEL = 0, DATA_ATUALIZACAO = '2026-11-02 09:00:00'
    WHERE ID_MEDICAMENTO_FARMACIA = 2;
CALL u01_assert((SELECT DATA_ATUALIZACAO IS NULL FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO_FARMACIA = 1), 'Preencher disponibilidade nao fabrica data antiga');

UPDATE MEDICAMENTO_FARMACIA SET PRECO = 0 WHERE ID_MEDICAMENTO_FARMACIA = 1;
CALL u01_esperar_erro('CALL u01_consolidar_em_teste()', '3819', 'Consolidacao recusa preco invalido');
UPDATE MEDICAMENTO_FARMACIA SET PRECO = 8.99, DISPONIVEL = 2 WHERE ID_MEDICAMENTO_FARMACIA = 1;
CALL u01_esperar_erro('CALL u01_consolidar_em_teste()', '3819', 'Consolidacao recusa disponibilidade fora de 0/1');
UPDATE MEDICAMENTO_FARMACIA SET DISPONIVEL = 1 WHERE ID_MEDICAMENTO_FARMACIA = 1;
