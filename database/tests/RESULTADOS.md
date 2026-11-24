# Correção complementar U01 / Issue #33 — 23/11/2026

**Estado: implementada e validada em MySQL 8.0.45/Windows, pendente de revisão humana.**
Branch `feature/33-integridade-banco`, criada de `develop` `2045c94`.
As evidências abaixo são desta execução pelo agente. O registro anterior de 17/11 foi
preservado integralmente mais abaixo; seus estados de Issue/PR/branch são históricos.

## Ambiente e isolamento

Cliente/servidor: MySQL Community 8.0.45, Win64. Binários em
`C:\Program Files\MySQL\MySQL Server 8.0\bin`.
Os serviços MySQL80/wampmysqld64/wampmariadb64 estavam parados e não foram iniciados.
Foi criada uma instância independente com `mysqld --no-defaults --initialize-insecure`
em diretório temporário novo, ligada somente a `127.0.0.1:33333`, mysqlx desabilitado,
`lower_case_table_names=1`. Ela começou somente com os quatro schemas de sistema.

A conta root sem senha pertence exclusivamente a essa instância efêmera. Nenhuma senha,
perfil pessoal ou credencial foi utilizado/versionado. O aviso genérico do cliente sobre
senha em linha de comando apareceu com `--skip-password`; não foi passada senha.

Todos os bancos citados foram novos, com existência previamente consultada. Nenhum banco
preexistente da equipe, `pharmafind_demo` ou serviço da porta 3306 foi acessado.

## Suíte final — 313 asserções aprovadas

Comando efetivamente executado na raiz do repositório:

```powershell
.\database\tests\Executar-Testes.cmd 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' a33_06 33333 --sem-senha
```

Servidor retornou `8.0.45` e `lower_case_table_names = 1`. Código de saída **0**.
A contagem de linhas iniciadas por `OK:` no log foi **313**.
A saída terminou com:

```text
SUCESSO: esquema, migracoes 001/002/003, seed, integridade e remocao protegida; quatro bancos exclusivos removidos.
```

| Cobertura efetivamente executada | Resultado |
|---|---|
| Esquema novo com quatro tabelas, sem USUARIO | Aprovado. |
| Testes anteriores de ofertas, IDs, FKs, preços, disponibilidade, timestamps/fuso | Aprovados. |
| Histórico negativo/zero, positivo, par oferta/data duplicado, datas/ofertas diferentes, UPDATE e FK | Aprovados. |
| CEP válido, NULL, letras, vazio, 7/9 dígitos e dígitos Unicode | Aprovados. |
| Coordenadas válidas, limites, ausência, parciais, fora dos limites e UPDATE | Aprovados. |
| Apresentação obrigatória/não vazia; identidade; outra dosagem/apresentação; caixa/acento/espaço final | Aprovados. |
| Legado → 001/002 → 003; preservação de data desconhecida e histórico | Aprovado. |
| Snapshot U01 anterior com seis medicamentos → 003a/preenchimento/003b | Aprovado, sem recriar tabelas. |
| Dados incompatíveis, estrutura extra, colisão de constraint/índice, collation divergente e reaplicação | Recusados como esperado. |
| Preenchimento opcional: conteúdo alterado e medicamento externo desconhecido | Preservados, sem preenchimento parcial/inventado. |
| Preservação dos atributos antigos de medicamentos/farmácias/ofertas/histórico | Aprovada com comparação de todas as linhas/colunas antigas. |
| Seed inicial/repetida, conflitos de identidade/ID/preço/par/apresentação, dados externos | Aprovados. |
| Cenários 6 medicamentos/4 farmácias/12 ofertas; 8 disponíveis/4 indisponíveis | Preservados. |
| Dipirona 1001: três ofertas, duas disponíveis; 8,99/9,99/2,00 e 7,50 indisponível | Aprovado na camada SQL. |
| USUARIO sem autorização, alvo errado, sem backup, com registros, FK, view, rotina, trigger ou evento | Remoção recusada; tabela preservada. |
| USUARIO vazia/sem dependências, alvo e backup confirmados | Removida somente nos bancos novos marcados. |
| Reaplicação de remoção e consumo das autorizações | Aprovados; quatro conjuntos do domínio preservados. |
| Limpeza com marcador ausente/incorreto e execução isolada sem asserções | Proteções anteriores preservadas e aprovadas. |

Bancos da suíte final criados/removidos:
`pharmafind_u01_test_novo_a33_06`, `pharmafind_u01_test_migrado_a33_06`,
`pharmafind_u01_test_protecao_a33_06`, `pharmafind_u01_test_integridade_a33_06`.
As rodadas intermediárias bem-sucedidas `a33_04` e `a33_05` também removeram apenas seus quatro alvos.

## Inicializador e reaplicação

Comandos executados:

```powershell
.\database\Inicializar-Demonstracao.cmd 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --criar pharmafind_u01_test_inicializado_a33_11 33333 --sem-senha
.\database\Inicializar-Demonstracao.cmd 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --reaplicar pharmafind_u01_test_inicializado_a33_11 33333 --sem-senha
```

Ambos terminaram com código **0**. `verificar-inicializacao.sql` foi enviado ao cliente
antes/depois por Python `subprocess`, sem credenciais, com sucesso. Os sete booleanos foram
`1` e os três hashes idênticos:

| Conjunto | SHA-256 antes e depois |
|---|---|
| medicamentos (inclui apresentação) | `7361a54427631b98e2f0dbb3e03d4b4b55d5dceeb7eeda5d5af2af24d186b967` |
| farmacias | `916558885307058054789d2071dfc02bc22698422b088182f247389d9c544303` |
| ofertas | `a76abc2f8b23810c79d0f83058c8f438c31ef46bfa11fe44f66229a60cc9cf7a` |

Um alvo alternativo com sufixo fora do padrão foi recusado antes da conexão.
O clone válido permaneceu no diretório temporário para inspeção.

## Scripts publicados e recuperação real por backup

Além dos executores da suíte, foram executados via `SOURCE` os arquivos completos 003a,
preenchimento opcional, 003b e instalação dos auxiliares 003c em bancos novos da instância.
As reaplicações completas 003a/003b foram recusadas com `ERROR 1644 (45000)`, código 1,
mantendo os hashes do domínio. Rotinas deixadas pelas recusas ficaram disponíveis para inspeção.

A orquestração foi Python `subprocess` chamando mysql/mysqldump, sem senhas. Para a rodada
`a33_14`, o comando de backup efetivo correspondeu a:

```bat
mysqldump --no-defaults --host=127.0.0.1 --port=33333 --user=root --skip-password --default-character-set=utf8mb4 --single-transaction --routines --events --triggers --no-tablespaces --set-gtid-purged=OFF pharmafind_u01_test_integridade_a33_14
```

