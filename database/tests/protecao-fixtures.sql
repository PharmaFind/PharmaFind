-- Somente no banco descartavel de protecao, criado e verificado pelo runner.
-- Mesmo conteudo esperado pela limpeza, para que a preservacao nao dependa de dados diferentes.
INSERT INTO MEDICAMENTO (ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, APRESENTACAO, DESCRICAO)
    VALUES (1, 'Medicamento legado de teste', 'Ativo ficticio', 'Teste', '10 mg', 'Comprimido de teste', 'Fixture');
INSERT INTO FARMACIA (ID_FARMACIA, NOME, ENDERECO) VALUES
    (1, 'Farmacia teste A', 'Endereco ficticio A'), (2, 'Farmacia teste B', 'Endereco ficticio B');
INSERT INTO MEDICAMENTO_FARMACIA
    (ID_MEDICAMENTO_FARMACIA, ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL, DATA_ATUALIZACAO) VALUES
    (1, 1, 1, 8.99, 1, NULL), (2, 1, 2, 10.99, 0, '2026-11-02 09:00:00');
INSERT INTO HISTORICO_PRECO (ID_HISTORICO_PRECO, ID_MEDICAMENTO_FARMACIA, PRECO, DATA_REGISTRO)
    VALUES (1, 1, 8.99, '2026-11-01');
