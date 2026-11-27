# Backend PharmaFind

Fundação Java 21 com Spring Boot, Spring Web, Spring JDBC (`JdbcTemplate`), Maven e MySQL Connector/J. Nesta etapa há repositórios de leitura; endpoints de negócio permanecem pendentes. Iniciar o processo sem banco não comprova persistência operacional.

## Pré-requisitos e banco

- JDK 21 e Maven 3.9 ou superior.
- MySQL 8.0.16 ou superior, com o esquema oficial e a carga fictícia documentados em [`../database/README.md`](../database/README.md).
- Para testes de integração, use exclusivamente um banco descartável, por exemplo `pharmafind_test`, preparado com `database/PharmaFindDB.sql` e `database/seeds/demonstracao.sql`. Não aponte testes de escrita a bancos compartilhados. Os testes de leitura não alteram registros.

Execute os comandos Maven a partir de `backend/`.

## Configuração

Defina as variáveis no terminal; nenhum segredo deve ser versionado. PowerShell:

```powershell
$env:DB_URL = "jdbc:mysql://localhost:3306/pharmafind_demo"
$env:DB_USERNAME = "seu_usuario"
$env:DB_PASSWORD = "sua_senha"
```

`DB_URL` aceita propriedades Connector/J. As sessões configuram fuso `+00:00` e modo estrito. Os instantes são lidos como `Instant`; datas nulas permanecem `null`.

## Compilar, testar e iniciar

```powershell
mvn clean compile
mvn test
mvn package
mvn spring-boot:run
```

`ConexaoMySqlIntegrationTest` é habilitado quando `DB_URL` existe e espera a seed oficial. Confira `backend/target/surefire-reports/` para distinguir testes executados, ignorados e falhos. Sem `DB_URL`, a integração é ignorada; os testes unitários não dependem de MySQL.

O cenário CT17 de alteração temporária exige também `DB_TEST_EXCLUSIVE=true` e valida que o schema selecionado é exatamente `pharmafind_test`. O teste usa transação revertida; não habilite essa variável para banco compartilhado.

## Verificar conexão e sessão

`ConexaoRepository.conexaoAtiva()` executa `SELECT 1`. Falhas de infraestrutura propagam as exceções controladas do Spring JDBC; não são convertidas em resultado vazio. O teste de integração consulta ainda `@@SESSION.time_zone` e `@@SESSION.sql_mode`, e valida a recuperação dos medicamentos, farmácias, ofertas, nulos e preços da seed.

Versões efetivamente observadas neste ambiente: OpenJDK Temurin 21.0.13.1 e Maven 3.10.2. As versões do Spring Boot, Connector/J e MySQL só devem ser registradas após a execução de compilação e integração; o POM fixa Spring Boot 3.5.16.
