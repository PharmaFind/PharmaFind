# Validação técnica U02 / Issue #11 — PR #36

Data: **26/11/2026**, America/Sao_Paulo (rodada final aproximadamente 22:48).
Executada pelo agente no ambiente local, com autorização do solicitante para instância descartável.

## Referência e ambiente efetivamente utilizados

- Pasta: `C:\Codes\vscode\PharmaFind`; branch `feature/11-backend-java-persistencia`.
- HEAD: `71b69a9abdb3b74d8cd246380d5f0d0e72924d86`.
- Develop e MERGE_HEAD: `53c7ae2cf179ed553d99c5fa21bc4cfb63e7d7bb`, merge do PR #34.
  Os testes usaram a árvore local conciliada com as correções desta validação, ainda sem commit naquela rodada.
- Windows 11 amd64; Temurin **21.0.13+9 LTS**; Maven **3.10.2**;
  Git **2.53.0.windows.1**; MySQL Server/cliente **8.0.45**.
- Spring Boot **3.5.16**, Spring JDBC **6.2.19**, Connector/J **9.7.0**,
  HikariCP **6.3.3** e Tomcat **10.1.55**, conferidos no JAR produzido.
- Surefire **3.5.6**. Python **3.13.3** foi usado somente na orquestração temporária,
  sem dependência Python adicionada ao projeto.
- Issue #11, metadados dos PRs #34/#36 e PRs abertos consultados pelo conector GitHub.
  PR #34 integrado; PR #36 aberto. PRs #35 (frontend) e #38 (documentação) também abertos;
  nenhum arquivo de frontend alterado nesta validação.

## Isolamento e preparação

Somente `pharmafind_test`, na instância criada do zero em
`%TEMP%\pharmafind_u02_bxwkewkk\data`, porta **57141**, bind **127.0.0.1**,
mysqlx desabilitado e `lower_case_table_names=1`. `@@datadir`, `@@port` e `@@bind_address`
foram conferidos antes do DDL. Consulta de existência em `information_schema.schemata`
retornou **0** para `pharmafind_test`, antes de `CREATE DATABASE` sem `IF NOT EXISTS`.

O esquema `database/PharmaFindDB.sql` e a seed `database/seeds/demonstracao.sql`
foram enviados integralmente ao cliente MySQL, sem alterações. Criadas quatro tabelas;
seed confirmou 6 medicamentos, 4 farmácias e 12 ofertas. Não foram executadas migrações,
DROP DATABASE ou alterações em bancos preexistentes.

Conta de teste temporária restrita ao loopback, com `SELECT, UPDATE` em `pharmafind_test.*`.
Senha aleatória somente em memória; configuração JDBC somente no ambiente dos processos filhos.
Não foram persistidas variáveis de ambiente do Windows, credenciais, dumps ou datadirs no Git.
Os serviços `MySQL80`, `wampmysqld64` e `wampmariadb64` permaneceram parados.

## Comandos e resultados

Versões: `java -version`, `mvn -version`, `git --version`, `mysql.exe --version`,
`mysqld.exe --version`. Inspeção do artefato: `jar tf target/pharmafind-backend-0.0.1-SNAPSHOT.jar`.

Comandos Maven executados a partir de `backend/`:

| Comando / ambiente | Descobertos | Executados/aprovados | Falhas/erros | Ignorados | Resultado |
|---|---:|---:|---:|---:|---|
| `mvn clean compile` | — | — | — | — | BUILD SUCCESS; 8 fontes Java compiladas |
| `mvn test`, sem DB_URL/DB_TEST_EXCLUSIVE | 19 | 9 | 0 | 10 | BUILD SUCCESS |
| `mvn -B -ntp test`, MySQL isolado habilitado | 19 | 19 | 0 | 0 | BUILD SUCCESS |
| `mvn -B -ntp package`, mesmo MySQL | 19 | 19 | 0 | 0 | BUILD SUCCESS; JAR executável gerado |

As flags `-B -ntp` apenas controlam a saída do Maven. `package` reexecutou os mesmos
19 testes; não são 38 casos distintos. A rodada sem banco precedeu a rodada integrada.

Habilitação: DB_URL apontou para `jdbc:mysql://127.0.0.1:57141/pharmafind_test`, com
`connectTimeout=2000`, `socketTimeout=5000`, `allowPublicKeyRetrieval=true` e `useSSL=false`
somente nesta instância descartável de loopback; DB_TEST_EXCLUSIVE=true.
DB_USERNAME/DB_PASSWORD foram configuradas no ambiente filho, sem valores sensíveis neste registro.

Surefire conferido diretamente nos XMLs e copiado localmente por rodada:

| Classe | Aprovados na integração | Aprovados em package |
|---|---:|---:|
| PharmaFindApplicationTest | 1 | 1 |
| ConexaoRepositoryTest | 2 | 2 |
| MedicamentoRepositoryTest | 4 | 4 |
| OfertaRepositoryTest | 1 | 1 |
| ConexaoIndisponivelTest | 1 | 1 |
| ConexaoMySqlIntegrationTest | **10** | **10** |

