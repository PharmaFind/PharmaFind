-- U01 complementar / #33. MySQL >= 8.0.16. Backup verificado e SEM escritas concorrentes.
-- DDL tem commit implicito. Nunca usar --force. Leia database/README.md.
-- CREATE PROCEDURE sem IF EXISTS: nao substitui objetos de outra origem.
-- Se CALL falhar, a rotina permanece para diagnostico; siga o procedimento de retomada no README.
SET NAMES utf8mb4;
SET SESSION time_zone = '+00:00';
SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES');
-- ETAPA SEPARADA E DESTRUTIVA. NAO e executada pelas etapas 003a/003b.
-- Primeiro execute CALL pf33_inspecionar_usuario(), revise dados/dependencias e faca backup.
-- Em banco NAO descartavel, apresente o resultado ao solicitante e obtenha aprovacao
-- explicita ANTES de preencher as variaveis e chamar pf33_remover_usuario().
-- Este arquivo apenas INSTALA os auxiliares: nao executa DROP TABLE ao ser carregado.
DELIMITER $$
CREATE PROCEDURE pf33_inspecionar_usuario()
SQL SECURITY INVOKER
BEGIN
    IF (SELECT COUNT(*) FROM information_schema.USER_PRIVILEGES
        WHERE GRANTEE = CONCAT(QUOTE(SUBSTRING_INDEX(CURRENT_USER(),'@',1)), '@',
            QUOTE(SUBSTRING_INDEX(CURRENT_USER(),'@',-1)))
        AND PRIVILEGE_TYPE IN ('SELECT','SHOW VIEW','TRIGGER','EVENT')) <> 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '003c: use conta administrativa com SELECT/SHOW VIEW/TRIGGER/EVENT globais para inspecao completa.';
    END IF;
    SELECT DATABASE() AS banco, VERSION() AS versao;
    IF NOT EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'USUARIO' AND TABLE_TYPE = 'BASE TABLE') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '003c: USUARIO ausente ou nao e tabela; nenhuma exclusao.';
    END IF;
    SELECT COUNT(*) AS quantidade_usuarios FROM USUARIO;
    SELECT TABLE_SCHEMA, TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_SCHEMA, REFERENCED_TABLE_NAME
        FROM information_schema.KEY_COLUMN_USAGE WHERE
        (TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO' AND REFERENCED_TABLE_NAME IS NOT NULL)
        OR (REFERENCED_TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME = 'USUARIO');
    SELECT VIEW_SCHEMA, VIEW_NAME FROM information_schema.VIEW_TABLE_USAGE
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO';
    SELECT TRIGGER_SCHEMA, TRIGGER_NAME FROM information_schema.TRIGGERS
        WHERE (EVENT_OBJECT_SCHEMA = DATABASE() AND EVENT_OBJECT_TABLE = 'USUARIO')
        OR ((TRIGGER_SCHEMA = DATABASE() OR LOCATE(CONCAT(LOWER(DATABASE()),'.'), LOWER(REPLACE(REPLACE(REPLACE(REPLACE(ACTION_STATEMENT,'`',''),' ',''),CHAR(9),''),CHAR(10),''))) > 0) AND REGEXP_LIKE(ACTION_STATEMENT, '(^|[^a-z0-9_])USUARIO([^a-z0-9_]|$)', 'i'));
    SELECT ROUTINE_SCHEMA, ROUTINE_NAME FROM information_schema.ROUTINES
        WHERE NOT (ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME IN
            ('pf33_inspecionar_usuario','pf33_remover_usuario'))
        AND ((ROUTINE_SCHEMA = DATABASE() OR LOCATE(CONCAT(LOWER(DATABASE()),'.'), LOWER(REPLACE(REPLACE(REPLACE(REPLACE(ROUTINE_DEFINITION,'`',''),' ',''),CHAR(9),''),CHAR(10),''))) > 0) AND REGEXP_LIKE(ROUTINE_DEFINITION, '(^|[^a-z0-9_])USUARIO([^a-z0-9_]|$)', 'i'));
    SELECT EVENT_SCHEMA, EVENT_NAME FROM information_schema.EVENTS
        WHERE ((EVENT_SCHEMA = DATABASE() OR LOCATE(CONCAT(LOWER(DATABASE()),'.'), LOWER(REPLACE(REPLACE(REPLACE(REPLACE(EVENT_DEFINITION,'`',''),' ',''),CHAR(9),''),CHAR(10),''))) > 0) AND REGEXP_LIKE(EVENT_DEFINITION, '(^|[^a-z0-9_])USUARIO([^a-z0-9_]|$)', 'i'));
END$$
CREATE PROCEDURE pf33_remover_usuario()
SQL SECURITY INVOKER
BEGIN
    -- A conta deve poder inspecionar TODOS os schemas/objetos (SHOW VIEW/TRIGGER/EVENT e rotinas).
    -- Catalogos podem ocultar dependencias de uma conta limitada; nao executar com visibilidade parcial.
    CALL pf33_inspecionar_usuario();
    IF NOT COALESCE(CAST(@pf33_autorizar_remocao_usuario AS BINARY) = CAST(DATABASE() AS BINARY), FALSE)
        OR NOT COALESCE(CAST(@pf33_backup_usuario_confirmado AS BINARY) = CAST(DATABASE() AS BINARY), FALSE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '003c: falta autorizacao EXATA do alvo e confirmacao de backup recuperavel.';
    END IF;
    IF (SELECT COUNT(*) FROM USUARIO) <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '003c: usuarios cadastrados; preservar tabela e backup. Quantidade listada; requer decisao humana.';
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE WHERE
        (TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO' AND REFERENCED_TABLE_NAME IS NOT NULL)
        OR (REFERENCED_TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME = 'USUARIO'))
        OR EXISTS (SELECT 1 FROM information_schema.VIEW_TABLE_USAGE WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO')
        OR EXISTS (SELECT 1 FROM information_schema.TRIGGERS WHERE
            (EVENT_OBJECT_SCHEMA = DATABASE() AND EVENT_OBJECT_TABLE = 'USUARIO')
            OR ((TRIGGER_SCHEMA = DATABASE() OR LOCATE(CONCAT(LOWER(DATABASE()),'.'), LOWER(REPLACE(REPLACE(REPLACE(REPLACE(ACTION_STATEMENT,'`',''),' ',''),CHAR(9),''),CHAR(10),''))) > 0) AND REGEXP_LIKE(ACTION_STATEMENT, '(^|[^a-z0-9_])USUARIO([^a-z0-9_]|$)', 'i')))
        OR EXISTS (SELECT 1 FROM information_schema.ROUTINES WHERE
            NOT (ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME IN ('pf33_inspecionar_usuario','pf33_remover_usuario'))
            AND ((ROUTINE_SCHEMA = DATABASE() OR LOCATE(CONCAT(LOWER(DATABASE()),'.'), LOWER(REPLACE(REPLACE(REPLACE(REPLACE(ROUTINE_DEFINITION,'`',''),' ',''),CHAR(9),''),CHAR(10),''))) > 0) AND REGEXP_LIKE(ROUTINE_DEFINITION, '(^|[^a-z0-9_])USUARIO([^a-z0-9_]|$)', 'i')))
        OR EXISTS (SELECT 1 FROM information_schema.EVENTS WHERE
            ((EVENT_SCHEMA = DATABASE() OR LOCATE(CONCAT(LOWER(DATABASE()),'.'), LOWER(REPLACE(REPLACE(REPLACE(REPLACE(EVENT_DEFINITION,'`',''),' ',''),CHAR(9),''),CHAR(10),''))) > 0) AND REGEXP_LIKE(EVENT_DEFINITION, '(^|[^a-z0-9_])USUARIO([^a-z0-9_]|$)', 'i'))) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '003c: dependencias detectadas; USUARIO preservada. Revise os objetos listados.';
    END IF;
    -- Consumir autorizacoes antes de DDL; nao permite reutiliza-las em outro banco/chamada.
    SET @pf33_autorizar_remocao_usuario = NULL;
    SET @pf33_backup_usuario_confirmado = NULL;
    DROP TABLE USUARIO;
    SELECT '003c: USUARIO vazia removida; dados do dominio preservados.' AS resultado;
END$$
DELIMITER ;
