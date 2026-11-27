# Backend PharmaFind

Fundação Java 21 com Spring Boot, Spring Web, Spring JDBC (`JdbcTemplate`), Maven e MySQL Connector/J. Nesta etapa há repositórios de leitura; endpoints de negócio permanecem pendentes. Iniciar o processo sem banco não comprova persistência operacional.

## Pré-requisitos e banco

- JDK 21 e Maven 3.9 ou superior.
- MySQL 8.0.16 ou superior, com o esquema oficial e a carga fictícia documentados em [`../database/README.md`](../database/README.md).
- Para testes de integração, use exclusivamente o banco descartável `pharmafind_test`, preparado com `database/PharmaFindDB.sql` e `database/seeds/demonstracao.sql` da base atualizada pelo PR #34 (`APRESENTACAO` obrigatória). Confirme previamente a existência e a origem exclusiva do banco. Não recrie nem altere bancos preexistentes sem autorização.

Execute os comandos Maven a partir de `backend/`.

## Configuração

Defina as variáveis no terminal; nenhum segredo deve ser versionado. PowerShell:

```powershell
$env:DB_URL = "jdbc:mysql://127.0.0.1:3306/pharmafind_test"
$env:DB_USERNAME = "seu_usuario"
$credencial = Get-Credential -UserName $env:DB_USERNAME -Message 'Credenciais do banco descartável'
$env:DB_PASSWORD = $credencial.GetNetworkCredential().Password
$env:DB_TEST_EXCLUSIVE = "true" # Somente após confirmar que o banco é exclusivo e descartável.
```

`DB_URL` aceita propriedades Connector/J; ajuste host/porta à instância autorizada. Mantenha as variáveis somente na sessão/processos de teste, sem gravar segredos nas variáveis permanentes do Windows. As sessões configuram fuso `+00:00` e modo estrito. Os instantes são lidos como `Instant`; datas nulas permanecem `null`. Sem `DB_URL`, a configuração de execução mantém o padrão `pharmafind_demo`; isso não autoriza executar testes nesse banco.

## Compilar, testar e iniciar

Primeiro, em um terminal sem `DB_URL` e sem `DB_TEST_EXCLUSIVE`, execute `mvn clean compile` e `mvn test`. Isso executa os testes independentes; a integração aparece como ignorada. Em seguida, configure as variáveis acima no terminal do banco descartável confirmado e execute:

```powershell
mvn test
mvn package
java -jar target/pharmafind-backend-0.0.1-SNAPSHOT.jar
```

`mvn spring-boot:run` também inicia a aplicação. Encerre o processo com Ctrl+C. Ao terminar os testes, remova as variáveis temporárias do terminal:

```powershell
Remove-Item Env:DB_URL,Env:DB_USERNAME,Env:DB_PASSWORD,Env:DB_TEST_EXCLUSIVE -ErrorAction SilentlyContinue
$credencial = $null
```

`ConexaoMySqlIntegrationTest` exige `DB_URL` e `DB_TEST_EXCLUSIVE=true` para toda a classe e espera a seed oficial. A URL deve selecionar `pharmafind_test`; cada teste confirma também `SELECT DATABASE()` antes das operações. Confira `target/surefire-reports/TEST-com.pharmafind.repository.ConexaoMySqlIntegrationTest.xml`: os dez testes devem ter `skipped="0"`, `failures="0"` e `errors="0"`. Sem habilitação explícita, os dez são ignorados; os demais testes não dependem de servidor MySQL.

CT17 altera temporariamente a oferta 3001 para R$ 9,49/indisponível, confere a nova leitura e a data automática, reverte a transação e consulta novamente fora dela para comparar preço, disponibilidade, data e relacionamentos originais. Outro teste cobre data e delivery nulos, também com rollback verificado. Não há atualização permanente nem alteração de esquema nos testes Java.

## Verificar conexão e sessão

`ConexaoRepository.conexaoAtiva()` executa `SELECT 1`. Falhas de infraestrutura propagam as exceções controladas do Spring JDBC; não são convertidas em resultado vazio. O teste de integração consulta ainda `@@SESSION.time_zone` e `@@SESSION.sql_mode`, e valida a recuperação dos medicamentos, farmácias, ofertas, nulos e preços da seed.

`ConexaoIndisponivelTest` usa o Connector/J real contra um socket de loopback sem protocolo MySQL, com `connectTimeout=1000` e `socketTimeout=1000`. Confere `CannotGetJdbcConnectionException` e causa SQLState de conexão nos quatro repositórios, sem interromper serviços. O mapeamento dessas exceções para respostas HTTP pertence às próximas unidades.

Validação local de 26/11/2026: Temurin 21.0.13+9 LTS, Maven 3.10.2, Spring Boot 3.5.16, Spring JDBC 6.2.19 e Connector/J 9.7.0 (versões conferidas no JAR), MySQL Server 8.0.45 em instância temporária isolada. Compilação, 19 testes com integração habilitada, empacotamento e inicialização passaram. CT17 e hashes antes/depois confirmaram a reversão das escritas. Evidências, falhas de preparação e limites em [`tests/RESULTADOS.md`](tests/RESULTADOS.md). A reprodução por outro integrante ainda depende de execução independente.