`TEST-com.pharmafind.repository.ConexaoMySqlIntegrationTest.xml` confirmou
`tests="10" failures="0" errors="0" skipped="0"` nas duas rodadas habilitadas.

Preparação e execução foram orquestradas pelo script **temporário, não versionado**
`python -u target/validar_u02.py`. Ele chamou `mysqld --no-defaults --initialize-insecure`
no datadir novo; depois iniciou `mysqld --no-defaults --datadir=<novo> --port=57141
--bind-address=127.0.0.1 --mysqlx=OFF --skip-log-bin --default-time-zone=+00:00 --console`.
O cliente recebeu explicitamente host/porta/conta e os arquivos oficiais por stdin.
Os comandos reproduzíveis do backend estão em [../README.md](../README.md);
a criação/carregamento de banco novo está em [../../database/README.md](../../database/README.md).

## Cobertura e falha controlada de conexão — CT14/CT15

- Pesquisa parcial sem distinguir caixa; IDs existentes/inexistentes; separação das dosagens
  e apresentação própria conferidas por ID. Ordenação textual `1 g` antes de `500 mg` testada separadamente.
- Entradas nula/vazia/branca, limite de 100 e recusa de 101 caracteres; `%`, `_`, barra invertida
  e tentativa `' OR 1=1 --` tratados literalmente. Parâmetros vinculados também verificados com Mockito.
- Ofertas por medicamento, ausência de ofertas, todas indisponíveis, relacionamentos, preços
  BigDecimal com escala, ordenação crescente e empate por ID da farmácia. Oferta 3003/7,50
  indisponível permanece na persistência, antes de 3001/8,99 e 3002/10,99 na ordenação por preço.
- CEP/coordenadas/horários ausentes, delivery nulo e data nula preservados; fixtures temporárias revertidas.
- SELECT 1 real, sessão `+00:00`, modo `STRICT_ALL_TABLES` e leitura do instante UTC da seed conferidos.

`ConexaoIndisponivelTest` executou o driver Connector/J real contra socket reservado em
127.0.0.1 **sem protocolo MySQL**, sem parar serviços. `connectTimeout=1000` e
`socketTimeout=1000`, limite total de 10 s. Nos quatro repositórios, ocorreu
`CannotGetJdbcConnectionException`, com causa SQLException e SQLState iniciado por `08`.
Nenhuma chamada retornou lista vazia ou dados artificiais. Duração: **4,370 s** sem banco,
**4,238 s** na integração, **4,200 s** em package. Não é teste com mock nem teste de resposta HTTP.

## CT17 e preservação dos dados

O teste alterou a oferta 3001 para **9,49/indisponível**, consultou os novos valores e
conferiu o instante automático contra o relógio do servidor. A transação foi revertida;
nova consulta fora dela comparou todos os campos das ofertas do medicamento 1001 ao estado inicial.

Consulta independente após `test`/`package`, com sessão UTC:

```text
ID_MEDICAMENTO_FARMACIA  PRECO  DISPONIVEL  DATA_ATUALIZACAO
3001                    8.99   1           2026-11-12 12:00:00
```

O arquivo oficial `database/tests/verificar-inicializacao.sql` foi executado antes/depois
e novamente após iniciar a aplicação. Seus sete booleanos permaneceram **1**;
HISTORICO_PRECO permaneceu vazio. Hashes de todos os campos dos três conjuntos:

| Conjunto | SHA-256 idêntico antes/depois |
|---|---|
| medicamentos | `7361a54427631b98e2f0dbb3e03d4b4b55d5dceeb7eeda5d5af2af24d186b967` |
| farmacias | `916558885307058054789d2071dfc02bc22698422b088182f247389d9c544303` |
| ofertas | `a76abc2f8b23810c79d0f83058c8f438c31ef46bfa11fe44f66229a60cc9cf7a` |

## Inicialização e encerramento

Executado: `java -jar target/pharmafind-backend-0.0.1-SNAPSHOT.jar
--server.address=127.0.0.1 --server.port=49744`, com o ambiente filho do banco descartável.
Log às **22:48:53 -03:00**: `Tomcat started on port 49744` e
`Started PharmaFindApplication in 2.179 seconds`. Conexão TCP na porta HTTP confirmada.
Isso comprova inicialização do JAR; a conectividade MySQL é demonstrada pelos dez testes JDBC.

Aplicação encerrada após a verificação. `mysqladmin --no-defaults --host=127.0.0.1
--port=57141 --user=root --skip-password shutdown`: saída **0**, processo MySQL saída **0**,
porta **57141 fechada**. Datadir temporário preservado para inspeção, fora do repositório;
nenhum banco foi apagado. Os serviços existentes continuam parados.

## Falhas de preparação e limitações

