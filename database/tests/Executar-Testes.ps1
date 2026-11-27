[CmdletBinding()]
param(
    [string]$MySqlPath = '',
    [ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$LoginPath,
    [string]$HostName = '127.0.0.1',
    [ValidateRange(1,65535)][int]$Port = 3306,
    [string]$User = 'root',
    [ValidatePattern('^[0-9a-f_]{1,24}$')][string]$TestId = '',
    [switch]$SkipPassword
)
$ErrorActionPreference = 'Stop'
if ($LoginPath -and $SkipPassword) { throw 'Escolha LoginPath ou SkipPassword.' }
if (-not $MySqlPath) { $MySqlPath = (Get-Command mysql.exe -ErrorAction Stop).Source }
if (-not (Test-Path -LiteralPath $MySqlPath -PathType Leaf)) { throw 'mysql.exe nao encontrado.' }
if (-not $TestId) { $TestId = [guid]::NewGuid().ToString('N').Substring(0,12) }
$databases = @{}
foreach ($kind in @('novo','migrado','protecao','integridade')) {
    $db = "pharmafind_u01_test_${kind}_$TestId"
    if ($db -notmatch '^pharmafind_u01_test_(novo|migrado|protecao|integridade)_[0-9a-f_]{1,24}$') { throw 'Alvo invalido.' }
    $databases[$kind] = $db
}
$databaseDirectory = Split-Path -Parent $PSScriptRoot
function Read-Sql([string]$path) { Get-Content -LiteralPath (Join-Path $databaseDirectory $path) -Raw -Encoding UTF8 }
function Wrap-Sql([string]$path,[string]$name,[string]$handler = '') {
    @('DELIMITER $$', "CREATE PROCEDURE $name()", 'BEGIN', $handler, (Read-Sql $path), 'END$$', 'DELIMITER ;') -join "`n"
}
function Read-Definition([string]$path,[string]$name) {
    (Read-Sql $path).Replace("CALL $name();", '').Replace("DROP PROCEDURE $name;", '')
}
$cepMap = Read-Sql 'seeds/ceps-teste.json'
$cepMap | ConvertFrom-Json | Out-Null
$cepSql = "SET @u01_ceps_json = '" + $cepMap.Replace('\', '\\').Replace("'", "''") + "';"
$sql = @(
    ('SET NAMES utf8mb4;
SELECT VERSION() AS versao_servidor, @@lower_case_table_names AS lower_case_table_names;
SET SESSION time_zone = ''+00:00'';
SET SESSION sql_mode = CONCAT_WS('','', @@SESSION.sql_mode, ''STRICT_ALL_TABLES'');')
    ('CREATE DATABASE ' + $databases['novo'] + ' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
    ('CREATE DATABASE ' + $databases['migrado'] + ' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
    ('CREATE DATABASE ' + $databases['protecao'] + ' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
    ('CREATE DATABASE ' + $databases['integridade'] + ' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
    ('USE ' + $databases['novo'] + ';
SET @u01_banco_descartavel = NULL;')
    (Read-Sql 'PharmaFindDB.sql')
    (Read-Sql 'tests/assercoes.sql')
    (Read-Sql 'tests/esquema.sql')
    (Read-Sql 'tests/integridade.sql')
    $cepSql
    (Wrap-Sql 'seeds/demonstracao.sql' 'u01_seed_em_teste')
    (Read-Sql 'tests/demonstracao.sql')
    ('USE ' + $databases['migrado'] + ';')
    (Read-Sql 'tests/legado.sql')
    (Read-Sql 'tests/assercoes.sql')
    (Read-Sql 'tests/migracao-antes.sql')
    (Read-Sql 'migrations/001-preparar-ofertas.sql')
    (Wrap-Sql 'migrations/002-consolidar-ofertas.sql' 'u01_consolidar_em_teste')
    (Read-Sql 'tests/migracao-preenchimento.sql')
    (Read-Sql 'migrations/002-consolidar-ofertas.sql')
    (Read-Definition 'migrations/003a-preparar-integridade.sql' 'pf33_preparar_integridade')
    (Read-Definition 'migrations/003b-restricoes-integridade.sql' 'pf33_consolidar_integridade')
    ('CALL pf33_preparar_integridade();
UPDATE MEDICAMENTO SET APRESENTACAO = ''Comprimido de teste'' WHERE ID_MEDICAMENTO = 1;
CALL pf33_consolidar_integridade();
DROP PROCEDURE pf33_preparar_integridade;
DROP PROCEDURE pf33_consolidar_integridade;')
    (Read-Sql 'migrations/003c-remover-usuario.sql')
    ('SET @u01_banco_descartavel = DATABASE();')
    (Read-Sql 'tests/usuario.sql')
    ('SET @u01_banco_descartavel = NULL;')
    (Read-Sql 'tests/migracao-depois.sql')
    (Read-Sql 'tests/protecao-preservacao.sql')
    ('SET @u01_banco_descartavel = ''pharmafind_demo'';')
    (Read-Sql 'tests/migracao-depois.sql')
    (Read-Sql 'tests/protecao-preservacao.sql')
    ('SET @u01_banco_descartavel = DATABASE();')
    (Read-Sql 'tests/migracao-depois.sql')
    ('SET @u01_banco_descartavel = NULL;')
    (Read-Sql 'tests/protecao-limpeza-autorizada.sql')
    (Read-Sql 'tests/esquema.sql')
    (Read-Sql 'tests/integridade.sql')
    (Wrap-Sql 'seeds/demonstracao.sql' 'u01_seed_em_teste')
    (Read-Sql 'tests/demonstracao.sql')
    ('USE ' + $databases['integridade'] + ';')
    (Read-Sql 'tests/u01-antes-003.sql')
    (Read-Sql 'tests/assercoes.sql')
    (Read-Definition 'migrations/003a-preparar-integridade.sql' 'pf33_preparar_integridade')
    (Read-Definition 'migrations/003b-restricoes-integridade.sql' 'pf33_consolidar_integridade')
    (Wrap-Sql 'tests/seed-antes-003.sql' 'u01_seed_anterior_em_teste')
    (Read-Sql 'tests/003-antes.sql')
    (Wrap-Sql 'migrations/003-preencher-demonstracao.sql' 'pf33_preencher_em_teste')
    (Read-Sql 'tests/003-preenchimento.sql')
    (Read-Sql 'migrations/003-preencher-demonstracao.sql')
    (Read-Sql 'tests/003-depois.sql')
    (Read-Sql 'migrations/003c-remover-usuario.sql')
    ('SET @u01_banco_descartavel = DATABASE();')
    (Read-Sql 'tests/usuario.sql')
    ('SET @u01_banco_descartavel = NULL;')
    (Read-Sql 'tests/integridade.sql')
    (Wrap-Sql 'seeds/demonstracao.sql' 'u01_seed_em_teste')
    ('CALL u01_seed_em_teste();
CALL u01_seed_em_teste();
CALL u01_assert((SELECT COUNT(*) = 6 FROM MEDICAMENTO) AND (SELECT COUNT(*) = 4 FROM FARMACIA)
    AND (SELECT COUNT(*) = 12 FROM MEDICAMENTO_FARMACIA) AND (SELECT COUNT(*) = 1 FROM HISTORICO_PRECO),
    ''Seed atual compativel com U01 migrada; sem duplicar ou apagar historico'');')
    ('USE ' + $databases['protecao'] + ';')
    (Read-Sql 'PharmaFindDB.sql')
    (Read-Sql 'tests/protecao-fixtures.sql')
    ('SET @u01_banco_descartavel = DATABASE();')
    (Wrap-Sql 'tests/migracao-depois.sql' 'u01_executar_limpeza_isolada' 'DECLARE CONTINUE HANDLER FOR 1305 BEGIN END;')
    ('CALL u01_executar_limpeza_isolada();
SET @u01_banco_descartavel = NULL;')
    (Read-Sql 'tests/assercoes.sql')
    (Read-Sql 'tests/protecao-preservacao.sql')
    ('CALL u01_assert((SELECT COUNT(*) = 0 FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = DATABASE()
    AND ROUTINE_NAME IN (''u01_consolidar_em_teste'',''u01_seed_em_teste'')), ''Limpeza isolada independe dos executores'');')
    ('DROP DATABASE ' + $databases['protecao'] + ';')
    ('DROP DATABASE ' + $databases['integridade'] + ';')
    ('DROP DATABASE ' + $databases['migrado'] + ';')
    ('DROP DATABASE ' + $databases['novo'] + ';')
) -join "`n"
$mysqlArguments = @()
if ($LoginPath) { $mysqlArguments += "--login-path=$LoginPath" }
else {
    $mysqlArguments += @("--host=$HostName","--port=$Port","--user=$User")
    if ($SkipPassword) { $mysqlArguments += '--skip-password' } else { $mysqlArguments += '--password' }
}
$mysqlArguments += @('--connect-timeout=5','--default-character-set=utf8mb4','--batch','--raw','--skip-force')
$names = ($databases.Values | ForEach-Object { "'$_'" }) -join ','
$query = "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME IN ($names);"
Write-Host ('Bancos descartaveis planejados: ' + (($databases.Values | Sort-Object) -join ', '))
Write-Host 'Primeira conexao somente leitura. Falha preserva bancos; sucesso remove apenas os quatro criados nesta rodada.'
$previousOutputEncoding = $OutputEncoding
try {
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $existing = @(& $MySqlPath @mysqlArguments --skip-column-names "--execute=$query")
    if ($LASTEXITCODE -ne 0) { throw 'Consulta de existencia falhou; suite nao iniciada.' }
    if ($existing.Count -gt 0) { throw ('Bancos preexistentes; suite recusada: ' + ($existing -join ', ')) }
    $sql | & $MySqlPath @mysqlArguments
    if ($LASTEXITCODE -ne 0) { throw "Suite falhou (mysql: $LASTEXITCODE); bancos mantidos para inspecao." }
    Write-Host 'SUCESSO: esquema, migracoes 001/002/003, seed, integridade e remocao protegida; quatro bancos exclusivos removidos.'
} finally { $OutputEncoding = $previousOutputEncoding }
