-- #33. Somente bancos descartaveis CRIADOS nesta rodada. Sem banco arbitrario.
CALL u01_assert(REGEXP_LIKE(DATABASE(), '^pharmafind_u01_test_(migrado|integridade)_[0-9a-f_]{1,24}$','c')
    AND CAST(@u01_banco_descartavel AS BINARY) = CAST(DATABASE() AS BINARY),
    'Remocao USUARIO limitada ao banco descartavel marcado pelo runner');
SET @pf33_autorizar_remocao_usuario = NULL;
SET @pf33_backup_usuario_confirmado = NULL;
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO preservada sem autorizacao');
SET @pf33_autorizar_remocao_usuario = 'pharmafind_demo';
SET @pf33_backup_usuario_confirmado = DATABASE();
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO preservada com alvo errado');
SET @pf33_autorizar_remocao_usuario = DATABASE();
SET @pf33_backup_usuario_confirmado = NULL;
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO preservada sem backup confirmado');
-- Fixture recuperavel: definicao integral de USUARIO no snapshot U01 versionado.
SET @pf33_backup_usuario_confirmado = DATABASE();
INSERT INTO USUARIO (ID_USUARIO,NOME,EMAIL,SENHA) VALUES (9101,'Fixture','fixture@example.invalid','fixture_sem_autenticacao');
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO com registros nunca e apagada automaticamente');
CALL u01_assert((SELECT COUNT(*) = 1 FROM USUARIO), 'Quantidade de usuarios preservada apos recusa');
DELETE FROM USUARIO WHERE ID_USUARIO = 9101 AND EMAIL = 'fixture@example.invalid';
CREATE TABLE pf33_dependencia (ID INT, CONSTRAINT FK_PF33_TESTE FOREIGN KEY (ID) REFERENCES USUARIO(ID_USUARIO));
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO com FK dependente preservada');
DROP TABLE pf33_dependencia;
CREATE VIEW pf33_view AS SELECT ID_USUARIO FROM USUARIO;
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO com view dependente preservada');
DROP VIEW pf33_view;
DELIMITER $$
CREATE PROCEDURE pf33_referencia_teste() BEGIN SELECT COUNT(*) FROM USUARIO; END$$
DELIMITER ;
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO referenciada em rotina preservada');
DROP PROCEDURE pf33_referencia_teste;
CREATE TRIGGER pf33_trigger BEFORE INSERT ON USUARIO FOR EACH ROW SET NEW.NOME = NEW.NOME;
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO com trigger preservada');
DROP TRIGGER pf33_trigger;
CREATE EVENT pf33_evento ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 DAY
    DO SET @pf33_evento_teste = (SELECT COUNT(*) FROM USUARIO);
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'USUARIO referenciada em evento preservada');
DROP EVENT pf33_evento;
SET @pf33_medicamentos = (SELECT COUNT(*) FROM MEDICAMENTO);
SET @pf33_farmacias = (SELECT COUNT(*) FROM FARMACIA);
SET @pf33_ofertas = (SELECT COUNT(*) FROM MEDICAMENTO_FARMACIA);
SET @pf33_historico = (SELECT COUNT(*) FROM HISTORICO_PRECO);
CALL pf33_remover_usuario();
CALL u01_assert((SELECT COUNT(*) = 4 FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_TYPE = 'BASE TABLE'), 'Remocao controlada deixa quatro tabelas');
CALL u01_assert((SELECT COUNT(*) = @pf33_medicamentos FROM MEDICAMENTO)
    AND (SELECT COUNT(*) = @pf33_farmacias FROM FARMACIA)
    AND (SELECT COUNT(*) = @pf33_ofertas FROM MEDICAMENTO_FARMACIA)
    AND (SELECT COUNT(*) = @pf33_historico FROM HISTORICO_PRECO), 'Remover USUARIO preserva os quatro conjuntos de dominio');
CALL u01_assert(@pf33_autorizar_remocao_usuario IS NULL AND @pf33_backup_usuario_confirmado IS NULL,
    'Autorizacoes de remocao consumidas antes do DDL');
CALL u01_esperar_erro('CALL pf33_remover_usuario()',1644,'Reaplicar remocao de USUARIO recusa tabela ausente');
DROP PROCEDURE pf33_remover_usuario;
DROP PROCEDURE pf33_inspecionar_usuario;
