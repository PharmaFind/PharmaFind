CALL u01_assert((SELECT COUNT(*) = 2 FROM MEDICAMENTO_FARMACIA), 'Migracao conserva todas as ofertas');
CALL u01_assert((SELECT DISPONIVEL = 1 AND DATA_ATUALIZACAO IS NULL AND PRECO = 8.99
    AND ID_MEDICAMENTO = 1 AND ID_FARMACIA = 1 FROM MEDICAMENTO_FARMACIA
    WHERE ID_MEDICAMENTO_FARMACIA = 1), 'Consolidacao preserva IDs, preco e data desconhecida');
CALL u01_assert((SELECT DISPONIVEL = 0 AND DATA_ATUALIZACAO = '2026-11-02 09:00:00' AND PRECO = 10.99
    FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 2), 'Consolidacao preserva data informada e indisponibilidade');
CALL u01_assert((SELECT COUNT(*) = 1 AND MIN(ID_MEDICAMENTO_FARMACIA) = 1
    AND MIN(PRECO) = 8.99 AND MIN(DATA_REGISTRO) = '2026-11-01'
    FROM HISTORICO_PRECO), 'Migracao preserva o historico legado de teste');

-- Protecao AUTONOMA em cada DELETE: nao depende de u01_assert, de erro anterior,
-- do modo do cliente nem de uma variavel booleana deixada por outra execucao.
-- O runner arma @u01_banco_descartavel apenas para seu banco migrado recem-criado.
-- Fora desse contexto (inclusive SOURCE isolado), os predicados nao selecionam linhas.
DELETE FROM HISTORICO_PRECO
WHERE REGEXP_LIKE(DATABASE(), '^pharmafind_u01_test_migrado_[0-9a-f_]{1,24}$', 'c')
    AND CAST(DATABASE() AS BINARY) = CAST(@u01_banco_descartavel AS BINARY)
    AND ID_HISTORICO_PRECO = 1 AND ID_MEDICAMENTO_FARMACIA = 1
    AND PRECO = 8.99 AND DATA_REGISTRO = '2026-11-01';
DELETE FROM MEDICAMENTO_FARMACIA
WHERE REGEXP_LIKE(DATABASE(), '^pharmafind_u01_test_migrado_[0-9a-f_]{1,24}$', 'c')
    AND CAST(DATABASE() AS BINARY) = CAST(@u01_banco_descartavel AS BINARY)
    AND ID_MEDICAMENTO = 1
    AND ((ID_MEDICAMENTO_FARMACIA = 1 AND ID_FARMACIA = 1 AND PRECO = 8.99
        AND DISPONIVEL = 1 AND DATA_ATUALIZACAO IS NULL)
      OR (ID_MEDICAMENTO_FARMACIA = 2 AND ID_FARMACIA = 2 AND PRECO = 10.99
        AND DISPONIVEL = 0 AND DATA_ATUALIZACAO = '2026-11-02 09:00:00'));
DELETE FROM MEDICAMENTO
WHERE REGEXP_LIKE(DATABASE(), '^pharmafind_u01_test_migrado_[0-9a-f_]{1,24}$', 'c')
    AND CAST(DATABASE() AS BINARY) = CAST(@u01_banco_descartavel AS BINARY)
    AND ID_MEDICAMENTO = 1 AND NOME = 'Medicamento legado de teste'
    AND PRINCIPIO_ATIVO = 'Ativo ficticio' AND CATEGORIA = 'Teste' AND DOSAGEM = '10 mg' AND APRESENTACAO = 'Comprimido de teste' AND DESCRICAO = 'Fixture';
DELETE FROM FARMACIA
WHERE REGEXP_LIKE(DATABASE(), '^pharmafind_u01_test_migrado_[0-9a-f_]{1,24}$', 'c')
    AND CAST(DATABASE() AS BINARY) = CAST(@u01_banco_descartavel AS BINARY)
    AND ((ID_FARMACIA = 1 AND NOME = 'Farmacia teste A' AND ENDERECO = 'Endereco ficticio A')
      OR (ID_FARMACIA = 2 AND NOME = 'Farmacia teste B' AND ENDERECO = 'Endereco ficticio B'))
    AND CEP IS NULL AND LATITUDE IS NULL AND LONGITUDE IS NULL
    AND HORARIO_ABERTURA IS NULL AND HORARIO_FECHAMENTO IS NULL AND DELIVERY IS NULL;
