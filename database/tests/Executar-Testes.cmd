@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Alternativa nativa do Windows: nao executa PowerShell nem altera ExecutionPolicy.
rem Usa root em 127.0.0.1:3306 e solicita a senha somente no cliente MySQL.
set "U01_MYSQL=%~1"
if not defined U01_MYSQL set "U01_MYSQL=%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe"
if not exist "%U01_MYSQL%" (
    echo ERRO: mysql.exe nao encontrado. Informe seu caminho como primeiro argumento.
    exit /b 2
)
if not "%~3"=="" (
    echo ERRO: uso: Executar-Testes.cmd caminho_mysql [identificador_descartavel]. Nao passe senhas.
    exit /b 2
)
if not defined TEMP (
    echo ERRO: diretorio TEMP nao definido.
    exit /b 2
)

pushd "%~dp0..\.."
if errorlevel 1 exit /b 2

for %%F in (
    "database\PharmaFindDB.sql"
    "database\tests\assercoes.sql"
    "database\tests\esquema.sql"
    "database\tests\demonstracao.sql"
    "database\seeds\demonstracao.sql"
    "database\seeds\ceps-teste.json"
    "database\tests\legado.sql"
    "database\tests\migracao-antes.sql"
    "database\tests\migracao-preenchimento.sql"
    "database\tests\migracao-depois.sql"
    "database\tests\protecao-fixtures.sql"
    "database\tests\protecao-preservacao.sql"
    "database\tests\protecao-limpeza-autorizada.sql"
    "database\migrations\001-preparar-ofertas.sql"
    "database\migrations\002-consolidar-ofertas.sql"
) do (
    if not exist "%%~F" (
        echo ERRO: arquivo SQL necessario nao encontrado: %%~F
        popd
        exit /b 2
    )
)

rem Nomes gerados internamente; CREATE sem IF NOT EXISTS impede reutilizar uma base existente.
set "U01_SUFFIX=%RANDOM%_%RANDOM%_%RANDOM%"
if not "%~2"=="" set "U01_SUFFIX=%~2"
set U01_SUFFIX | findstr /r /x "U01_SUFFIX=[0-9a-f_][0-9a-f_]*" >nul
if errorlevel 1 (
    echo ERRO: identificador deve conter apenas 0-9, a-f e sublinhado.
    popd
    exit /b 2
)
if not "%U01_SUFFIX:~24,1%"=="" (
    echo ERRO: identificador deve ter no maximo 24 caracteres.
    popd
    exit /b 2
)
set "U01_NEW_DB=pharmafind_u01_test_novo_%U01_SUFFIX%"
set "U01_MIGRATED_DB=pharmafind_u01_test_migrado_%U01_SUFFIX%"
set "U01_GUARD_DB=pharmafind_u01_test_protecao_%U01_SUFFIX%"
set "U01_SQL_FILE=%TEMP%\pharmafind_u01_%U01_SUFFIX%.sql"
set "U01_EXISTENCE_FILE=%TEMP%\pharmafind_u01_%U01_SUFFIX%_existencia.txt"
if exist "%U01_SQL_FILE%" (
    echo ERRO: arquivo temporario ja existe. Execute novamente para gerar outro nome.
    popd
    exit /b 2
)
if exist "%U01_EXISTENCE_FILE%" (
    echo ERRO: arquivo temporario de consulta ja existe. Use outro identificador.
    popd
    exit /b 2
)

echo Bancos exclusivos planejados: %U01_NEW_DB%, %U01_MIGRATED_DB%, %U01_GUARD_DB%
echo Primeira conexao: consulta somente leitura para verificar existencia previa.
"%U01_MYSQL%" --host=127.0.0.1 --port=3306 --user=root --password --connect-timeout=5 --batch --raw --skip-column-names --skip-force --execute="SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME IN ('%U01_NEW_DB%', '%U01_MIGRATED_DB%', '%U01_GUARD_DB%');" > "%U01_EXISTENCE_FILE%"
set "U01_EXIT=%ERRORLEVEL%"
if not "%U01_EXIT%"=="0" (
    del /q "%U01_EXISTENCE_FILE%"
    echo ERRO: consulta de existencia falhou. Nenhum teste SQL foi iniciado.
    popd
    exit /b %U01_EXIT%
)
for %%S in ("%U01_EXISTENCE_FILE%") do if not %%~zS==0 (
    echo ERRO: bancos ja existentes. Execucao recusada antes dos testes:
    type "%U01_EXISTENCE_FILE%"
    del /q "%U01_EXISTENCE_FILE%"
    popd
    exit /b 2
)
del /q "%U01_EXISTENCE_FILE%"
echo Ausencia confirmada. Segunda conexao: somente bancos descartaveis novos.

