-- U01 / #10. Executar UMA vez sobre o esquema legado, com backup e sem escritas concorrentes.
-- Nao executar sobre banco criado com a versao nova de PharmaFindDB.sql.
SET SESSION time_zone = '+00:00';
SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES');

-- Sem defaults de negocio nem atualizacao automatica durante o preenchimento manual.
-- A disponibilidade e a data dos registros antigos permanecem desconhecidas (NULL).
ALTER TABLE MEDICAMENTO_FARMACIA
    ADD COLUMN DISPONIVEL BOOLEAN NULL DEFAULT NULL,
    ADD COLUMN DATA_ATUALIZACAO TIMESTAMP NULL DEFAULT NULL;
