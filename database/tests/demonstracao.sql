-- Somente em bancos exclusivos dos runners. u01_seed_em_teste usa o arquivo REAL da seed.
-- Primeiro verifica que um conflito impede a carga inteira, inclusive insercoes ainda ausentes.
INSERT INTO MEDICAMENTO (ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, APRESENTACAO, DESCRICAO)
    VALUES (1006, 'Registro conflitante do teste', 'Teste', 'Teste', '1 mg', 'Comprimido de teste', 'Nao pertence a seed');
CALL u01_esperar_erro('CALL u01_seed_em_teste()', 3819, 'Seed recusa ID existente com conteudo diferente');
ROLLBACK;
CALL u01_assert((SELECT COUNT(*) = 1 FROM MEDICAMENTO), 'Conflito impede insercao parcial dos medicamentos');
CALL u01_assert((SELECT COUNT(*) = 0 FROM FARMACIA) AND (SELECT COUNT(*) = 0 FROM MEDICAMENTO_FARMACIA),
    'Conflito impede insercao parcial de farmacias e ofertas');
DELETE FROM MEDICAMENTO WHERE ID_MEDICAMENTO = 1006;

INSERT INTO MEDICAMENTO (ID_MEDICAMENTO,NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO)
VALUES (9998,'Dipirona','Teste','Teste','500 mg','20 comprimidos','Fixture de identidade sob outro ID');
CALL u01_esperar_erro('CALL u01_seed_em_teste()',3819,'Seed recusa identidade existente sob outro ID');
ROLLBACK;
CALL u01_assert((SELECT COUNT(*) = 1 FROM MEDICAMENTO) AND (SELECT COUNT(*) = 0 FROM FARMACIA),
    'Conflito de identidade nao produz insercoes parciais');
DELETE FROM MEDICAMENTO WHERE ID_MEDICAMENTO = 9998;
CALL u01_seed_em_teste();
CALL u01_assert((SELECT COUNT(*) = 6 FROM MEDICAMENTO) AND (SELECT COUNT(*) = 4 FROM FARMACIA)
    AND (SELECT COUNT(*) = 12 FROM MEDICAMENTO_FARMACIA), 'Seed carrega 6 medicamentos, 4 farmacias e 12 ofertas');
CALL u01_assert((SELECT COUNT(*) = 2 AND COUNT(DISTINCT DOSAGEM) = 2 FROM MEDICAMENTO
    WHERE NOME = 'Dipirona'), 'CT03 seed: apresentacoes distintas possuem IDs separados');
CALL u01_assert((SELECT COUNT(*) = 3 FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO = 1001)
    AND (SELECT COUNT(*) = 2 FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO = 1002),
    'CT03 seed: ofertas de 500 mg e 1 g sao separadas');
CALL u01_assert((SELECT COUNT(*) = 2 AND MIN(PRECO) = 8.99 AND AVG(PRECO) = 9.99
    AND MAX(PRECO) - MIN(PRECO) = 2.00 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 1001 AND DISPONIVEL = 1), 'CT02 seed: precos disponiveis permitem os valores especificados');
CALL u01_assert((SELECT COUNT(*) = 1 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 1001 AND PRECO = 7.50 AND DISPONIVEL = 0), 'CT02 seed: oferta mais barata esta indisponivel');
CALL u01_assert((SELECT COUNT(*) = 0 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 1004), 'CT05 seed: medicamento cadastrado sem ofertas');
CALL u01_assert((SELECT COUNT(*) = 3 AND SUM(DISPONIVEL) = 0 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 1003), 'CT06 seed: tres ofertas, todas indisponiveis');
CALL u01_assert((SELECT COUNT(*) = 1 AND MIN(PRECO) = 12.00 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 1005 AND DISPONIVEL = 1), 'CT04 seed: medicamento com uma oferta disponivel');
CALL u01_assert((SELECT COUNT(*) = 2 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO = 1006 AND DISPONIVEL = 1 AND PRECO = 15.90), 'CT07 seed: duas ofertas empatadas no menor preco');
CALL u01_assert((SELECT SUM(DISPONIVEL = 1) = 8 AND SUM(DISPONIVEL = 0) = 4
    AND MIN(PRECO) > 0 FROM MEDICAMENTO_FARMACIA), 'Seed possui 8 ofertas disponiveis e 4 indisponiveis validas');
