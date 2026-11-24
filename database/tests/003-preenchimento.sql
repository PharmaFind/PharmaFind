-- #33. Usar somente depois de 003-antes, nos dados descartaveis originais.
SET @pf33_descricao_original = (SELECT DESCRICAO FROM MEDICAMENTO WHERE ID_MEDICAMENTO = 1001);
UPDATE MEDICAMENTO SET DESCRICAO = CONCAT(DESCRICAO, ' editada') WHERE ID_MEDICAMENTO = 1001;
CALL u01_esperar_erro('CALL pf33_preencher_em_teste()',3819,'Preenchimento opcional recusa conteudo alterado');
ROLLBACK;
CALL u01_assert((SELECT COUNT(*) = 6 FROM MEDICAMENTO WHERE APRESENTACAO IS NULL)
    AND (SELECT DESCRICAO = CONCAT(@pf33_descricao_original, ' editada') FROM MEDICAMENTO WHERE ID_MEDICAMENTO = 1001),
    'Recusa do preenchimento preserva conteudo e nao preenche parcialmente');
UPDATE MEDICAMENTO SET DESCRICAO = @pf33_descricao_original WHERE ID_MEDICAMENTO = 1001;
INSERT INTO MEDICAMENTO (ID_MEDICAMENTO,NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,DESCRICAO)
VALUES (9997,'Medicamento externo de teste','Teste','Teste','1 mg','Apresentacao nao documentada');
CALL pf33_preencher_em_teste();
CALL u01_assert((SELECT APRESENTACAO IS NULL FROM MEDICAMENTO WHERE ID_MEDICAMENTO = 9997),
    'Preenchimento de fixtures nao inventa apresentacao para medicamento externo');
CALL u01_esperar_erro('CALL pf33_consolidar_integridade()',1644,'Medicamento externo desconhecido bloqueia consolidacao');
DELETE FROM MEDICAMENTO WHERE ID_MEDICAMENTO = 9997 AND NOME = 'Medicamento externo de teste';
DROP PROCEDURE pf33_preencher_em_teste;
