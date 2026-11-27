@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Runner nativo; nao chama PowerShell nem altera ExecutionPolicy.
set "U01_MYSQL=%~1"
if not defined U01_MYSQL set "U01_MYSQL=%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe"
if not exist "%U01_MYSQL%" exit /b 2
if not "%~5"=="" exit /b 2
set "U01_SUFFIX=%RANDOM%_%RANDOM%_%RANDOM%"
if not "%~2"=="" set "U01_SUFFIX=%~2"
set U01_SUFFIX | findstr /r /x "U01_SUFFIX=[0-9a-f_][0-9a-f_]*" >nul
if errorlevel 1 exit /b 2
if not "%U01_SUFFIX:~24,1%"=="" exit /b 2
set "U01_PORT=3306"
if not "%~3"=="" set "U01_PORT=%~3"
set U01_PORT | findstr /r /x "U01_PORT=[0-9][0-9]*" >nul
if errorlevel 1 exit /b 2
if not "%U01_PORT:~5,1%"=="" exit /b 2
if %U01_PORT% LSS 1 exit /b 2
if %U01_PORT% GTR 65535 exit /b 2
set "U01_AUTH=--password"
if "%~4"=="--sem-senha" set "U01_AUTH=--skip-password"
if not "%~4"=="" if not "%~4"=="--sem-senha" exit /b 2
if not defined TEMP exit /b 2
set "U01_NOVO=pharmafind_u01_test_novo_%U01_SUFFIX%"
set "U01_MIGRADO=pharmafind_u01_test_migrado_%U01_SUFFIX%"
set "U01_PROTECAO=pharmafind_u01_test_protecao_%U01_SUFFIX%"
set "U01_INTEGRIDADE=pharmafind_u01_test_integridade_%U01_SUFFIX%"
set "U01_SQL=%TEMP%\pharmafind_u01_%U01_SUFFIX%.sql"
set "U01_EXIST=%TEMP%\pharmafind_u01_%U01_SUFFIX%_existencia.txt"
if exist "%U01_SQL%" exit /b 2
if exist "%U01_EXIST%" exit /b 2
pushd "%~dp0.."
if errorlevel 1 exit /b 2
if not exist "PharmaFindDB.sql" goto :erro_preparacao
if not exist "tests\assercoes.sql" goto :erro_preparacao
if not exist "tests\esquema.sql" goto :erro_preparacao
if not exist "tests\integridade.sql" goto :erro_preparacao
if not exist "seeds\ceps-teste.json" goto :erro_preparacao
if not exist "seeds\demonstracao.sql" goto :erro_preparacao
if not exist "tests\demonstracao.sql" goto :erro_preparacao
if not exist "tests\legado.sql" goto :erro_preparacao
if not exist "tests\migracao-antes.sql" goto :erro_preparacao
if not exist "migrations\001-preparar-ofertas.sql" goto :erro_preparacao
if not exist "migrations\002-consolidar-ofertas.sql" goto :erro_preparacao
if not exist "tests\migracao-preenchimento.sql" goto :erro_preparacao
if not exist "migrations\003a-preparar-integridade.sql" goto :erro_preparacao
if not exist "migrations\003b-restricoes-integridade.sql" goto :erro_preparacao
if not exist "migrations\003c-remover-usuario.sql" goto :erro_preparacao
if not exist "tests\usuario.sql" goto :erro_preparacao
if not exist "tests\migracao-depois.sql" goto :erro_preparacao
if not exist "tests\protecao-preservacao.sql" goto :erro_preparacao
if not exist "tests\protecao-limpeza-autorizada.sql" goto :erro_preparacao
if not exist "tests\u01-antes-003.sql" goto :erro_preparacao
if not exist "tests\seed-antes-003.sql" goto :erro_preparacao
if not exist "tests\003-antes.sql" goto :erro_preparacao
if not exist "tests\003-preenchimento.sql" goto :erro_preparacao
if not exist "migrations\003-preencher-demonstracao.sql" goto :erro_preparacao
if not exist "tests\003-depois.sql" goto :erro_preparacao
if not exist "tests\protecao-fixtures.sql" goto :erro_preparacao
echo Bancos descartaveis: %U01_NOVO%, %U01_MIGRADO%, %U01_PROTECAO%, %U01_INTEGRIDADE%
"%U01_MYSQL%" --host=127.0.0.1 --port=%U01_PORT% --user=root %U01_AUTH% --connect-timeout=5 --batch --raw --skip-column-names --skip-force --execute="SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME IN ('%U01_NOVO%','%U01_MIGRADO%','%U01_PROTECAO%','%U01_INTEGRIDADE%');" > "%U01_EXIST%"
if errorlevel 1 goto :erro_consulta
for %%S in ("%U01_EXIST%") do if not %%~zS==0 goto :erro_existente
del /q "%U01_EXIST%"
(
    echo SET NAMES utf8mb4;
    echo SELECT VERSION^(^) AS versao_servidor, @@lower_case_table_names AS lower_case_table_names;
    echo SET SESSION time_zone = '+00:00';
    echo SET SESSION sql_mode = CONCAT_WS^(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES'^);
    echo CREATE DATABASE %U01_NOVO% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo CREATE DATABASE %U01_MIGRADO% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo CREATE DATABASE %U01_PROTECAO% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo CREATE DATABASE %U01_INTEGRIDADE% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    echo USE %U01_NOVO%;
    echo SET @u01_banco_descartavel = NULL;
    type "PharmaFindDB.sql"
    echo.
    type "tests\assercoes.sql"
    echo.
    type "tests\esquema.sql"
    echo.
    type "tests\integridade.sql"
    echo.
    echo SET @u01_ceps_json = '
    type "seeds\ceps-teste.json"
    echo.
    echo ';
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_seed_em_teste^(^)
    echo BEGIN
    type "seeds\demonstracao.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    type "tests\demonstracao.sql"
    echo.
    echo USE %U01_MIGRADO%;
    type "tests\legado.sql"
    echo.
    type "tests\assercoes.sql"
    echo.
    type "tests\migracao-antes.sql"
    echo.
    type "migrations\001-preparar-ofertas.sql"
    echo.
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_consolidar_em_teste^(^)
    echo BEGIN
    type "migrations\002-consolidar-ofertas.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    type "tests\migracao-preenchimento.sql"
    echo.
    type "migrations\002-consolidar-ofertas.sql"
    echo.
    findstr /v /l /b /c:"CALL pf33_preparar_integridade();" /c:"DROP PROCEDURE pf33_preparar_integridade;" "migrations\003a-preparar-integridade.sql"
    echo.
    findstr /v /l /b /c:"CALL pf33_consolidar_integridade();" /c:"DROP PROCEDURE pf33_consolidar_integridade;" "migrations\003b-restricoes-integridade.sql"
    echo.
    echo CALL pf33_preparar_integridade^(^);
    echo UPDATE MEDICAMENTO SET APRESENTACAO = 'Comprimido de teste' WHERE ID_MEDICAMENTO = 1;
    echo CALL pf33_consolidar_integridade^(^);
    echo DROP PROCEDURE pf33_preparar_integridade;
    echo DROP PROCEDURE pf33_consolidar_integridade;
    type "migrations\003c-remover-usuario.sql"
    echo.
    echo SET @u01_banco_descartavel = DATABASE^(^);
    type "tests\usuario.sql"
    echo.
    echo SET @u01_banco_descartavel = NULL;
    type "tests\migracao-depois.sql"
    echo.
    type "tests\protecao-preservacao.sql"
    echo.
    echo SET @u01_banco_descartavel = 'pharmafind_demo';
    type "tests\migracao-depois.sql"
    echo.
    type "tests\protecao-preservacao.sql"
    echo.
    echo SET @u01_banco_descartavel = DATABASE^(^);
    type "tests\migracao-depois.sql"
    echo.
    echo SET @u01_banco_descartavel = NULL;
    type "tests\protecao-limpeza-autorizada.sql"
    echo.
    type "tests\esquema.sql"
    echo.
    type "tests\integridade.sql"
    echo.
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_seed_em_teste^(^)
    echo BEGIN
    type "seeds\demonstracao.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    type "tests\demonstracao.sql"
    echo.
    echo USE %U01_INTEGRIDADE%;
    type "tests\u01-antes-003.sql"
    echo.
    type "tests\assercoes.sql"
    echo.
    findstr /v /l /b /c:"CALL pf33_preparar_integridade();" /c:"DROP PROCEDURE pf33_preparar_integridade;" "migrations\003a-preparar-integridade.sql"
    echo.
    findstr /v /l /b /c:"CALL pf33_consolidar_integridade();" /c:"DROP PROCEDURE pf33_consolidar_integridade;" "migrations\003b-restricoes-integridade.sql"
    echo.
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_seed_anterior_em_teste^(^)
    echo BEGIN
    type "tests\seed-antes-003.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    type "tests\003-antes.sql"
    echo.
    echo DELIMITER $$
    echo CREATE PROCEDURE pf33_preencher_em_teste^(^)
    echo BEGIN
    type "migrations\003-preencher-demonstracao.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    type "tests\003-preenchimento.sql"
    echo.
    type "migrations\003-preencher-demonstracao.sql"
    echo.
    type "tests\003-depois.sql"
    echo.
    type "migrations\003c-remover-usuario.sql"
    echo.
    echo SET @u01_banco_descartavel = DATABASE^(^);
    type "tests\usuario.sql"
    echo.
    echo SET @u01_banco_descartavel = NULL;
    type "tests\integridade.sql"
    echo.
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_seed_em_teste^(^)
    echo BEGIN
    type "seeds\demonstracao.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    echo CALL u01_seed_em_teste^(^);
    echo CALL u01_seed_em_teste^(^);
    echo CALL u01_assert^(^(SELECT COUNT^(*^) = 6 FROM MEDICAMENTO^) AND ^(SELECT COUNT^(*^) = 4 FROM FARMACIA^)
    echo     AND ^(SELECT COUNT^(*^) = 12 FROM MEDICAMENTO_FARMACIA^) AND ^(SELECT COUNT^(*^) = 1 FROM HISTORICO_PRECO^),
    echo     'Seed atual compativel com U01 migrada; sem duplicar ou apagar historico'^);
    echo USE %U01_PROTECAO%;
    type "PharmaFindDB.sql"
    echo.
    type "tests\protecao-fixtures.sql"
    echo.
    echo SET @u01_banco_descartavel = DATABASE^(^);
    echo DELIMITER $$
    echo CREATE PROCEDURE u01_executar_limpeza_isolada^(^)
    echo BEGIN
    echo DECLARE CONTINUE HANDLER FOR 1305 BEGIN END;
    type "tests\migracao-depois.sql"
    echo.
    echo END$$
    echo DELIMITER ;
    echo CALL u01_executar_limpeza_isolada^(^);
    echo SET @u01_banco_descartavel = NULL;
    type "tests\assercoes.sql"
    echo.
    type "tests\protecao-preservacao.sql"
    echo.
    echo CALL u01_assert^(^(SELECT COUNT^(*^) = 0 FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = DATABASE^(^)
    echo     AND ROUTINE_NAME IN ^('u01_consolidar_em_teste','u01_seed_em_teste'^)^), 'Limpeza isolada independe dos executores'^);
    echo DROP DATABASE %U01_PROTECAO%;
    echo DROP DATABASE %U01_INTEGRIDADE%;
    echo DROP DATABASE %U01_MIGRADO%;
    echo DROP DATABASE %U01_NOVO%;
) > "%U01_SQL%"
if errorlevel 1 goto :erro_preparacao
"%U01_MYSQL%" --host=127.0.0.1 --port=%U01_PORT% --user=root %U01_AUTH% --connect-timeout=5 --default-character-set=utf8mb4 --batch --raw --skip-force < "%U01_SQL%"
set "U01_EXIT=%ERRORLEVEL%"
del /q "%U01_SQL%"
if not "%U01_EXIT%"=="0" (
    echo ERRO: suite interrompida; bancos desta rodada preservados para inspecao.
    popd
    exit /b %U01_EXIT%
)
echo SUCESSO: esquema, migracoes 001/002/003, seed, integridade e remocao protegida; quatro bancos exclusivos removidos.
popd
exit /b 0

:erro_existente
type "%U01_EXIST%"
echo ERRO: bancos preexistentes; suite recusada.
:erro_consulta
if exist "%U01_EXIST%" del /q "%U01_EXIST%"
:erro_preparacao
if exist "%U01_SQL%" del /q "%U01_SQL%"
popd
exit /b 2
