-- #33. Rodar somente em bancos descartaveis novos dos runners.
START TRANSACTION;
INSERT INTO MEDICAMENTO (ID_MEDICAMENTO,NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO)
VALUES (8001,'Integridade','Teste','Teste','10 mg','10 comprimidos','Fixture'),
       (8002,'Integridade','Teste','Teste','20 mg','10 comprimidos','Fixture'),
       (8003,'Integridade','Teste','Teste','10 mg','20 comprimidos','Fixture');
CALL u01_assert((SELECT COUNT(*) = 3 FROM MEDICAMENTO WHERE ID_MEDICAMENTO BETWEEN 8001 AND 8003),
    'Identidades com outra dosagem ou apresentacao coexistem');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO) VALUES (''Integridade'',''Teste'',''Teste'',''10 mg'',''10 comprimidos'',''Fixture'')', '1062', 'Identidade identica rejeitada');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO) VALUES (''Integridade'',''Teste'',''Teste'',''10 mg'',NULL,''Fixture'')', '1048', 'Apresentacao NULL rejeitada');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO) VALUES (''Integridade'',''Teste'',''Teste'',''10 mg'','''',''Fixture'')', '3819', 'Apresentacao vazia rejeitada');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO) VALUES (''Integridade'',''Teste'',''Teste'',''10 mg'',''   '',''Fixture'')', '3819', 'Apresentacao em branco rejeitada');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO) VALUES (''INTEGRIDADE'',''Teste'',''Teste'',''10 mg'',''10 comprimidos'',''Fixture'')', '1062', 'Identidade respeita collation sem distinguir caixa');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO) VALUES (''Integrídade'',''Teste'',''Teste'',''10 mg'',''10 comprimidos'',''Fixture'')', '1062', 'Identidade respeita collation sem distinguir acento');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,APRESENTACAO,DESCRICAO) VALUES (''Integridade'',''Teste'',''Teste'',''10 mg'',''10 comprimidos '',''Fixture'')', '1062', 'Identidade respeita PAD SPACE');
CALL u01_esperar_erro('INSERT INTO MEDICAMENTO (NOME,PRINCIPIO_ATIVO,CATEGORIA,DOSAGEM,DESCRICAO) VALUES (''Falta'',''Teste'',''Teste'',''1 mg'',''Fixture'')', '1364', 'Apresentacao omitida rejeitada');
INSERT INTO FARMACIA (ID_FARMACIA,NOME,ENDERECO,CEP,LATITUDE,LONGITUDE)
VALUES (8001,'Teste','Ficticio','72429005',-90,-180), (8002,'Teste','Ficticio',NULL,90,180),
       (8003,'Teste','Ficticio',NULL,NULL,NULL);
CALL u01_assert((SELECT COUNT(*) = 3 FROM FARMACIA WHERE ID_FARMACIA BETWEEN 8001 AND 8003),
    'CEP valido, limites geograficos e ausencia legitima aceitos');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,CEP) VALUES (''Teste'',''Ficticio'',''ABC'')', '3819', 'CEP ABC rejeitado');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,CEP) VALUES (''Teste'',''Ficticio'',''1234567'')', '3819', 'CEP 1234567 rejeitado');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,CEP) VALUES (''Teste'',''Ficticio'',''123456789'')', '1406', 'CEP 123456789 rejeitado');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,CEP) VALUES (''Teste'',''Ficticio'','''')', '3819', 'CEP vazio rejeitado');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,CEP) VALUES (''Teste'',''Ficticio'',''１２３４５６７８'')', '3819', 'CEP １２３４５６７８ rejeitado');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,LATITUDE,LONGITUDE) VALUES (''Teste'',''Ficticio'',999,0)', '3819', 'Latitude 999 rejeitada');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,LATITUDE,LONGITUDE) VALUES (''Teste'',''Ficticio'',0,200)', '3819', 'Longitude 200 rejeitada');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,LATITUDE,LONGITUDE) VALUES (''Teste'',''Ficticio'',-90.0000001,0)', '3819', 'Latitude abaixo do limite rejeitada');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,LATITUDE,LONGITUDE) VALUES (''Teste'',''Ficticio'',0,-180.0000001)', '3819', 'Longitude abaixo do limite rejeitada');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,LATITUDE,LONGITUDE) VALUES (''Teste'',''Ficticio'',NULL,0)', '3819', 'Latitude ausente isoladamente rejeitada');