- Primeira compilação e tentativa integrada no sandbox falharam antes dos testes:
  cache Maven inacessível em `C:\.m2\repository`. Reexecuções externas autorizadas usaram
  o cache do usuário e passaram; nenhuma configuração permanente do Maven foi alterada.
- Primeira instância temporária, porta 57410: cliente recusou `--no-login-paths`.
  Após retirar a opção, a configuração `--skip-name-resolve` recusou root/127.0.0.1
  (erro 1130). Essa instância, sem banco de teste criado, foi encerrada pelo PID próprio;
  nenhum serviço compartilhado foi interrompido. Datadir preservado.
- Segunda instância, porta 51793: esquema/seed carregados, mas Maven parou no acesso ao cache,
  sem executar testes. Foi encerrada com `mysqladmin shutdown`, saída 0 e porta fechada.
  Terceira instância, porta 57141: rodada completa descrita acima, com sucesso.
- Mockito/JDK emitiram avisos de carregamento dinâmico de agente e class sharing;
  não causaram falhas no Java 21 utilizado.
- Não executados Linux, outro JDK/MySQL, desempenho, concorrência ou reprodução por segundo integrante.
- Não implementados/testados endpoints, handlers HTTP, services de negócio, motor de preços,
  integração do frontend ou gráfico. A aprovação continua exigindo revisão humana independente.
- Na conclusão da rodada de testes, o merge local permanecia aberto por não haver autorização
  para commit. Até aquele momento, nenhum commit, push, PR novo, aprovação, merge remoto
  ou atualização de Issue/Project havia sido realizado. A revisão para publicação está registrada abaixo.

Correções: conflitos de README/API conciliados; documentos mesclados ajustados ao esquema de
quatro tabelas e à fundação Java real; teste de medicamentos/ofertas validado por ID, com ordenação
separada; import duplicado removido; casos de borda, falha real de conexão e verificação de rollback
adicionados. SQL de produção, esquema/seed e registros históricos do banco foram preservados.

Conferência final: `git ls-files -u` sem entradas; `git diff --check` e
`git diff --cached --check` sem erros. Somente README/API foram adicionados ao índice
para marcar a resolução, além do conteúdo já preparado pelo merge antes desta validação.
`git diff MERGE_HEAD -- database` e `git diff HEAD -- backend/src/main backend/pom.xml`
sem diferenças: contribuições SQL do PR #34 e código de produção do PR #36 preservados.

Arquivos desta validação: README.md, CONTEXTO.md, backend/README.md,
backend/src/test/java/com/pharmafind/repository/{ConexaoMySqlIntegrationTest,MedicamentoRepositoryTest,ConexaoIndisponivelTest}.java,
backend/tests/RESULTADOS.md, docs/API.md, docs/ADR/003-persistencia-demonstrativa.md
e docs/GUIA-ONBOARDING-AGENTES.md. As demais alterações já preparadas no índice pertencem
ao merge da develop, não a novas mudanças no banco por esta validação.

Artefatos locais ignorados pelo Git: `target/surefire-reports/` e
`target/validacao-u02/{sem-mysql,integracao,package}/`, logs e `summary.json`.
Este documento é o registro curado versionável; os artefatos brutos e datadirs não integram a entrega.

**Parecer técnico:** fundação U02 apta à revisão humana. Fechamento da Issue depende também da
reprodução por outro integrante e da revisão independente; até lá, preferir `Refs #11` a `Closes #11`.

## Revisão para publicação autorizada — 26/11/2026

O solicitante autorizou posteriormente dois commits e a atualização do PR #36.
O primeiro commit, `21eec81`, concluiu o merge local com pais `71b69a9` e `53c7ae2`,
preservando as resoluções de README/API. As correções adicionais são entregues em commit separado.

Nesta revisão, os XMLs e logs das três rodadas foram conferidos novamente, sem executar
novos testes Maven: 9 aprovados/10 ignorados sem banco e 19 aprovados/0 ignorados tanto na
integração quanto em package, sempre sem falhas/erros. CT17, hashes, inicialização e encerramento
conferem com `target/validacao-u02/summary.json`. Não houve mudança posterior no código testado.

Esquema e seed são idênticos aos do PR #34 (commit `e300e70` e develop `53c7ae2`),
com blobs Git `53c65f097bca12dab452efacbf63f84694e7538b` e
`0edccc8e8200685e49446fe14fac68ad76866160`, respectivamente. A pasta database inteira
permanece igual à develop integrada; código de produção Java/POM permanecem iguais a `71b69a9`.

Revisados arquivos preparados, correções adicionais e novos arquivos; não foram encontradas
credenciais reais ou dados sensíveis nos arquivos destinados à publicação. A busca por nomes
de artefatos e padrões de chaves/tokens também não encontrou candidatos. Compilação, logs e
scripts temporários permanecem locais em `backend/target/`, ignorados pelo Git e fora dos commits.
O histórico e a autoria dos commits originais foram mantidos. Revisão independente e reprodução
por outro integrante continuam pendentes; não há autorização para aprovar, integrar remotamente
ou encerrar a Issue #11.
