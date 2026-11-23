-- Auxiliares exclusivos dos bancos descartaveis criados pelos runners de teste.
DELIMITER $$
CREATE PROCEDURE u01_assert(IN condicao BOOLEAN, IN descricao VARCHAR(128))
BEGIN
    IF NOT COALESCE(condicao, FALSE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = descricao;
    END IF;
    SELECT CONCAT('OK: ', descricao) AS resultado;
END$$

CREATE PROCEDURE u01_esperar_erro(IN comando TEXT, IN codigos VARCHAR(80), IN descricao VARCHAR(128))
BEGIN
    DECLARE erro_recebido INT DEFAULT 0;
    BEGIN
        -- No ALTER de NULL para NOT NULL, o modo estrito pode rejeitar com 1265/01000.
        -- SQLEXCEPTION sozinho nao abrange SQLSTATE iniciado por 01.
        -- Capturar somente esse codigo adicional; a lista esperada abaixo continua obrigatoria.
        DECLARE CONTINUE HANDLER FOR 1265, SQLEXCEPTION
            GET DIAGNOSTICS CONDITION 1 erro_recebido = MYSQL_ERRNO;
        SET @u01_comando = comando;
        PREPARE u01_instrucao FROM @u01_comando;
        IF erro_recebido = 0 THEN
            EXECUTE u01_instrucao;
            DEALLOCATE PREPARE u01_instrucao;
        END IF;
    END;
    CALL u01_assert(erro_recebido <> 0 AND FIND_IN_SET(erro_recebido, codigos) > 0, descricao);
END$$
DELIMITER ;