CALL u01_assert((SELECT COUNT(*) = 12 FROM MEDICAMENTO_FARMACIA
    WHERE DATA_ATUALIZACAO = '2026-11-12 12:00:00'), 'Datas da seed sao fixtures fixas em UTC');
CALL u01_assert((SELECT COUNT(*) = 3 FROM FARMACIA
    WHERE LATITUDE BETWEEN -90 AND 90 AND LONGITUDE BETWEEN -180 AND 180), 'Tres farmacias possuem coordenadas cadastradas validas');
CALL u01_assert((SELECT LATITUDE IS NULL AND LONGITUDE IS NULL FROM FARMACIA WHERE ID_FARMACIA = 2004),
    'CT13 dados: farmacia sem coordenadas nao recebe ponto inventado');
CALL u01_assert((SELECT COUNT(*) = 0 FROM HISTORICO_PRECO), 'Seed nao cria registros historicos');

-- O JSON abaixo foi lido do arquivo versionado pelo runner, sem buscar servicos de CEP.
CALL u01_assert(JSON_VALID(@u01_ceps_json) AND JSON_LENGTH(@u01_ceps_json, '$.ceps') = 3
    AND JSON_UNQUOTE(JSON_EXTRACT(@u01_ceps_json, '$.demonstrativo')) = 'true', 'Mapa local e JSON demonstrativo com tres CEPs');
CALL u01_assert((SELECT COUNT(*) = 3 AND COUNT(DISTINCT cep) = 3
    AND SUM(cep REGEXP '^[0-9]{8}$' AND latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180) = 3
    FROM JSON_TABLE(@u01_ceps_json, '$.ceps[*]' COLUMNS (
        cep VARCHAR(32) PATH '$.cep', latitude DECIMAL(10,7) PATH '$.latitude',
        longitude DECIMAL(10,7) PATH '$.longitude')) AS pontos), 'CT09 dados: CEPs unicos e coordenadas validas no mapa');
-- JSON_TABLE pode usar collation diferente da coluna persistida; fixar apenas esta comparacao.
CALL u01_assert((SELECT COUNT(*) = 3 FROM FARMACIA f JOIN JSON_TABLE(@u01_ceps_json, '$.ceps[*]'
    COLUMNS (cep VARCHAR(32) PATH '$.cep')) AS pontos
    ON pontos.cep COLLATE utf8mb4_unicode_ci = f.CEP COLLATE utf8mb4_unicode_ci), 'CEPs das tres farmacias constam do mapa local');
CALL u01_assert((SELECT COUNT(*) = 0 FROM JSON_TABLE(@u01_ceps_json, '$.ceps[*]'
    COLUMNS (cep VARCHAR(32) PATH '$.cep')) AS pontos WHERE cep = '99999999'), 'CT11 dados: CEP de exemplo nao mapeado fica fora da lista');

-- Registros sentinela fora da seed: verificar preservacao na reexecucao.
INSERT INTO MEDICAMENTO (ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, APRESENTACAO, DESCRICAO)
    VALUES (9001, 'Sentinela ficticia', 'Teste', 'Teste', '1 mg', 'Comprimido de teste', 'Dado de teste fora da seed');
INSERT INTO FARMACIA (ID_FARMACIA, NOME, ENDERECO) VALUES (9001, 'Sentinela ficticia', 'Endereco ficticio de teste');
INSERT INTO MEDICAMENTO_FARMACIA
    (ID_MEDICAMENTO_FARMACIA, ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL, DATA_ATUALIZACAO)
    VALUES (9001, 9001, 9001, 99.99, 1, '2026-11-10 12:00:00');
