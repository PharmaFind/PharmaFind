-- #33. Esquema U01 e seed originais, exclusivamente no quarto banco descartavel.
CALL u01_seed_anterior_em_teste();
INSERT INTO HISTORICO_PRECO (ID_HISTORICO_PRECO,ID_MEDICAMENTO_FARMACIA,PRECO,DATA_REGISTRO)
VALUES (4001,3001,8.99,'2026-11-01');
CREATE TEMPORARY TABLE pf33_medicamentos_antes AS SELECT * FROM MEDICAMENTO;
CREATE TEMPORARY TABLE pf33_farmacias_antes AS SELECT * FROM FARMACIA;
CREATE TEMPORARY TABLE pf33_ofertas_antes AS SELECT * FROM MEDICAMENTO_FARMACIA;
CREATE TEMPORARY TABLE pf33_historico_antes AS SELECT * FROM HISTORICO_PRECO;
UPDATE HISTORICO_PRECO SET PRECO = 0 WHERE ID_HISTORICO_PRECO = 4001;
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa historico zero sem alterar estrutura');
UPDATE HISTORICO_PRECO SET PRECO = -1 WHERE ID_HISTORICO_PRECO = 4001;
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa historico negativo');
UPDATE HISTORICO_PRECO SET PRECO = 8.99 WHERE ID_HISTORICO_PRECO = 4001;
INSERT INTO HISTORICO_PRECO (ID_HISTORICO_PRECO,ID_MEDICAMENTO_FARMACIA,PRECO,DATA_REGISTRO)
VALUES (4002,3001,9.99,'2026-11-01');
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa duplicidade preexistente');
DELETE FROM HISTORICO_PRECO WHERE ID_HISTORICO_PRECO = 4002;
UPDATE FARMACIA SET CEP = 'ABC' WHERE ID_FARMACIA = 2001;
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa CEP preexistente invalido');
UPDATE FARMACIA SET CEP = '72429005', LATITUDE = 999 WHERE ID_FARMACIA = 2001;
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa latitude preexistente invalida');
UPDATE FARMACIA SET LATITUDE = -15.9960000, LONGITUDE = NULL WHERE ID_FARMACIA = 2001;
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa coordenadas preexistentes parciais');
UPDATE FARMACIA SET LONGITUDE = -48.0560000 WHERE ID_FARMACIA = 2001;
ALTER TABLE FARMACIA ADD CONSTRAINT CK_FARMACIA_CEP CHECK (1 = 1);
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa colisao de constraint');
ALTER TABLE FARMACIA DROP CHECK CK_FARMACIA_CEP;
ALTER TABLE FARMACIA ADD COLUMN PF33_EXTRA INT;
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa estrutura inesperada');
ALTER TABLE FARMACIA DROP COLUMN PF33_EXTRA;
CREATE INDEX UQ_MEDICAMENTO_IDENTIDADE ON MEDICAMENTO (NOME);
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa colisao de indice independente');
DROP INDEX UQ_MEDICAMENTO_IDENTIDADE ON MEDICAMENTO;
ALTER TABLE MEDICAMENTO MODIFY NOME VARCHAR(150) COLLATE utf8mb4_0900_ai_ci NOT NULL;
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa collation divergente sem converter');
ALTER TABLE MEDICAMENTO MODIFY NOME VARCHAR(150) COLLATE utf8mb4_unicode_ci NOT NULL;
CALL u01_assert((SELECT COUNT(*) = 0 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'MEDICAMENTO' AND COLUMN_NAME = 'APRESENTACAO'), 'Recusas 003a nao adicionam colunas');
CALL pf33_preparar_integridade();
CALL u01_esperar_erro('CALL pf33_preparar_integridade()',1644,'003a recusa reaplicacao');
CALL u01_assert((SELECT COUNT(*) = 6 FROM MEDICAMENTO WHERE APRESENTACAO IS NULL),
    '003a nao inventa apresentacoes nem muda IDs');
CALL u01_esperar_erro('CALL pf33_consolidar_integridade()',1644,'003b recusa apresentacoes desconhecidas');
UPDATE MEDICAMENTO SET APRESENTACAO = '   ' WHERE ID_MEDICAMENTO = 1001;
CALL u01_esperar_erro('CALL pf33_consolidar_integridade()',1644,'003b recusa apresentacoes vazias');
UPDATE MEDICAMENTO SET APRESENTACAO = NULL WHERE ID_MEDICAMENTO = 1001;
