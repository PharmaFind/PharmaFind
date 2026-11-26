# Backend PharmaFind

Backend Java 21 com Spring Boot, Spring Web, Spring JDBC (`JdbcTemplate`) e MySQL Connector/J. A persistência nesta etapa é somente de leitura; ainda não há endpoints de negócio.

## Configurar o MySQL

Defina as variáveis de ambiente no terminal antes de iniciar a aplicação. No PowerShell:

```powershell
$env:DB_URL = "jdbc:mysql://localhost:3306/pharmafind_demo"
$env:DB_USERNAME = "<usuario_mysql>"
$env:DB_PASSWORD = "<senha_mysql>"
mvn spring-boot:run
```

Substitua os marcadores pelos dados locais, sem gravar credenciais em arquivos versionados. `DB_URL` pode apontar para outro banco MySQL compatível. A aplicação também inicia sem conexão disponível; consultas aos repositórios exigem um banco acessível.

## Validar

```powershell
mvn test
```

Os testes unitários não dependem de um banco. `ConexaoMySqlIntegrationTest` roda somente quando `DB_URL` está definido e usa as demais variáveis acima. Nenhum teste cria, altera ou remove dados do banco.

Os repositórios disponíveis são `MedicamentoRepository`, `FarmaciaRepository`, `OfertaRepository` e `ConexaoRepository`. Consultas com entrada externa usam parâmetros JDBC (`?`).