O stdout foi salvo em arquivo binário temporário, **antes de executar 003a**, e depois
enviado por stdin ao mysql selecionando `pharmafind_u01_test_integridade_a33_15`, criado novo.
Todos os processos terminaram com código 0. O backup restaurou a estrutura antiga, sem
APRESENTACAO, USUARIO vazia, seis medicamentos, quatro farmácias, 12 ofertas e um ponto histórico.
A origem migrou para a estrutura nova e removeu USUARIO sob autorização de teste.

Hashes de todas as colunas originais, serializadas por linha/PK, foram iguais antes,
depois da migração/remoção e na restauração:

| Tabela | SHA-256 |
|---|---|
| MEDICAMENTO | `9ce65bd17233f40cab33906f4f0db5828cad7b57dcc0baf9920e1be7c3c6f2c8` |
| FARMACIA | `497d65b2f46d118bafa60726cb1cc614a2bdf320ea188712901d512566437f34` |
| MEDICAMENTO_FARMACIA | `8e8f201f8378460a90b2eae1c0f615328b5cd1caaad5289490897c6b9a7a89af` |
| HISTORICO_PRECO | `52215d5d0041b2bd57f69be6af2aea8931bee059660055c66b8d8d8d5bf43424` |

Uma rodada anterior (`a33_12` → backup → `a33_13`) também restaurou com sucesso um snapshot
após 003b e antes da remoção de USUARIO. Esses quatro bancos ficaram para inspeção na instância
temporária. Dumps/logs/diretório de dados ficam fora do repositório, sem dados de pessoas.

## Falhas observadas durante o desenvolvimento

| Rodada | Falha real | Correção |
|---|---|---|
| a33_01 | 003b recebeu apresentação NULL na fixture legada, erro 1644. | FINDSTR /x não filtrava os rodapés dos arquivos LF; runner passou a usar filtro literal de prefixo. Nenhuma restrição foi afrouxada. |
| a33_02 | Asserção de recusa da remoção falhou. | Teste esperava SQLSTATE 45000 no campo MYSQL_ERRNO; corrigido para erro 1644. A busca textual de dependências foi limitada ao schema ou referências qualificadas ao alvo, evitando falso positivo de outro banco de teste. |
| a33_03 | Fixture de colisão usou CHECK (1), rejeitado com erro 3812 antes do cenário esperado. | Fixture corrigida para expressão booleana CHECK (1 = 1). |

Essas rodadas interromperam e preservaram seus quatro bancos descartáveis; não foram
reutilizadas nem limpas automaticamente. O sucesso posterior usou outros nomes previamente
verificados. Não houve falha funcional observada na suíte final.

## Limitações e estado da revisão

Verificações estáticas desta entrega: `git diff --check` sem erros; parser PS1 sem erros;
13 exemplos JSON da API e um da SPEC válidos; snapshots históricos conferidos contra
`2045c94`, com migrações 001/002 intactas. Inspeção dos arquivos alterados não encontrou
dumps/logs/temporários, caracteres de substituição ou tokens/chaves privadas pelos padrões
consultados. Essa inspeção por padrões não é garantia geral de ausência de segredos.

- MySQL **8.0.45/Windows** foi executado; MySQL 8.0.16 e Linux não foram executados.
- Runner PS1: parser sem erros; execução integral não realizada porque a política local é
  Restricted. Não foi alterada a ExecutionPolicy. O runner CMD executou a suíte completa.
- Não foram testados concorrência/performance, contas com roles, SQL dinâmico externo ou
  bancos existentes de pessoas. Escritas suspensas e inspeção administrativa são requisitos.
- DDL não tem rollback global. A recuperação comprovada foi restauração em cópia nova;
  não houve injeção de falha de disco no meio dos ALTERs.
- API, Java, frontend, geolocalização e gráfico não foram implementados/testados.
- Revisão humana independente, aprovação, merge e encerramento da Issue continuam pendentes.
- As evidências históricas abaixo não devem ser usadas como resultado da correção #33.

---

# Verificações históricas U01 — 17/11/2026

Branch de trabalho: `feature/10-esquema-ofertas`, criada de `develop` no commit
`075473435dbaef49594d1bf526e4964c6b5ed269`. Alterações locais para parte da Issue #10;
este registro não comprova revisão humana, merge ou conclusão integral da U01.

**Estado atual: APTO PARA PR**, com base na suíte ampliada e na criação/reaplicação
do clone `b53f735eca4e`, executadas pelo usuário no MySQL 8.0.45 local. Os sete
booleanos ficaram em `1` antes/depois e os três hashes permaneceram idênticos.
A conclusão e os critérios de aceite estão ao final deste arquivo. As seções
anteriores preservam a sequência real de falhas, bloqueios e validações parciais;
seus vereditos provisórios não representam o estado final. Revisão humana, PR,
merge e atualização da Issue/Project não foram realizados.

| Verificação efetivamente executada | Resultado |
|---|---|
| `git diff --check` | Sem erros de whitespace no diff dos arquivos rastreados. |
| Parser PowerShell (`System.Management.Automation.Language.Parser.ParseFile`) sobre `Executar-Testes.ps1` | Sem erros de sintaxe. Não executa SQL. |
| Cliente `mysql.exe --version` | MySQL Community Server **8.0.45**, Win64. Isso é a versão do cliente, não uma consulta autenticada ao servidor. |
| Serviço local `MySQL80` | Observado em estado `Running`. |
| Tentativa de consulta `SELECT VERSION(), @@port, @@session.sql_mode` via TCP local, usuário `root`, sem senha fornecida | Recusada: `ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)`. Nenhum resultado SQL obtido. |
| Perfil de autenticação MySQL no local padrão do usuário | Arquivo de login-path não encontrado; nenhum segredo consultado ou registrado. |

**Estado na primeira verificação do agente:** testes SQL ainda não executados, sem
criação de bancos ou aplicação das migrações pelo agente. A execução posterior pelo
usuário está registrada abaixo; não confundir a suíte SQL com os CTs fim a fim.

O usuário relatou `PSSecurityException` ao tentar iniciar `Executar-Testes.ps1`:
execução de scripts desabilitada no PowerShell. Esse erro ocorre antes de o runner
iniciar e não representa falha de integridade SQL. Foi adicionada a alternativa nativa
`Executar-Testes.cmd`, que envia a mesma suíte ao cliente MySQL, sem chamar PowerShell
ou alterar a política de execução. Naquele momento a execução autenticada estava pendente.

Verificação da alternativa `.cmd`: executada com um caminho deliberadamente inexistente
para o cliente; recusou o caminho com código `2`, antes de iniciar MySQL. `git diff --check`
também passou após o ajuste. Isso valida somente esse caminho de erro, não a suíte SQL.

## Primeira execução autenticada pelo usuário — falha corrigida

