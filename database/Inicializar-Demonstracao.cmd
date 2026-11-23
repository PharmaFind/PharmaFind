@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Banco fixo e exclusivo para demonstracao local. Nenhuma senha em argumentos.
set "U01_MYSQL=%~1"
if not defined U01_MYSQL set "U01_MYSQL=%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe"
if not exist "%U01_MYSQL%" (
    echo ERRO: informe o caminho do mysql.exe como primeiro argumento.
    exit /b 2
)
set "U01_MODO=criar"
if "%~2"=="--reaplicar" set "U01_MODO=reaplicar"
if not "%~2"=="" if not "%~2"=="--reaplicar" if not "%~2"=="--criar" (
    echo ERRO: segundo argumento permitido: --criar ou --reaplicar. Nao passe senha.
    exit /b 2
)
if not "%~4"=="" exit /b 2
set "U01_BANCO=pharmafind_demo"
if not "%~3"=="" (
    set "U01_BANCO=%~3"
    rem O alvo alternativo e SOMENTE um clone descartavel; nao recebe banco arbitrario.
    set U01_BANCO | findstr /r /x "U01_BANCO=pharmafind_u01_test_inicializado_[0-9a-f_][0-9a-f_]*" >nul
    if errorlevel 1 (
        echo ERRO: banco alternativo deve ser um clone pharmafind_u01_test_inicializado com identificador valido.
        exit /b 2
    )
)
if not "%U01_BANCO:~64,1%"=="" exit /b 2
if not defined TEMP exit /b 2
if not exist "%~dp0PharmaFindDB.sql" exit /b 2
if not exist "%~dp0seeds\demonstracao.sql" exit /b 2
set "U01_SQL_FILE=%TEMP%\pharmafind_u01_init_%RANDOM%_%RANDOM%_%RANDOM%.sql"
set "U01_EXISTENCE_FILE=%U01_SQL_FILE%_existencia.txt"
if exist "%U01_SQL_FILE%" (
    echo ERRO: arquivo temporario ja existe. Execute novamente.
    exit /b 2
)
if exist "%U01_EXISTENCE_FILE%" exit /b 2
(
    if "%U01_MODO%"=="criar" (
        rem Sem IF NOT EXISTS: falha antes de selecionar um banco ja existente.
        echo CREATE DATABASE %U01_BANCO% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        echo USE %U01_BANCO%;
        type "%~dp0PharmaFindDB.sql"
        echo.
    ) else (
        echo USE %U01_BANCO%;
    )
    type "%~dp0seeds\demonstracao.sql"
    echo.
) > "%U01_SQL_FILE%"
if errorlevel 1 (
    if exist "%U01_SQL_FILE%" del /q "%U01_SQL_FILE%"
    echo ERRO: falha ao preparar SQL. MySQL nao foi iniciado.
    exit /b 2
)
echo Banco alvo: %U01_BANCO%. Modo: %U01_MODO%. Dados ficticios para demonstracao.
echo Primeira conexao: verificar existencia do banco sem alterar registros.
"%U01_MYSQL%" --host=127.0.0.1 --port=3306 --user=root --password --connect-timeout=5 --batch --raw --skip-column-names --skip-force --execute="SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '%U01_BANCO%';" > "%U01_EXISTENCE_FILE%"
set "U01_EXIT=%ERRORLEVEL%"
if not "%U01_EXIT%"=="0" (
    del /q "%U01_SQL_FILE%" "%U01_EXISTENCE_FILE%"
    echo ERRO: consulta de existencia falhou. Inicializacao nao executada.
    exit /b %U01_EXIT%
)
set "U01_EXISTE="
set /p U01_EXISTE=<"%U01_EXISTENCE_FILE%"
del /q "%U01_EXISTENCE_FILE%"
if "%U01_MODO%"=="criar" if not "%U01_EXISTE%"=="0" (
    del /q "%U01_SQL_FILE%"
    echo ERRO: banco ja existe ou ausencia nao comprovada. Criacao recusada sem alterar dados.
    exit /b 2
)
if "%U01_MODO%"=="reaplicar" if not "%U01_EXISTE%"=="1" (
    del /q "%U01_SQL_FILE%"
    echo ERRO: banco existente nao confirmado. Reaplicacao recusada.
    exit /b 2
)
echo Estado do banco confirmado. Segunda conexao: executar o modo solicitado nesse alvo.
"%U01_MYSQL%" --host=127.0.0.1 --port=3306 --user=root --password --connect-timeout=5 --default-character-set=utf8mb4 --batch --raw --skip-force < "%U01_SQL_FILE%"
set "U01_EXIT=%ERRORLEVEL%"
del /q "%U01_SQL_FILE%"
if not "%U01_EXIT%"=="0" (
    echo ERRO: inicializacao interrompida. Base existente ou criada mantida para inspecao.
    exit /b %U01_EXIT%
)
echo SUCESSO: %U01_BANCO% possui a massa ficticia U01. Mapa de CEPs em database\seeds\ceps-teste.json.
exit /b 0
