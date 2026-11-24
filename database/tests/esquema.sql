-- Fixtures artificiais para validar persistencia; nao sao a seed demonstrativa da U01.
-- O relogio abaixo e SOMENTE o da sessao de teste, sem alterar o relogio do servidor.
SET timestamp = 1794916800;
SET @u01_agora = CURRENT_TIMESTAMP;
START TRANSACTION;

CALL u01_assert((SELECT COUNT(*) = 4 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE' AND engine = 'InnoDB'),
    'As quatro tabelas do MVP usam InnoDB');

INSERT INTO MEDICAMENTO (ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, APRESENTACAO, DESCRICAO) VALUES
    (10, 'Medicamento teste', 'Ativo ficticio', 'Teste', '500 mg', 'Comprimido de teste', 'Fixture da dosagem A'),
    (11, 'Medicamento teste', 'Ativo ficticio', 'Teste', '1 g', 'Comprimido de teste', 'Fixture da dosagem B'),
    (12, 'Sem ofertas', 'Ativo ficticio', 'Teste', '10 mg', 'Comprimido de teste', 'Fixture sem oferta'),
    (13, 'Todas indisponiveis', 'Ativo ficticio', 'Teste', '20 mg', 'Comprimido de teste', 'Fixture indisponivel');
INSERT INTO FARMACIA (ID_FARMACIA, NOME, ENDERECO) VALUES
    (2, 'Farmacia teste A', 'Endereco ficticio A'),
    (3, 'Farmacia teste B', 'Endereco ficticio B'),
    (4, 'Farmacia teste C', 'Endereco ficticio C');
INSERT INTO MEDICAMENTO_FARMACIA
    (ID_MEDICAMENTO_FARMACIA, ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL, DATA_ATUALIZACAO) VALUES
    (1, 10, 2, 8.99, 1, '2026-11-01 00:00:00'),
    (3, 10, 4, 7.50, 0, NULL),
    (4, 11, 2, 22.00, 1, NULL),
    (5, 13, 2, 10.00, 0, NULL),
    (6, 13, 3, 12.00, 0, NULL);
INSERT INTO MEDICAMENTO_FARMACIA
    (ID_MEDICAMENTO_FARMACIA, ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL)
    VALUES (2, 10, 3, 10.99, 1);

CALL u01_assert((SELECT COUNT(*) = 3 AND SUM(ID_MEDICAMENTO = 10) = 3
    FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO = 10), 'CT03 SQL: ofertas separadas por ID');
CALL u01_assert((SELECT COUNT(*) = 1 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 11 AND PRECO = 22.00), 'CT03 SQL: outra dosagem preservada');
CALL u01_assert((SELECT COUNT(*) = 0 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 12), 'CT05 SQL: medicamento sem ofertas');
CALL u01_assert((SELECT COUNT(*) = 2 AND SUM(DISPONIVEL) = 0 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 13), 'CT06 SQL: todas as ofertas indisponiveis');
CALL u01_assert((SELECT DATA_ATUALIZACAO = @u01_agora FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO_FARMACIA = 2), 'Data automatica na inclusao');
CALL u01_assert((SELECT DATA_ATUALIZACAO IS NULL FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO_FARMACIA = 3), 'Data desconhecida permanece NULL');

CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (10, 2, 9.00, 1)',
    1062, 'Par medicamento/farmacia duplicado rejeitado');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, APRESENTACAO, DESCRICAO) VALUES (10, ''Duplicado'', ''Teste'', ''Teste'', ''1 mg'', ''Comprimido de teste'', ''Fixture'')',
    1062, 'ID de medicamento duplicado rejeitado');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (999, 2, 9.00, 1)',
    1452, 'FK: medicamento inexistente rejeitado');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (12, 999, 9.00, 1)',
    1452, 'FK: farmacia inexistente rejeitada');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (NULL, 4, 9.00, 1)',
    1048, 'Medicamento NULL rejeitado');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (12, NULL, 9.00, 1)',
    1048, 'Farmacia NULL rejeitada');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (12, 4, 0.00, 1)',
    3819, 'Preco zero rejeitado');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (12, 4, -1.00, 1)',
    3819, 'Preco negativo rejeitado');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (12, 4, NULL, 1)',
    1048, 'Preco NULL rejeitado');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (12, 4, 9.00, NULL)',
    1048, 'Disponibilidade NULL rejeitada');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO) VALUES (12, 4, 9.00)',
    1364, 'Disponibilidade omitida rejeitada em modo estrito');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (12, 4, 9.00, 2)',
    3819, 'Disponibilidade 2 rejeitada');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL) VALUES (12, 4, 9.00, -1)',
    3819, 'Disponibilidade negativa rejeitada');