rem Concatena os mesmos arquivos reais utilizados pelo runner PowerShell.
rem O arquivo temporario contem apenas SQL de teste, nunca credenciais.
(
    echo SET NAMES utf8mb4;
    echo SELECT VERSION^(^) AS versao_servidor;
    echo CREATE DATABASE %U01_NEW_DB% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo CREATE DATABASE %U01_MIGRATED_DB% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo CREATE DATABASE %U01_GUARD_DB% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo USE %U01_NEW_DB%;
    echo SET @u01_banco_descartavel = NULL;
    type "database\PharmaFindDB.sql"
    echo.
    type "database\tests\assercoes.sql"
    echo.
    type "database\tests\esquema.sql"
    echo.
    echo SET @u01_ceps_json = '
    type "database\seeds\ceps-teste.json"
    echo.
    echo ';
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_seed_em_teste^(^)
    echo BEGIN
    type "database\seeds\demonstracao.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    type "database\tests\demonstracao.sql"
    echo.
    echo USE %U01_MIGRATED_DB%;
    type "database\tests\legado.sql"
    echo.
    type "database\tests\assercoes.sql"
    echo.
    type "database\tests\migracao-antes.sql"
    echo.
    type "database\migrations\001-preparar-ofertas.sql"
    echo.
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_consolidar_em_teste^(^)
    echo BEGIN
    type "database\migrations\002-consolidar-ofertas.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    type "database\tests\migracao-preenchimento.sql"
    echo.
    type "database\migrations\002-consolidar-ofertas.sql"
    echo.
    echo SET @u01_banco_descartavel = NULL;
    type "database\tests\migracao-depois.sql"
    echo.
    type "database\tests\protecao-preservacao.sql"
    echo.
    echo SET @u01_banco_descartavel = 'pharmafind_demo';
    type "database\tests\migracao-depois.sql"
    echo.
    type "database\tests\protecao-preservacao.sql"
    echo.
    echo SET @u01_banco_descartavel = DATABASE^(^);
    type "database\tests\migracao-depois.sql"
    echo.
    echo SET @u01_banco_descartavel = NULL;
    type "database\tests\protecao-limpeza-autorizada.sql"
    echo.
    echo.
    type "database\tests\esquema.sql"
    echo.
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_seed_em_teste^(^)
    echo BEGIN
    type "database\seeds\demonstracao.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    type "database\tests\demonstracao.sql"
    echo.
    echo USE %U01_GUARD_DB%;
    type "database\PharmaFindDB.sql"
    echo.
    type "database\tests\protecao-fixtures.sql"
    echo.
    echo SET @u01_banco_descartavel = DATABASE^(^);
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_executar_limpeza_isolada^(^)
    echo BEGIN
    echo DECLARE CONTINUE HANDLER FOR 1305 BEGIN END;
    type "database\tests\migracao-depois.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    echo CALL u01_executar_limpeza_isolada^(^);
    echo SET @u01_banco_descartavel = NULL;
    type "database\tests\assercoes.sql"
    echo.
    type "database\tests\protecao-preservacao.sql"
    echo.
    echo DROP DATABASE %U01_GUARD_DB%;
    echo DROP DATABASE %U01_MIGRATED_DB%;
    echo DROP DATABASE %U01_NEW_DB%;
) > "%U01_SQL_FILE%"
if errorlevel 1 (
    echo ERRO: nao foi possivel preparar o SQL de teste. MySQL nao foi iniciado.
    if exist "%U01_SQL_FILE%" del /q "%U01_SQL_FILE%"
    popd
    exit /b 2
)

echo Bancos exclusivos de teste: %U01_NEW_DB%, %U01_MIGRATED_DB%, %U01_GUARD_DB%
echo Sucesso remove somente esses bancos. Falha os preserva para inspecao.
"%U01_MYSQL%" --host=127.0.0.1 --port=3306 --user=root --password --connect-timeout=5 --default-character-set=utf8mb4 --batch --raw --skip-force < "%U01_SQL_FILE%"
set "U01_EXIT=%ERRORLEVEL%"
del /q "%U01_SQL_FILE%"
if not "%U01_EXIT%"=="0" (
    echo ERRO: testes interrompidos. Confira a mensagem do MySQL e os nomes dos bancos acima.
    popd
    exit /b %U01_EXIT%
)
echo SUCESSO: esquema, migracao, massa e protecao da limpeza passaram; tres bancos exclusivos removidos.
popd
exit /b 0
