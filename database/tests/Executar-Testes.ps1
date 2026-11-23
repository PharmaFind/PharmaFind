[CmdletBinding()]
param(
    [string]$MySqlPath = '',
    [ValidatePattern('^[A-Za-z0-9_.-]+$')]
    [string]$LoginPath,
    [string]$HostName = '127.0.0.1',
    [ValidateRange(1, 65535)]
    [int]$Port = 3306,
    [string]$User = 'root',
    [ValidatePattern('^[0-9a-f_]{1,24}$')]
    [string]$TestId = ''
)

$ErrorActionPreference = 'Stop'
if (-not $MySqlPath) {
    $client = Get-Command mysql.exe -ErrorAction SilentlyContinue
    if ($client) {
        $MySqlPath = $client.Source
    } else {
        throw 'Informe -MySqlPath com o caminho do mysql.exe instalado.'
    }
}
if (-not (Test-Path -LiteralPath $MySqlPath -PathType Leaf)) {
    throw 'mysql.exe nao encontrado no caminho informado.'
}

# Nomes gerados pelo runner; nao aceita um banco existente como argumento.
$suffix = $TestId
if (-not $suffix) { $suffix = [guid]::NewGuid().ToString('N').Substring(0, 12) }
$newDatabase = "pharmafind_u01_test_novo_$suffix"
$migratedDatabase = "pharmafind_u01_test_migrado_$suffix"
$guardDatabase = "pharmafind_u01_test_protecao_$suffix"
foreach ($databaseName in @($newDatabase, $migratedDatabase, $guardDatabase)) {
    if ($databaseName -notmatch '^pharmafind_u01_test_(novo|migrado|protecao)_[0-9a-f_]{1,24}$') {
        throw 'Nome do banco de teste fora do escopo permitido.'
    }
}

$databaseDirectory = Split-Path -Parent $PSScriptRoot
function Read-Sql([string]$RelativePath) {
    Get-Content -LiteralPath (Join-Path $databaseDirectory $RelativePath) -Raw -Encoding UTF8
}

# Executa o arquivo real de consolidacao tambem nos cenarios que devem falhar.
# A procedure existe apenas no banco de teste; nao faz parte da migracao publicada.
$consolidationSql = Read-Sql 'migrations/002-consolidar-ofertas.sql'
$testConsolidation = @'
DELIMITER $$
CREATE PROCEDURE u01_consolidar_em_teste()
BEGIN
'@ + "`n" + $consolidationSql + @'

END$$
DELIMITER ;
'@

$seedSql = Read-Sql 'seeds/demonstracao.sql'
$testSeed = @'
DELIMITER $$
CREATE PROCEDURE u01_seed_em_teste()
BEGIN
'@ + "`n" + $seedSql + @'