CALL u01_esperar_erro('UPDATE MEDICAMENTO_FARMACIA SET PRECO = 0 WHERE ID_MEDICAMENTO_FARMACIA = 1',
    3819, 'Preco invalido rejeitado tambem no UPDATE');
CALL u01_esperar_erro('UPDATE MEDICAMENTO_FARMACIA SET DISPONIVEL = 2 WHERE ID_MEDICAMENTO_FARMACIA = 1',
    3819, 'Disponibilidade invalida rejeitada tambem no UPDATE');
CALL u01_esperar_erro('DELETE FROM MEDICAMENTO WHERE ID_MEDICAMENTO = 10',
    1451, 'Exclusao de medicamento com ofertas bloqueada');
CALL u01_esperar_erro('DELETE FROM FARMACIA WHERE ID_FARMACIA = 2',
    1451, 'Exclusao de farmacia com ofertas bloqueada');
CALL u01_esperar_erro('UPDATE MEDICAMENTO SET ID_MEDICAMENTO = 777 WHERE ID_MEDICAMENTO = 10',
    1451, 'Alteracao de ID de medicamento referenciado bloqueada');
CALL u01_esperar_erro('UPDATE FARMACIA SET ID_FARMACIA = 777 WHERE ID_FARMACIA = 2',
    1451, 'Alteracao de ID de farmacia referenciada bloqueada');
CALL u01_esperar_erro('INSERT INTO HISTORICO_PRECO (ID_MEDICAMENTO_FARMACIA, PRECO, DATA_REGISTRO) VALUES (999, 9.00, ''2026-11-01'')',
    1452, 'FK do historico preservada');

UPDATE MEDICAMENTO_FARMACIA SET PRECO = 9.50 WHERE ID_MEDICAMENTO_FARMACIA = 1;
CALL u01_assert((SELECT PRECO = 9.50 AND DATA_ATUALIZACAO = @u01_agora
    FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 1), 'CT17 SQL: preco alterado atualiza a data');
SET timestamp = 1794916860;
UPDATE MEDICAMENTO_FARMACIA SET PRECO = PRECO WHERE ID_MEDICAMENTO_FARMACIA = 1;
CALL u01_assert((SELECT DATA_ATUALIZACAO = @u01_agora FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO_FARMACIA = 1), 'UPDATE sem mudanca nao altera a data');
UPDATE MEDICAMENTO_FARMACIA SET DISPONIVEL = 0 WHERE ID_MEDICAMENTO_FARMACIA = 1;
CALL u01_assert((SELECT DATA_ATUALIZACAO = CURRENT_TIMESTAMP AND DISPONIVEL = 0
    FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 1), 'Alterar disponibilidade atualiza a data');
UPDATE MEDICAMENTO_FARMACIA SET PRECO = 8.00 WHERE ID_MEDICAMENTO_FARMACIA = 3;
CALL u01_assert((SELECT DATA_ATUALIZACAO = CURRENT_TIMESTAMP FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO_FARMACIA = 3), 'Atualizacao real preenche uma data antes desconhecida');

SET SESSION time_zone = '-03:00';
CALL u01_assert((SELECT UNIX_TIMESTAMP(DATA_ATUALIZACAO) = 1794916860
    FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 1), 'Fuso preserva o mesmo instante');
SET SESSION time_zone = '+00:00';
ROLLBACK;
SET timestamp = 0;