O usuário executou `Executar-Testes.cmd` no PowerShell e forneceu a saída na conversa.
Não houve acesso do agente à senha nem nova conexão autenticada executada pelo agente.

- A suíte de **esquema novo** apresentou `OK` em todas as suas verificações: InnoDB,
  fixtures SQL de CT03/CT05/CT06, IDs/FKs/unicidade, validações de preço/disponibilidade,
  bloqueio de exclusão/alteração de IDs referenciados, FK do histórico e timestamps
  de inclusão/atualização/ausência de mudança/fuso (incluindo a parte SQL de CT17).
- Na migração, passou `Migracao nao presume disponibilidade nem data`.
- A execução parou na rejeição esperada de disponibilidade desconhecida, com diagnóstico
  não tratado pelo auxiliar de teste:

  ```text
  ERROR 1265 (01000) at line 323: Data truncated for column 'DISPONIVEL' at row 1
  ```

- O runner informou a preservação dos bancos de teste
  `pharmafind_u01_test_novo_21511_14020_21538` e
  `pharmafind_u01_test_migrado_21511_14020_21538`. Não foram removidos pelo agente.
- Naquela execução não houve saída de sucesso global nem validação completa da migração;
  a versão do servidor não foi consultada nesse log.

**Correção do teste após essa saída:** o auxiliar passa a tratar especificamente o
código `1265`, além de `SQLEXCEPTION`, e o teste de disponibilidade desconhecida aceita
`1048/1138/1265`. O SQLSTATE `01000` não era abrangido por `SQLEXCEPTION`. Foram adicionadas
asserções de preservação dos dois `NULL` e da coluna anulável após a recusa, para não
aceitar conversão silenciosa como sucesso. As validações da migração não foram afrouxadas.
**A reexecução da suíte corrigida passou**, conforme a evidência seguinte.