CALL u01_esperar_erro('INSERT INTO FARMACIA (NOME,ENDERECO,LATITUDE,LONGITUDE) VALUES (''Teste'',''Ficticio'',0,NULL)', '3819', 'Longitude ausente isoladamente rejeitada');
CALL u01_esperar_erro('UPDATE FARMACIA SET CEP = ''ABC'' WHERE ID_FARMACIA = 8001', '3819', 'CEP invalido rejeitado em UPDATE');
CALL u01_esperar_erro('UPDATE FARMACIA SET LONGITUDE = NULL WHERE ID_FARMACIA = 8001', '3819', 'Coordenada parcial rejeitada em UPDATE');
INSERT INTO MEDICAMENTO_FARMACIA (ID_MEDICAMENTO_FARMACIA,ID_MEDICAMENTO,ID_FARMACIA,PRECO,DISPONIVEL)
VALUES (8001,8001,8001,10,1),(8002,8001,8002,10,1);
INSERT INTO HISTORICO_PRECO (ID_MEDICAMENTO_FARMACIA,PRECO,DATA_REGISTRO)
VALUES (8001,10,'2026-11-01'),(8001,11,'2026-11-02'),(8002,12,'2026-11-01');
CALL u01_assert((SELECT COUNT(*) = 3 FROM HISTORICO_PRECO WHERE ID_MEDICAMENTO_FARMACIA IN (8001,8002)),
    'Historico positivo aceita datas diferentes e ofertas diferentes na mesma data');
CALL u01_esperar_erro('INSERT INTO HISTORICO_PRECO (ID_MEDICAMENTO_FARMACIA,PRECO,DATA_REGISTRO) VALUES (8001,-1,''2026-11-03'')', '3819', 'Historico negativo rejeitado');
CALL u01_esperar_erro('INSERT INTO HISTORICO_PRECO (ID_MEDICAMENTO_FARMACIA,PRECO,DATA_REGISTRO) VALUES (8001,0,''2026-11-03'')', '3819', 'Historico zero rejeitado');
CALL u01_esperar_erro('INSERT INTO HISTORICO_PRECO (ID_MEDICAMENTO_FARMACIA,PRECO,DATA_REGISTRO) VALUES (8001,20,''2026-11-01'')', '1062', 'Historico oferta data repetida rejeitado');
CALL u01_esperar_erro('INSERT INTO HISTORICO_PRECO (ID_MEDICAMENTO_FARMACIA,PRECO,DATA_REGISTRO) VALUES (999999,10,''2026-11-01'')', '1452', 'Historico FK inexistente rejeitada');
CALL u01_esperar_erro('UPDATE HISTORICO_PRECO SET PRECO = 0 WHERE ID_MEDICAMENTO_FARMACIA = 8001', '3819', 'Historico preco invalido rejeitado em UPDATE');
CALL u01_esperar_erro('UPDATE HISTORICO_PRECO SET DATA_REGISTRO = ''2026-11-01'' WHERE ID_MEDICAMENTO_FARMACIA = 8001 AND DATA_REGISTRO = ''2026-11-02''', '1062', 'Historico duplicado rejeitado em UPDATE');
CALL u01_esperar_erro('DELETE FROM MEDICAMENTO_FARMACIA WHERE ID_MEDICAMENTO_FARMACIA = 8001', '1451', 'Historico impede exclusao da oferta referenciada');
CALL u01_assert((SELECT COUNT(*) = 0 FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'USUARIO'), 'MVP nao possui tabela de autenticacao');
ROLLBACK;
