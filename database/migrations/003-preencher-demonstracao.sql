-- #33. OPCIONAL e EXPLICITO: somente as seis fixtures U01 com conteudo original conhecido.
-- Executar apos 003a, antes de 003b, fora de outra transacao e sem escritas concorrentes.
-- Nao e SOURCE automatico da migracao; confira previamente os seis IDs e descricoes.
SET NAMES utf8mb4;
DROP TEMPORARY TABLE IF EXISTS pf33_apresentacoes, pf33_apresentacoes_validacao;
CREATE TEMPORARY TABLE pf33_apresentacoes ENGINE=InnoDB AS SELECT * FROM MEDICAMENTO WHERE FALSE;
CREATE TEMPORARY TABLE pf33_apresentacoes_validacao (COMPATIVEL BOOLEAN NOT NULL CHECK (COMPATIVEL = 1));
INSERT INTO pf33_apresentacoes
    (ID_MEDICAMENTO, NOME, PRINCIPIO_ATIVO, CATEGORIA, DOSAGEM, APRESENTACAO, DESCRICAO) VALUES
    (1001, 'Dipirona', 'Dipirona sódica', 'Analgésico', '500 mg', '20 comprimidos', 'Apresentação demonstrativa fictícia: 20 comprimidos.'),
    (1002, 'Dipirona', 'Dipirona sódica', 'Analgésico', '1 g', '10 comprimidos', 'Apresentação demonstrativa fictícia: 10 comprimidos.'),
    (1003, 'Paracetamol', 'Paracetamol', 'Analgésico', '750 mg', '20 comprimidos', 'Apresentação demonstrativa fictícia: 20 comprimidos.'),
    (1004, 'Ibuprofeno', 'Ibuprofeno', 'Anti-inflamatório', '400 mg', '10 cápsulas', 'Apresentação demonstrativa fictícia: 10 cápsulas.'),
    (1005, 'Loratadina', 'Loratadina', 'Antialérgico', '10 mg', '12 comprimidos', 'Apresentação demonstrativa fictícia: 12 comprimidos.'),
    (1006, 'Omeprazol', 'Omeprazol', 'Categoria demonstrativa', '20 mg', '28 cápsulas', 'Apresentação demonstrativa fictícia: 28 cápsulas.');
START TRANSACTION;
SET @pf33_apresentacoes_compativeis = (SELECT COUNT(*) = 6 FROM MEDICAMENTO m JOIN pf33_apresentacoes s
    ON m.ID_MEDICAMENTO = s.ID_MEDICAMENTO
    WHERE CAST(m.NOME AS BINARY) = CAST(s.NOME AS BINARY)
        AND CAST(m.PRINCIPIO_ATIVO AS BINARY) = CAST(s.PRINCIPIO_ATIVO AS BINARY)
        AND CAST(m.CATEGORIA AS BINARY) = CAST(s.CATEGORIA AS BINARY)
        AND CAST(m.DOSAGEM AS BINARY) = CAST(s.DOSAGEM AS BINARY)
        AND CAST(m.DESCRICAO AS BINARY) = CAST(s.DESCRICAO AS BINARY)
        AND (m.APRESENTACAO IS NULL OR CAST(m.APRESENTACAO AS BINARY) = CAST(s.APRESENTACAO AS BINARY)));
INSERT INTO pf33_apresentacoes_validacao VALUES (@pf33_apresentacoes_compativeis);
UPDATE MEDICAMENTO m JOIN pf33_apresentacoes s ON m.ID_MEDICAMENTO = s.ID_MEDICAMENTO
    SET m.APRESENTACAO = s.APRESENTACAO
    WHERE @pf33_apresentacoes_compativeis = 1 AND m.APRESENTACAO IS NULL;
COMMIT;
DROP TEMPORARY TABLE pf33_apresentacoes, pf33_apresentacoes_validacao;