Referências técnicas: [diagnóstico 1265](https://dev.mysql.com/doc/mysql-errors/8.0/en/server-error-reference.html#error_warn_data_truncated)
e [classes de handlers MySQL](https://dev.mysql.com/doc/refman/8.0/en/declare-handler.html).

## Segunda execução autenticada pelo usuário — sucesso

O usuário repetiu o comando abaixo no terminal local e forneceu a saída completa na
conversa. Resultado registrado a partir dessa saída, sem atribuir a execução ao agente:

```powershell
.\database\tests\Executar-Testes.cmd 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
```

| Grupo de verificações | Resultado informado na saída |
|---|---|
| Suíte completa do esquema novo | Todas as verificações `OK`. |
| Preparação da migração e recusa de disponibilidade desconhecida | `OK`, incluindo preservação dos `NULL` e da coluna anulável após a recusa. |
| Preenchimento explícito da disponibilidade | `OK`, sem fabricar data antiga. |
| Recusa da consolidação com preço ou disponibilidade inválidos | Ambas `OK`. |
| Migração com ofertas e histórico anteriores de teste | `OK`, preservando ofertas, IDs, preços, disponibilidade, datas conhecidas/desconhecidas e histórico. |
| Suíte completa repetida sobre o esquema migrado | Todas as verificações `OK`. |
| Limpeza dos bancos exclusivos desta rodada | Confirmada pela mensagem final de sucesso do runner. |

Trechos literais da saída fornecida (sem incluir a solicitação de senha):

```text
Bancos exclusivos de teste: pharmafind_u01_test_novo_22030_19081_11125 e pharmafind_u01_test_migrado_22030_19081_11125
OK: Consolidacao recusa disponibilidade desconhecida
OK: Consolidacao recusada preserva os NULL sem conversao
OK: Consolidacao recusada preserva a coluna ainda anulavel
OK: Migracao preserva o historico legado de teste
SUCESSO: esquema novo e migrado passaram; bancos exclusivos removidos.
```

**Etapa de esquema/migração validada pela suíte SQL no ambiente do usuário.** Isso não
valida frontend, API, CTs fim a fim, implantação em banco da aplicação ou a U01 inteira.
O runner remove somente os bancos que cria na própria rodada; os bancos preservados
na primeira tentativa não foram removidos pela segunda. Não houve consulta posterior
do agente para inspecionar esses bancos. A versão do servidor também não aparece na saída.

Ao final daquela rodada, permaneciam pendentes seed, farmácias/coordenadas e CEPs
mapeados, além de revisão humana e publicação/integração autorizadas. A continuação
da implementação está registrada abaixo. A Issue #10 e o Project não foram atualizados.

## Extensão U01 — massa demonstrativa e CEPs (17/11/2026)

Depois da execução anterior, o usuário aprovou a continuação da mesma Issue #10:
6 apresentações, 4 farmácias fictícias, 12 ofertas (8 disponíveis/4 indisponíveis),
três CEPs em JSON com pontos representativos e inicializador local `pharmafind_demo`.
A carga tem IDs/datas fixos, verifica conflitos antes das inserções, não sobrescreve
dados incompatíveis e não grava usuários ou registros históricos.

Os runners `.cmd`/`.ps1` agora executam `tests/demonstracao.sql` após a suíte de esquema
tanto no banco novo quanto no migrado, usando os arquivos reais da seed e do mapa JSON.
Testam carga inicial/repetida, conflitos sem sobrescrita/inserção parcial, cenários de
preços/disponibilidade, coordenadas/CEPs e preservação de dados/histórico externos.
O runner passou a exibir `SELECT VERSION()` para registrar a versão do servidor.

Verificações locais efetivamente executadas nesta extensão:

- Parser PowerShell sobre o runner ampliado: sem erros de sintaxe.
- Leitura do JSON com `ConvertFrom-Json`: três CEPs únicos de oito dígitos, coordenadas
  nos limites válidos e rótulo de ponto representativo; sem caracteres que exijam escape
  adicional na inclusão do arquivo pelo runner CMD.
- `git diff --check`: sem erros no diff rastreado.
- `Inicializar-Demonstracao.cmd` e `Executar-Testes.cmd`, com caminho deliberadamente
  inexistente para o cliente: ambos recusaram o caminho com código `2`, antes de
  iniciar MySQL. Essa verificação não testa o caminho autenticado nem executa SQL.
- Fontes institucionais dos CEPs consultadas; referências e origem de cada ponto em
  `database/seeds/README.md` e `ceps-teste.json`. Dois pontos são fixtures manuais; um
  é arredondado do ponto público da UnB. Não são geocodificação postal certificada.

**A suíte SQL ampliada e o inicializador de `pharmafind_demo` ainda não foram executados
com autenticação.** O sucesso anterior registra somente a versão anterior de esquema/
migração. Não usar aquele log como prova de seed, reexecução ou mapeamento já validados
no MySQL. CT09 depende também do cálculo/integração da U05 e não está aprovado por haver JSON.

## Preparação das correções finais — antes da autorização SQL

Após a auditoria, o usuário solicitou proteção autônoma da limpeza e autorização
explícita antes de qualquer SQL da validação final. Nesta etapa **nenhum comando SQL
foi executado e nenhum banco foi consultado, criado, alterado ou removido**.

Alterações observadas no código:

- Os quatro `DELETE`s de `migracao-depois.sql` passaram a exigir o nome permitido de
  banco migrado descartável, marcador de sessão igual ao banco atual e os IDs/conteúdos
  específicos das fixtures. Não dependem das rotinas de asserção para impedir exclusões.
- Os testes anteriores foram mantidos. Foram preparados casos de marcador ausente ou
  incorreto, limpeza autorizada e arquivo executado sem auxiliares no banco descartável
  de proteção. Esses casos não foram executados no MySQL.
- Os runners aceitam identificador explícito e consultam existência antes da suíte,
  recusando nomes preexistentes. `CREATE DATABASE` continua sem `IF NOT EXISTS`.
- O inicializador admite um clone de teste com prefixo restrito, verifica existência
  e permite validar criação/reaplicação sem utilizar `pharmafind_demo`.
- `verificar-inicializacao.sql` prepara consulta de contagens e hashes para comparação
  após criação/reaplicação; nenhum hash ou resultado SQL foi observado nesta etapa.

Verificações **realmente executadas sem banco**:

| Verificação | Resultado observado |
|---|---|
| Parser PowerShell do runner alterado | Sem erros de sintaxe. |
| Arquivos referenciados por `Read-Sql` | Encontrados. |
| Inspeção textual dos quatro `DELETE`s | Todos possuem as três travas e filtro de fixture. Não prova execução MySQL. |
| Inicializador com argumento `alvo_fora_do_padrao` | Recusado com código `2`, antes de qualquer conexão SQL. |
| Runner com identificador `id-invalido` | Recusado com código `2`, antes de qualquer conexão SQL. |
| `git diff --check` | Sem erros de whitespace no diff rastreado. |

**Pendentes:** autorização da rodada; consulta da existência dos nomes aprovados;
execução autenticada da suíte final; criação e reaplicação no clone de inicialização;
comparação dos hashes e registro dos resultados reais. O sucesso histórico da suíte
anterior permanece válido para aquela versão, não comprova estes novos testes.

Para executar, siga [database/README.md](../README.md#testes-reproduzíveis-no-terminal-windows),
digite a senha somente no terminal local ou utilize um login-path de desenvolvimento.
Registre a saída real, versão do servidor e resultado após a execução. Não coloque
senha no script, em argumentos de processo, neste arquivo ou no chat.

## Validação final autorizada condicionalmente — bloqueada pela autenticação

O usuário autorizou a consulta de existência e, **somente se ela retornar zero bancos
existentes**, a suíte, a criação do clone e sua reaplicação. Instância autorizada:
`127.0.0.1:3306`. Qualquer falha de consulta, banco preexistente ou falha de teste
exige interrupção, sem continuar o fluxo dependente ou tentar correções.

Alvos exatos autorizados:

- `pharmafind_u01_test_novo_ce2d6b3490b0`
- `pharmafind_u01_test_migrado_ce2d6b3490b0`
- `pharmafind_u01_test_protecao_ce2d6b3490b0`
- `pharmafind_u01_test_inicializado_ce2d6b3490b0`

Verificações realmente realizadas nesta retomada, sem conexão ao MySQL:

| Verificação | Resultado observado |
|---|---|
| Pasta e branch | `C:\Codes\vscode\PharmaFind`, `feature/10-esquema-ofertas`. |
| Inspeção dos runners e SQL utilizados | Com o identificador e clone acima, criação/remoção da suíte limitadas aos três primeiros alvos; inicialização/reaplicação limitadas ao quarto. Nenhum desses comandos foi executado. |
| Proteção de `migracao-depois.sql` | Os quatro `DELETE`s exigem prefixo permitido, marcador igual ao banco atual e conteúdo das fixtures. Verificação textual; execução ainda pendente. |
| Cliente MySQL no caminho informado | Executável encontrado. |
| Login-path no local padrão `%APPDATA%\MySQL\.mylogin.cnf` | Arquivo ausente. Nenhum segredo lido ou armazenado. |
| `git diff --check` | Código de saída `0`; aviso de conversão futura de LF para CRLF em `PharmaFindDB.sql`. |

**Bloqueio:** a ferramenta do agente não dispõe da senha nem de entrada privada do
usuário no prompt do cliente. A senha anteriormente digitada pelo usuário no próprio
terminal não está disponível ao agente. Não foi tentada nova autenticação sem senha,
pois a tentativa histórica já havia sido recusada. A consulta autorizada **não foi
iniciada** nesta retomada: não houve erro SQL novo nem resultado de existência.

| Etapa SQL desta rodada | Resultado real |
|---|---|
| Consulta de existência dos quatro alvos | Não executada; quantidade existente desconhecida. Condição de liberação não satisfeita. |
| Suíte atual: esquema, migrações, integridade, massa, CEPs e proteção da limpeza | Não executada. |
| Inicialização do clone novo | Não executada. |
| Booleanos de esquema, medicamentos, farmácias, ofertas, sem ofertas, indisponíveis e histórico | Nenhum valor observado; não atribuir `0` ou `1`. |
| Reaplicação idempotente | Não executada. |
| Hashes de medicamentos, farmácias e ofertas antes/depois | Não obtidos; comparação não realizada. |
| Bancos criados ou removidos pelo agente nesta rodada | Nenhum. |
| Existência/permanência dos quatro alvos | Desconhecida; nenhuma consulta realizada. Bancos preexistentes não foram acessados ou modificados. |

O sucesso histórico da suíte anterior continua registrado acima e não valida a suíte
ampliada atual. **Veredito: NECESSITA CORREÇÕES / validação final pendente**; esta
rodada não identificou nova falha funcional, mas não fornece evidência para declarar
a U01 apta para PR. Não houve commit, push ou Pull Request.

## Consulta de existência executada pelo usuário — condição satisfeita

O usuário executou no próprio PowerShell a consulta somente leitura dos quatro
nomes acima, usando TCP em `127.0.0.1:3306`, e forneceu a saída:

```text
bancos_ja_existentes
0
Codigo de saida: 0
```

Isso comprova ausência dos quatro alvos no instante daquela consulta e satisfaz a
condição de autorização para iniciar a sequência proposta. A consulta não criou,
alterou ou removeu bancos. A senha não foi compartilhada com o agente.

Próximo comando autorizado, a executar pelo usuário no terminal com entrada privada
da senha:

```powershell
.\database\tests\Executar-Testes.cmd 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' ce2d6b3490b0
"Codigo de saida: $LASTEXITCODE"
```

O runner repete a consulta de existência dos três alvos da suíte antes de qualquer
criação; recusa bancos preexistentes e não continua após erro. Em sucesso remove
somente os três bancos que criou. Em falha preserva os bancos criados para inspeção.
O clone `pharmafind_u01_test_inicializado_ce2d6b3490b0` não é utilizado nessa etapa.

**Ainda pendentes:** saída real da suíte atual; criação e reaplicação da demonstração;
booleanos e comparação dos hashes. Nenhum resultado dessas etapas foi recebido ou
declarado como sucesso. A liberação da execução não equivale à aprovação da U01 para PR.

## Suíte final executada pelo usuário — falha de collation nos CEPs

O usuário executou o comando acima e forneceu a saída. O runner confirmou ausência
dos três bancos, iniciou a suíte e consultou a versão do servidor: **MySQL 8.0.45**.
A conexão foi local em `127.0.0.1:3306`; nenhuma senha foi compartilhada com o agente.

| Verificação da rodada `ce2d6b3490b0` | Resultado observado |
|---|---|
| Criação do esquema novo, cinco tabelas InnoDB | `OK`. |
| IDs exatos/apresentações, unicidade do par, FKs e bloqueios referenciais | Todas as asserções correspondentes `OK`. |
| Rejeição de preços inválidos e disponibilidade ausente/nula/fora de 0/1, inclusive UPDATE | Todas as asserções correspondentes `OK`. |
| Timestamp de inclusão, data desconhecida, alteração real, UPDATE sem mudança e fuso | Todas as asserções correspondentes `OK`. |
| Recusa de ID conflitante antes da seed e ausência de inserção parcial | Três asserções `OK`. |
| Carga demonstrativa inicial no esquema novo | `OK`: 6 medicamentos, 4 farmácias, 12 ofertas. |
| Apresentações separadas, preços disponíveis e oferta mais barata indisponível | `OK`. |
| Medicamento sem ofertas; medicamento com três ofertas indisponíveis; uma disponível; empate | Todas as asserções correspondentes `OK`. |
| Disponibilidade e preços da massa | `OK`: 8 ofertas disponíveis, 4 indisponíveis, preços positivos. |
| Datas fixas de demonstração e ausência de histórico criado pela seed | `OK`. |
| Coordenadas | `OK`: três farmácias com coordenadas válidas e uma sem ponto inventado. |
| JSON e mapa de CEPs | `OK`: JSON demonstrativo com três CEPs únicos e coordenadas válidas. |
| Associação dos CEPs das farmácias ao mapa JSON | **Erro 1267**, conforme diagnóstico abaixo. Nenhum resultado booleano obtido nessa asserção. |
| CEP não mapeado, reaplicação da seed e preservação por sentinelas/conflitos posteriores | Não executados: aparecem depois da consulta que falhou. |
| Migrações, repetição no esquema migrado e proteção da limpeza | Não executadas nesta rodada: o runner não chegou a selecionar esses bancos. O sucesso histórico anterior permanece limitado à versão anterior. |
| Inicialização e reaplicação pelo inicializador separado | Não executadas; fluxo dependente interrompido. |
| Booleanos de `verificar-inicializacao.sql` e três hashes antes/depois | Não obtidos; comparação não realizada. |

Diagnóstico literal fornecido pelo usuário:

```text
ERROR 1267 (HY000) at line 416: Illegal mix of collations (utf8mb4_0900_ai_ci,IMPLICIT) and (utf8mb4_unicode_ci,IMPLICIT) for operation '='
ERRO: testes interrompidos. Confira a mensagem do MySQL e os nomes dos bancos acima.
Codigo de saida: 1
```

A inspeção do arquivo identifica a próxima asserção após o último `OK` como o JOIN
`pontos.cep = f.CEP` em `tests/demonstracao.sql`. A coluna textual de `JSON_TABLE`
não declara collation; os bancos do runner usam `utf8mb4_unicode_ci`. O diagnóstico
é compatível com collations implícitas diferentes nessa igualdade. Isso não é
evidência de CEPs ausentes ou de erro na carga inicial da seed, que já havia passado.

Estado dos bancos **inferido do fluxo do runner e da saída, sem consulta posterior**:

- Criados e preservados após a falha:
  `pharmafind_u01_test_novo_ce2d6b3490b0`,
  `pharmafind_u01_test_migrado_ce2d6b3490b0` e
  `pharmafind_u01_test_protecao_ce2d6b3490b0`.
  Os três `CREATE DATABASE` precedem o esquema novo; nenhum `DROP DATABASE` foi atingido.
- O banco novo recebeu esquema e carga inicial; os bancos migrado/proteção não
  chegaram às suas fixtures ou testes.
- `pharmafind_u01_test_inicializado_ce2d6b3490b0` não foi criado por essa execução.
- Nenhum banco foi removido por essa execução; nenhum banco preexistente foi utilizado.

Em atendimento à condição de interrupção do usuário, nenhuma nova execução SQL,
limpeza de banco ou correção de código foi tentada após a falha. Somente este registro
foi atualizado. Não reutilizar os nomes existentes em uma nova rodada; uma nova
execução requer alvos descartáveis novos, consulta de existência e autorização.

**Veredito: NECESSITA CORREÇÕES.** Corrigir a comparação de CEPs sem remover a
asserção nem alterar collations de bancos existentes; depois validar a suíte completa,
o inicializador, a reaplicação e os hashes. Nenhum commit, push ou PR foi realizado.

## Correção 1267 e autorização da rodada `b53f735eca4e`

Foi aplicada em `tests/demonstracao.sql` a collation explícita
`utf8mb4_unicode_ci` em ambos os operandos do JOIN dos CEPs. A mudança limita-se à
expressão de comparação e a um comentário; não altera servidor, banco ou tabela.
A conferência do conteúdo antes/depois preservou as 30 chamadas de asserção/erro
esperado. A revisão dos outros JOINs não encontrou outra comparação entre colunas
textuais de origens com collations distintas: a seed compara textos em binário ou
usa a coluna temporária derivada da própria tabela.

Verificações efetivamente executadas sem conexão ao MySQL:

- Conferência de alteração limitada ao trecho esperado: passou.
- Parser PowerShell do runner: sem erros.
- `git diff --check`: código de saída `0`, com aviso de conversão futura LF/CRLF
  em `PharmaFindDB.sql`.
- Quatro `DELETE`s de `migracao-depois.sql`: guardas de nome, marcador e fixture
  preservadas na inspeção textual; isso não comprova seu funcionamento no MySQL.
- Nomes gerados: formato permitido e comprimento inferior a 64 caracteres.
- Reconferência dos runners: com os argumentos aprovados, criação/limpeza da suíte
  limitadas aos três primeiros nomes abaixo; inicializador com alvo alternativo
  explícito limitado ao quarto, sem removê-lo. Conexões CMD usam `127.0.0.1:3306`.

O usuário autorizou a consulta de existência dos quatro novos alvos e, somente
com exatamente zero bancos encontrados e código de saída `0`, a sequência proposta:

- `pharmafind_u01_test_novo_b53f735eca4e`
- `pharmafind_u01_test_migrado_b53f735eca4e`
- `pharmafind_u01_test_protecao_b53f735eca4e`
- `pharmafind_u01_test_inicializado_b53f735eca4e`

**Estado real no recebimento dessa autorização:** nenhuma conexão SQL foi iniciada
pelo agente e nenhuma saída SQL dessa nova rodada foi recebida. O arquivo de
login-path no local padrão continua ausente; a ferramenta não dispõe de entrada
privada da senha pelo usuário. A execução autenticada permanece no terminal local
do usuário, sem compartilhar a senha com o agente.

| Etapa da nova rodada | Evidência atual |
|---|---|
| Consulta de existência dos quatro alvos | Pendente; ausência ainda não comprovada. |
| Suíte completa e código de saída | Pendentes. |
| Criação/verificação/reaplicação do clone | Pendentes; dependem do sucesso da suíte. |
| Sete booleanos e três hashes antes/depois | Nenhum valor observado; comparação pendente. |
| Bancos criados ou removidos nesta retomada | Nenhum pelo agente; nenhuma execução nova relatada pelo usuário. |
| Bancos da rodada `ce2d6b3490b0` | Considerados existentes; não consultados, reutilizados, alterados ou removidos nesta retomada. |

Qualquer erro ou banco novo já existente interrompe o fluxo, sem correção/repetição
automática. A correção 1267 ainda não foi validada em execução. **Veredito atual:
NECESSITA CORREÇÕES**, por validação final pendente; não há evidência nova de falha
funcional após a mudança. Nenhum commit, push ou Pull Request foi realizado.

### Tentativa de colagem no PowerShell — consulta ainda não comprovada

O usuário forneceu uma saída iniciada por
`"Codigo de saida: $LASTEXITCODE"SELECT COUNT(*) AS bancos_ja_existentes`, sem a
abertura da atribuição/here-string. O PowerShell apresentou `UnexpectedToken` para
`SELECT`, `ReservedKeywordNotAllowed` para `FROM` e `PositionalParameterNotFound`
para `WHERE` (interpretado como `Where-Object`). A linha isolada `'@` foi seguida
por prompts de continuação `>>`, sem saída do cliente MySQL.

Esses são erros de interpretação/colagem no PowerShell, não diagnósticos SQL. Não
houve resultado observado para a contagem dos bancos nem código de saída de uma
consulta MySQL concluída. Um valor anterior de `$LASTEXITCODE` não valida esta
tentativa. A condição de liberação dos testes continua não satisfeita.

Nenhum comando foi repetido automaticamente e nenhum SQL foi executado pelo agente.
A suíte, o inicializador, a reaplicação, os sete booleanos e os hashes continuam
pendentes. Nenhuma criação/remoção nova foi observada; os bancos anteriores seguem
preservados. Veredito mantido: **NECESSITA CORREÇÕES**, com validação final pendente.

### Consulta concluída pelo usuário — quatro alvos novos ausentes

Após a tentativa de colagem acima, o usuário executou no próprio terminal o cliente
MySQL com `--protocol=TCP --host=127.0.0.1 --port=3306`, consultando os quatro nomes
da rodada `b53f735eca4e`. Forneceu o resultado e, em seguida, o código de saída:

```text
bancos_ja_existentes
0
Codigo de saida: 0
```

A ausência dos quatro alvos foi comprovada no instante dessa consulta, satisfazendo
a condição de autorização para iniciar a suíte. Essa consulta foi somente leitura;
não criou nem removeu bancos. A senha permaneceu no prompt local do cliente.

Foi reconferida a correção localizada de collation e o comando da suíte com o
identificador explícito `b53f735eca4e`: usa os três bancos novo/migrado/proteção
dessa rodada, em `127.0.0.1:3306`, com nova verificação de existência antes de criar.
A limpeza de sucesso cita somente esses três nomes. Os bancos `ce2d6b3490b0` não
entram no comando e permanecem preservados.

**Estado atual:** suíte ampliada ainda sem resultado recebido; inicialização,
reaplicação, sete booleanos e comparação dos três hashes continuam pendentes.
Não declarar a correção 1267 validada nem a U01 apta para PR apenas com a consulta.

### Suíte ampliada `b53f735eca4e` — sucesso completo no terminal do usuário

O usuário executou `Executar-Testes.cmd` com o identificador aprovado e forneceu a
saída completa, seguida de `Codigo de saida: 0`. O runner confirmou ausência dos
três alvos antes de criar e consultou o servidor **MySQL 8.0.45**, local em
`127.0.0.1:3306`. Nenhuma senha foi compartilhada ou armazenada pelo agente.

| Verificação efetivamente executada | Resultado observado |
|---|---|
| Esquema novo e cinco tabelas InnoDB | `OK`. |
| Identificadores, dosagens separadas, par único, FKs e bloqueios referenciais | Todas as asserções correspondentes `OK`. |
| Preço positivo/não nulo e disponibilidade explícita em 0/1, inclusive UPDATE | Todas as asserções correspondentes `OK`. |
| Datas automáticas, desconhecidas, atualização real, UPDATE sem mudança e fuso | Todas as asserções correspondentes `OK`. |
| Carga inicial da massa no esquema novo | `OK`: 6 medicamentos, 4 farmácias e 12 ofertas, sendo 8 disponíveis e 4 indisponíveis. |
| Cenários de preço, sem ofertas, todas indisponíveis, uma disponível e empate | Todas as asserções correspondentes `OK`. |
| Coordenadas presentes/ausentes, JSON, CEPs únicos/válidos e CEP não mapeado | Todas as asserções correspondentes `OK`. Validação de dados, sem fluxo de distância/API. |
| JOIN dos CEPs com collation explícita | `OK` no esquema novo e no migrado; erro 1267 não se repetiu nesta rodada. |
| Reexecução da seed | `OK`: sem duplicações, sem alteração de datas fixas e com preservação de dados/histórico externos. |
| Conflitos de ID, preço alterado, par com outro ID e oferta extra | Todos rejeitados; asserções de ausência de inserção parcial e preservação `OK`. |
| Migrações reais 001/002 | `OK`: não presumem disponibilidade/data, recusam NULL/valores inválidos e preservam ofertas, IDs, preços, datas conhecidas/desconhecidas e histórico legado de teste. |
| Limpeza com marcador ausente/incorreto | `OK`: fixtures, preços, disponibilidade e datas preservados. |
| Limpeza com marcador autorizado no banco migrado descartável | `OK`: remoção das fixtures esperadas. |
| Repetição das suítes de esquema e massa no banco migrado | Todas as asserções correspondentes `OK`. |
| Limpeza isolada no banco de proteção, sem auxiliares de asserção | `OK`: fixtures e seus valores preservados. |
| Encerramento da suíte | Mensagem de sucesso global e código de saída `0`. |

Trechos literais da saída fornecida:

```text
versao_servidor
8.0.45
OK: CEPs das tres farmacias constam do mapa local
OK: Reexecucao preserva registros e historico fora da seed
OK: Limpeza autorizada remove somente as fixtures esperadas
OK: Limpeza bloqueada conserva precos, disponibilidade e datas
SUCESSO: esquema, migracao, massa e protecao da limpeza passaram; tres bancos exclusivos removidos.
Codigo de saida: 0
```

**Bancos criados e removidos**, conforme a mensagem final e o fluxo do runner
concluído com sucesso (sem consulta posterior independente):

- `pharmafind_u01_test_novo_b53f735eca4e`
- `pharmafind_u01_test_migrado_b53f735eca4e`
- `pharmafind_u01_test_protecao_b53f735eca4e`

Os bancos da rodada anterior `ce2d6b3490b0` não foram selecionados nem removidos
por esse runner e continuam considerados existentes. Não houve nova inspeção deles.
O clone `pharmafind_u01_test_inicializado_b53f735eca4e` não foi criado pela suíte.

**Próxima etapa já autorizada:** executar o inicializador com `--criar` e esse clone
explícito, obter os sete booleanos/hashes, e somente com sucesso reaplicar a carga
e comparar os três hashes. Nenhum resultado dessa etapa foi recebido ainda.
A correção 1267 e a suíte ampliada estão validadas nesta execução; a validação
separada do inicializador e da reaplicação continua pendente. Veredito provisório:
**NECESSITA CORREÇÕES**, por validação final ainda incompleta, sem nova falha na suíte.
Nenhum commit, push ou Pull Request foi realizado.

### Inicialização do clone — sucesso; saída da verificação ainda não fornecida

O usuário executou `Inicializar-Demonstracao.cmd` com `--criar` e o alvo explícito
`pharmafind_u01_test_inicializado_b53f735eca4e`. O inicializador confirmou o estado
de ausência antes da criação, aplicou esquema/seed e exibiu:

```text
U01: demonstracao carregada ou ja identica (6 medicamentos, 4 farmacias, 12 ofertas).
SUCESSO: pharmafind_u01_test_inicializado_b53f735eca4e possui a massa ficticia U01. Mapa de CEPs em database\seeds\ceps-teste.json.
Codigo de saida: 0
```

Isso registra a execução bem-sucedida do inicializador sobre banco novo. O clone
foi criado e não houve comando de remoção dele. Os três bancos da suíte permanecem
registrados como removidos pelo runner; os bancos da rodada anterior não foram
alterados por esses comandos.

Em seguida, o usuário executou a consulta `SOURCE database/tests/verificar-inicializacao.sql`
no clone, capturando a saída em `$antesU01`. Informou código de saída `0`, mas sua
mensagem termina na expressão `$antesU01`, sem apresentar as linhas de resultados.
Não foi estabelecido se a variável está vazia ou se apenas faltou copiar sua saída.

**Sete booleanos:** nenhum valor recebido. **Três hashes iniciais:** nenhum valor
recebido. Código de saída `0` sozinho não comprova valores iguais a `1` ou conteúdo
dos hashes. A reaplicação e a comparação final continuam pendentes e não devem
avançar antes dessa conferência. Próxima ação: inspecionar somente a variável no
PowerShell, sem nova execução SQL. Nenhuma falha SQL nova foi relatada e nenhuma
repetição/correção automática foi tentada. Veredito provisório: **NECESSITA CORREÇÕES**,
por evidência final ainda incompleta.

### Saída inicial capturada — seis linhas e três hashes recebidos

O usuário inspecionou somente `$antesU01` no mesmo PowerShell e forneceu
`Linhas capturadas: 6`, seguidas dos cabeçalhos, linha de verificação e três hashes.
Isso esclarece a ausência de saída na mensagem anterior; nenhuma consulta precisou
ser repetida para obter esses dados. O banco informado foi
`pharmafind_u01_test_inicializado_b53f735eca4e`, servidor `8.0.45`.

Hashes iniciais efetivamente fornecidos:

| Conjunto | SHA-256 antes da reaplicação |
|---|---|
| medicamentos | `7f46e9e871e17039a7294c31f1ef3eb918fc951d97932ff25aac5e2f96710b7c` |
| farmacias | `916558885307058054789d2071dfc02bc22698422b088182f247389d9c544303` |
| ofertas | `a76abc2f8b23810c79d0f83058c8f438c31ef46bfa11fe44f66229a60cc9cf7a` |

A linha tabular dos booleanos foi compactada na mensagem (há um trecho visual
`11`), impedindo atribuir com segurança cada valor a um campo somente pela cópia.
A próxima etapa foi preparada para interpretar os cabeçalhos/tabulações da variável
original e exigir explicitamente `1` em cada um dos sete campos antes de executar
`--reaplicar`. Se o formato, banco ou qualquer campo não corresponder, deve parar
antes de nova execução SQL. A saída posterior também deverá conter os sete valores
iguais a `1` e os mesmos três hashes. Nenhuma reaplicação ou comparação foi observada
ainda; não registrar igualdade de hashes nem aprovação final antecipadamente.

## Conclusão da validação final — `b53f735eca4e`

O usuário executou o bloco de validação/reaplicação já autorizado e forneceu sua
saída completa. A leitura estruturada da variável original confirmou cada um dos
sete booleanos em `1` antes de chamar o inicializador. O inicializador verificou
existência do clone e reaplicou a seed, com código de saída `0`. A consulta posterior
também terminou com código de saída `0`, confirmou os sete valores e forneceu os
mesmos três hashes. Não houve nova falha nem repetição automática nessa execução.

| Campo observado | Antes | Depois |
|---|---|---|
| `esquema_ok` | `1` | `1` |
| `medicamentos_ok` | `1` | `1` |
| `farmacias_ok` | `1` | `1` |
| `ofertas_ok` | `1` | `1` |
| `sem_ofertas_ok` | `1` | `1` |
| `indisponiveis_ok` | `1` | `1` |
| `historico_intacto_ok` | `1` | `1` |

| Conjunto | SHA-256 observado antes e depois | Comparação |
|---|---|---|
| medicamentos | `7f46e9e871e17039a7294c31f1ef3eb918fc951d97932ff25aac5e2f96710b7c` | Idênticos |
| farmacias | `916558885307058054789d2071dfc02bc22698422b088182f247389d9c544303` | Idênticos |
| ofertas | `a76abc2f8b23810c79d0f83058c8f438c31ef46bfa11fe44f66229a60cc9cf7a` | Idênticos |

Trechos literais da saída fornecida:

```text
Codigo de saida da reaplicacao: 0
Codigo de saida da verificacao: 0
OK: sete booleanos antes/depois iguais a 1; tres hashes identicos.
```

### Resumo das execuções e dos bancos

Todas as execuções SQL desta validação foram feitas pelo usuário no próprio
terminal, com senha somente no prompt do cliente, em `127.0.0.1:3306`. O agente
revisou os arquivos e as saídas, sem obter ou armazenar credenciais.

| Etapa | Resultado real |
|---|---|
| Consulta dos quatro alvos antes de iniciar | `0` bancos existentes; código de saída `0`. |
| Suíte ampliada: esquema novo/migrado, seed, CEPs, preservação e limpeza protegida | Sucesso global; código de saída `0`, servidor MySQL `8.0.45`. |
| Inicializador `--criar` no clone novo | Sucesso; código de saída `0`. |
| Consulta inicial do clone | Código de saída `0`; sete booleanos em `1` e três hashes. |
| Inicializador `--reaplicar` no mesmo clone | Sucesso; código de saída `0`. |
| Consulta final e comparação | Código de saída `0`; sete booleanos em `1` e três hashes idênticos. |

| Banco da rodada autorizada | Estado observado/inferido |
|---|---|
| `pharmafind_u01_test_novo_b53f735eca4e` | Criado e removido pelo runner, conforme mensagem final e código `0`. |
| `pharmafind_u01_test_migrado_b53f735eca4e` | Criado e removido pelo runner, conforme mensagem final e código `0`. |
| `pharmafind_u01_test_protecao_b53f735eca4e` | Criado e removido pelo runner, conforme mensagem final e código `0`. |
| `pharmafind_u01_test_inicializado_b53f735eca4e` | Criado, verificado, reaplicado e mantido para inspeção. |

Não houve consulta independente posterior da ausência dos três bancos removidos.
Os três bancos preservados da falha `ce2d6b3490b0` continuam considerados existentes;
não foram reutilizados, alterados ou excluídos nesta validação. Os bancos históricos
`21511_14020_21538` também não receberam limpeza por parte do agente. Nenhum comando
usou bancos de produção, `pharmafind_demo` ou outros bancos preexistentes como alvo.

### Critérios de aceite da Issue #10

| Critério | Evidência e estado |
|---|---|
| Esquema executável em MySQL de desenvolvimento | Atendido: instalação nova, esquema migrado e inicializador no MySQL 8.0.45. |
| Medicamentos com identificadores únicos | Atendido: duplicidade rejeitada e apresentações separadas por ID. |
| Cada oferta referencia medicamento e farmácia específicos | Atendido: testes de FKs, NULL e bloqueios referenciais passaram. |
| Par medicamento/farmácia não duplicável | Atendido: duplicação rejeitada. |
| Ofertas disponíveis e indisponíveis | Atendido: 8 disponíveis e 4 indisponíveis na seed. |
| Medicamentos sem ofertas e com todas indisponíveis | Atendido: fixtures/asserções passaram; booleanos do clone em `1`. |
| Preços e relacionamentos válidos | Atendido: rejeições de valores inválidos e integridade passaram nos dois esquemas. |
| Scripts e procedimentos documentados | Atendido: documentação de instalação, migração, massa, CEPs e testes versionável na branch. |
| Testes registrados com resultados reais | Atendido: falhas anteriores e sucesso final preservados neste registro, com origem explícita nas saídas do usuário. |

### Limitações e parecer

- A suíte MySQL foi executada pelo runner CMD. O runner PowerShell teve sintaxe
  validada, mas não foi executado integralmente; a política de scripts anteriormente
  relatada não foi alterada.
- A versão de servidor efetivamente observada foi 8.0.45. Não há evidência de
  execução em outras versões/plataformas, nem de desempenho ou concorrência.
- As migrações 001/002 são de execução única. O caminho comprovadamente idempotente
  é a reaplicação da seed; não reaplicar o DDL ou as migrações em banco já consolidado.
- A preservação de dados/histórico foi demonstrada com fixtures e sentinelas em
  bancos descartáveis. Nenhuma migração foi aplicada a dados reais ou bancos antigos.
- CT03/CT05/CT06/CT17 foram validados na camada SQL; CT09/CT13 aqui se limitam aos
  dados de entrada. API, frontend, cálculo de distância e histórico analítico não
  foram implementados ou validados por esta tarefa.
- Revisão humana independente continua obrigatória. A Issue #10 e o Project
  não foram atualizados e não houve commit, push, criação de PR ou merge.

### Conferência final dos arquivos

- Branch confirmada: `feature/10-esquema-ofertas`. Há 6 arquivos rastreados
  modificados e 21 novos, todos relacionados ao esquema, migrações, massa,
  inicialização, testes ou documentação da U01. Nenhum está preparado no índice.
- Arquivos pertinentes à entrega: `README.md`, `database/PharmaFindDB.sql`,
  `database/README.md`, `database/Inicializar-Demonstracao.cmd`, os dois SQLs de
  `database/migrations/`, SQL/JSON/README de `database/seeds/`, os runners/SQLs e
  este registro de `database/tests/`, `docs/SPEC.md`, `docs/API.md` e ADRs 003/005.
- Os documentos citados foram sincronizados com o sucesso observado. Não foram
  alterados contratos HTTP, regras de negócio ou decisões da equipe nessa revisão.
- `git diff --check` passou; a conferência dos novos SQL/CMD/PS1/JSON não encontrou
  whitespace ao final de linhas. O aviso de futura conversão LF/CRLF do esquema
  é informativo, não uma falha do check.
- A busca por nomes de arquivos `.env`, logs, temporários, backups, dumps e chaves,
  e por padrões de tokens/chaves privadas/senhas em argumentos não encontrou
  candidatos no repositório. Isso é uma inspeção por padrões, não garantia geral
  de ausência de segredos. Nenhum conteúdo sensível foi exibido.
- Arquivos temporários de execução, credenciais e dumps devem ficar fora da
  entrega. O registro curado `RESULTADOS.md` pertence à documentação versionável;
  não equivale a versionar saídas brutas ou dados do servidor.
- A Issue #10 foi relida via GitHub, permanece aberta e sem comentários; a consulta
  de PRs abertos não retornou resultados. Nenhuma atribuição, revisão ou aprovação
  humana foi simulada.

**Veredito: APTO PARA PR.** Os problemas de limpeza indevida e conflito de collation
receberam correções e passaram nos testes aplicáveis. Não resta falha funcional
observada que bloqueie a apresentação desta U01 para revisão humana.