END$$
DELIMITER ;
'@
$cepMap = Read-Sql 'seeds/ceps-teste.json'
$cepMap | ConvertFrom-Json | Out-Null
$cepMapSql = "SET @u01_ceps_json = '" + $cepMap.Replace('\', '\\').Replace("'", "''") + "';"
$cleanupSql = Read-Sql 'tests/migracao-depois.sql'
$isolatedCleanup = @'
DELIMITER $$
CREATE PROCEDURE u01_executar_limpeza_isolada()
BEGIN
    -- Simula SOURCE que continua mesmo sem os auxiliares de assercao instalados.
    DECLARE CONTINUE HANDLER FOR 1305 BEGIN END;
'@ + "`n" + $cleanupSql + @'

END$$
DELIMITER ;
'@
$preflightQuery = "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME IN ('$newDatabase', '$migratedDatabase', '$guardDatabase');"

$sql = @(
    'SET NAMES utf8mb4;'
    'SELECT VERSION() AS versao_servidor;'
    "SET SESSION time_zone = '+00:00';"
    "SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES');"
    "CREATE DATABASE $newDatabase CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    "CREATE DATABASE $migratedDatabase CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    "CREATE DATABASE $guardDatabase CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    "USE $newDatabase;"
    'SET @u01_banco_descartavel = NULL;'
    (Read-Sql 'PharmaFindDB.sql')
    (Read-Sql 'tests/assercoes.sql')
    (Read-Sql 'tests/esquema.sql')
    $cepMapSql
    $testSeed
    (Read-Sql 'tests/demonstracao.sql')
    "USE $migratedDatabase;"
    (Read-Sql 'tests/legado.sql')
    (Read-Sql 'tests/assercoes.sql')
    (Read-Sql 'tests/migracao-antes.sql')
    (Read-Sql 'migrations/001-preparar-ofertas.sql')
    $testConsolidation
    (Read-Sql 'tests/migracao-preenchimento.sql')
    $consolidationSql
    'SET @u01_banco_descartavel = NULL;'
    $cleanupSql
    (Read-Sql 'tests/protecao-preservacao.sql')
    "SET @u01_banco_descartavel = 'pharmafind_demo';"
    $cleanupSql
    (Read-Sql 'tests/protecao-preservacao.sql')
    'SET @u01_banco_descartavel = DATABASE();'
    $cleanupSql
    'SET @u01_banco_descartavel = NULL;'
    (Read-Sql 'tests/protecao-limpeza-autorizada.sql')
    (Read-Sql 'tests/esquema.sql')
    $testSeed
    (Read-Sql 'tests/demonstracao.sql')
    "USE $guardDatabase;"
    (Read-Sql 'PharmaFindDB.sql')
    (Read-Sql 'tests/protecao-fixtures.sql')
    'SET @u01_banco_descartavel = DATABASE();'
    $isolatedCleanup
    'CALL u01_executar_limpeza_isolada();'
    'SET @u01_banco_descartavel = NULL;'
    (Read-Sql 'tests/assercoes.sql')
    (Read-Sql 'tests/protecao-preservacao.sql')
    "CALL u01_assert((SELECT COUNT(*) = 0 FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME IN ('u01_consolidar_em_teste', 'u01_seed_em_teste')), 'Teste isolado nao depende dos executores de migracao ou seed');"
    "DROP DATABASE $guardDatabase;"
    "DROP DATABASE $migratedDatabase;"
    "DROP DATABASE $newDatabase;"
) -join "`n"

# login-path deve vir antes das demais opcoes. Senhas nunca sao parametros do runner.
$mysqlArguments = @()
if ($LoginPath) {
    $mysqlArguments += "--login-path=$LoginPath"
} else {
    $mysqlArguments += @("--host=$HostName", "--port=$Port", "--user=$User", '--password')
}
$mysqlArguments += @('--connect-timeout=5', '--default-character-set=utf8mb4', '--batch', '--raw', '--skip-force')

Write-Host "Bancos exclusivos de teste: $newDatabase, $migratedDatabase e $guardDatabase"
Write-Host 'Primeira conexao: consulta somente leitura para verificar se esses bancos ja existem.'
Write-Host 'Sucesso remove somente esses bancos. Falha interrompe a execucao e os preserva para inspecao.'
$previousOutputEncoding = $OutputEncoding
try {
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $existingDatabases = @(& $MySqlPath @mysqlArguments --skip-column-names "--execute=$preflightQuery")
    if ($LASTEXITCODE -ne 0) { throw 'Falha na consulta de existencia. Nenhum teste SQL foi iniciado.' }
    if ($existingDatabases.Count -gt 0) {
        throw ('Execucao recusada: bancos ja existentes: ' + ($existingDatabases -join ', '))
    }
    Write-Host 'Ausencia confirmada. Segunda conexao: criacao dos bancos descartaveis e execucao da suite.'
    $sql | & $MySqlPath @mysqlArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Testes falharam (mysql: $LASTEXITCODE). Verifique o erro acima e os bancos de teste informados."
    }
    Write-Host 'SUCESSO: esquema, migracao, massa e protecao da limpeza passaram; tres bancos exclusivos removidos.'
} finally {
    $OutputEncoding = $previousOutputEncoding
}