INSERT INTO HISTORICO_PRECO (ID_HISTORICO_PRECO, ID_MEDICAMENTO_FARMACIA, PRECO, DATA_REGISTRO)
    VALUES (9001, 9001, 99.99, '2026-11-10');
CALL u01_seed_em_teste();
CALL u01_assert((SELECT COUNT(*) = 7 FROM MEDICAMENTO) AND (SELECT COUNT(*) = 5 FROM FARMACIA)
    AND (SELECT COUNT(*) = 13 FROM MEDICAMENTO_FARMACIA), 'Reexecutar seed nao duplica registros');
CALL u01_assert((SELECT COUNT(*) = 12 FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA BETWEEN 3001 AND 3012
    AND DATA_ATUALIZACAO = '2026-11-12 12:00:00'), 'Reexecutar seed nao modifica datas fixas');
CALL u01_assert((SELECT PRECO = 99.99 AND DATA_ATUALIZACAO = '2026-11-10 12:00:00'
    FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 9001)
    AND (SELECT PRECO = 99.99 AND DATA_REGISTRO = '2026-11-10' FROM HISTORICO_PRECO WHERE ID_HISTORICO_PRECO = 9001),
    'Reexecucao preserva registros e historico fora da seed');

UPDATE MEDICAMENTO_FARMACIA SET PRECO = 9.50 WHERE ID_MEDICAMENTO_FARMACIA = 3001;
SET @u01_data_alterada = (SELECT DATA_ATUALIZACAO FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 3001);
CALL u01_esperar_erro('CALL u01_seed_em_teste()', 3819, 'Seed recusa sobrescrever preco alterado');
ROLLBACK;
CALL u01_assert((SELECT PRECO = 9.50 AND DATA_ATUALIZACAO = @u01_data_alterada
    FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 3001), 'Conflito preserva preco e data alterados');
UPDATE MEDICAMENTO_FARMACIA SET PRECO = 8.99, DATA_ATUALIZACAO = '2026-11-12 12:00:00' WHERE ID_MEDICAMENTO_FARMACIA = 3001;

UPDATE MEDICAMENTO_FARMACIA SET ID_MEDICAMENTO_FARMACIA = 3999 WHERE ID_MEDICAMENTO_FARMACIA = 3012;
CALL u01_esperar_erro('CALL u01_seed_em_teste()', 3819, 'Seed recusa par medicamento/farmacia com outro ID de oferta');
ROLLBACK;
CALL u01_assert((SELECT COUNT(*) = 1 FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 3999), 'Conflito de par nao substitui a oferta existente');
UPDATE MEDICAMENTO_FARMACIA SET ID_MEDICAMENTO_FARMACIA = 3012, DATA_ATUALIZACAO = '2026-11-12 12:00:00' WHERE ID_MEDICAMENTO_FARMACIA = 3999;

INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO_FARMACIA, ID_MEDICAMENTO, ID_FARMACIA, PRECO, DISPONIVEL)
    VALUES (3900, 1004, 2001, 1.00, 1);
CALL u01_esperar_erro('CALL u01_seed_em_teste()', 3819, 'Seed recusa oferta extra que muda o cenario sem ofertas');
ROLLBACK;
CALL u01_assert((SELECT COUNT(*) = 1 FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 3900), 'Seed nao apaga oferta extra ao detectar conflito');
DELETE FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 3900;
CALL u01_seed_em_teste();

UPDATE MEDICAMENTO SET APRESENTACAO = '30 comprimidos' WHERE ID_MEDICAMENTO = 1001;
CALL u01_esperar_erro('CALL u01_seed_em_teste()',3819,'Seed preserva apresentacao alterada legitimamente');
ROLLBACK;
CALL u01_assert((SELECT APRESENTACAO = '30 comprimidos' FROM MEDICAMENTO WHERE ID_MEDICAMENTO = 1001),
    'Conflito nao sobrescreve apresentacao');
UPDATE MEDICAMENTO SET APRESENTACAO = '20 comprimidos' WHERE ID_MEDICAMENTO = 1001;
