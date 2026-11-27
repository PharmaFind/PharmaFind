# Banco de dados — U01 / Issue #10

**Estado atual:** correção complementar [#33](https://github.com/PharmaFind/PharmaFind/issues/33),
com quatro tabelas no MVP, apresentação própria e novas restrições. Consulte o procedimento
003 abaixo; as evidências anteriores continuam limitadas à versão então testada.

## Correção complementar U01 / Issue #33 — 23/11/2026

O MVP **não possui autenticação nem cadastro**. Instalações novas têm quatro tabelas:
`MEDICAMENTO`, `FARMACIA`, `MEDICAMENTO_FARMACIA` e `HISTORICO_PRECO`.
`USUARIO` não é criada. Bancos anteriores podem mantê-la até a remoção separada e autorizada.

Restrições adicionais:

| Tabela | Regra |
|---|---|
| HISTORICO_PRECO | `PRECO > 0`; `UNIQUE (ID_MEDICAMENTO_FARMACIA, DATA_REGISTRO)`; FK preservada. |
| FARMACIA | CEP `NULL` ou exatamente oito dígitos ASCII; manter `VARCHAR(8)` e modo estrito para rejeitar entradas longas. |
| FARMACIA | Latitude entre -90/90 e longitude entre -180/180, inclusive; ambas presentes ou ambas `NULL`. |
| MEDICAMENTO | `APRESENTACAO VARCHAR(150) NOT NULL`, sem default, não vazia após `TRIM`; identidade única por nome/dosagem/apresentação. |

O histórico continua `DATE`, com **um ponto por oferta por dia**. Nenhum trigger insere histórico:
a política de atualização de pontos fica com a U09, respeitando esta unicidade. Não mudar para
eventos intradiários sem nova decisão. Alterações de apresentação preservam o ID e suas ofertas;
o preenchimento da migração não altera preços, datas ou descrições.

### Ordem de migração e diagnóstico

Faça backup recuperável, verifique versão/instância e selecione o banco explicitamente.
Suspenda escritas de todas as aplicações e mantenha essa condição até terminar a validação.
Execute fora de outra transação e pare no primeiro erro; não use `--force`.

1. **Legado anterior à U01:** executar 001, revisar disponibilidade/datas por ID, executar 002.
   **U01 consolidada:** começar diretamente no próximo passo; não repetir 001/002.
2. `SOURCE database/migrations/003a-preparar-integridade.sql;`
   Valida estrutura, tipos, PKs/FKs, índices, checks de oferta e collations. Lista preços históricos
   inválidos, duplicidades e farmácias incompatíveis; recusa pendências antes de adicionar a coluna.
   Se aprovado, adiciona somente `APRESENTACAO` anulável, sem preencher valores.
3. Revisar cada medicamento e preencher apresentação **explicitamente por ID**, com evidência.
   Para a massa original completa de seis medicamentos, o script **opcional**
   `003-preencher-demonstracao.sql` preenche as apresentações já descritas nas fixtures:
   1001/20 comprimidos, 1002/10 comprimidos, 1003/20 comprimidos, 1004/10 cápsulas,
   1005/12 comprimidos, 1006/28 cápsulas. Verifica os seis registros originais integralmente,
   aceita apenas apresentação ausente/idêntica e recusa divergência sem atualização parcial.
   Não é um extrator genérico de descrições nem deve ser aplicado automaticamente a outra base.
   Outros IDs continuam pendentes até revisão; não preencher com “desconhecida”, vazio ou dados inventados.
4. `SOURCE database/migrations/003b-restricoes-integridade.sql;`
   Repete diagnóstico e verifica apresentações ausentes/vazias e identidades repetidas sob a
   collation aprovada. Só depois aplica as restrições, sem mudar IDs ou excluir registros.
   Após a correção P2 da segunda auditoria, **ambas as etapas validam independentemente**
   que `UQ_MEDICAMENTO_FARMACIA` tem exatamente duas colunas, na ordem
   `(ID_MEDICAMENTO, ID_FARMACIA)`, é único e não usa prefixos. Índices com terceira
   coluna, ordem/nomes divergentes, sem unicidade ou ausentes são recusados antes do ALTER.
   Pares duplicados são listados com quantidade e impedem a etapa, mesmo se o índice
   também estiver incorreto. Não há exclusão de ofertas ou reconstrução automática do índice.
5. Conferir `SHOW CREATE TABLE` nas quatro tabelas, dados/contagens e relacionamentos com o backup.
   A seed atual pode ser reaplicada após 003b; divergências legítimas continuam causando recusa.
6. Avaliar `USUARIO` separadamente, conforme procedimento abaixo. Sua permanência não bloqueia 003a/003b.

### Collation, nomes e compatibilidade Java/Linux

O esquema novo fixa `utf8mb4_unicode_ci`, também usada pelos runners originais.
Ela compara sem distinguir caixa/acentos e tem `PAD SPACE` (espaços finais não distinguem identidades).
Os testes cobrem essas equivalências. 003 exige essa collation em nome/dosagem e usa a mesma
para apresentação; **recusa bases divergentes**, sem converter textos ou collations automaticamente.
Uma divergência exige revisão e decisão específica antes de tentar novamente.

Todos os SQLs de aplicação devem usar os identificadores canônicos em **MAIÚSCULAS**,
incluindo consultas futuras do Repository Java. Não alternar `medicamento` e `MEDICAMENTO`.
Consultar `@@lower_case_table_names`; não mudar a configuração de uma instância inicializada.
Windows pode armazenar nomes em minúsculas; Linux com valor 0 exige a grafia criada pelo DDL.
A execução disponível foi Windows/MySQL 8.0.45; execução Linux e MySQL 8.0.16 ainda não comprovadas.

O backend deverá ler `APRESENTACAO` como campo próprio e mapear ao campo JSON proposto
`apresentacao`, preservando seleção pelo ID exato. Nenhum endpoint ou código Java é implementado aqui.

### Reaplicação, falha parcial e recuperação

003a/003b **não são instaladores idempotentes**: reaplicação é recusada com SQLSTATE 45000
(erro MySQL 1644); não duplicam constraints nem substituem objetos existentes.
As rotinas auxiliares são criadas sem sobrescrever nomes. Em sucesso, 003a/003b removem suas
próprias rotinas. Em erro, podem permanecer para diagnóstico:

- `pf33_preparar_integridade`;
- `pf33_consolidar_integridade`.

Não repetir o arquivo às cegas. Inspecione `SHOW CREATE PROCEDURE` e `SHOW CREATE TABLE`.
Se a estrutura ainda for a esperada e o problema for somente dado incompatível, faça saneamento
revisado e chame a rotina já instalada. Depois de sucesso, remova somente esse auxiliar conhecido.
Se não houver rotina, execute o arquivo correspondente somente após confirmar seu pré-requisito.
Rotina de outra origem/nome em conflito exige decisão; não usar `DROP IF EXISTS` para substituí-la.

Cada `ALTER TABLE` faz commit implícito. O conjunto de três ALTERs de 003b **não é uma transação**:
falha depois do primeiro pode deixar parte consolidada. O diagnóstico recusa esse estado.
Não tentar desfazer com `ROLLBACK`, remover constraints ou reaplicar etapas automaticamente.

Antes da migração, com escritas suspensas, exportar estrutura/dados, rotinas, eventos e triggers
para arquivo protegido **fora do Git**, por exemplo no terminal CMD (ajustar conta e nomes):

```bat
mysqldump --host=127.0.0.1 --user=root --password --single-transaction --routines --events --triggers --no-tablespaces --set-gtid-purged=OFF BANCO_ORIGEM > CAMINHO_SEGURO\backup.sql
```

Verificar o código de saída e restaurar esse dump em **outro banco novo**, explicitamente criado.
Conferir tabelas, registros, FKs, contagens/hashes e rotinas na cópia. Em falha parcial, preservar
a origem e usar a cópia validada para recuperação sob decisão humana; não sobrescrever nem excluir
a origem. O backup deve anteceder qualquer DDL. Os testes de recuperação desta Issue usam somente
alvos novos da instância temporária, sem copiar dados de pessoas.

### Remoção controlada de USUARIO — etapa 003c

`SOURCE database/migrations/003c-remover-usuario.sql;` **apenas instala auxiliares**; não remove tabelas.

Usar conta administrativa com privilégios globais diretos `SELECT`, `SHOW VIEW`, `TRIGGER`
e `EVENT`, além das permissões de execução/DDL necessárias. A inspeção recusa visibilidade
insuficiente; privilégios recebidos apenas via roles não atendem a essa verificação conservadora.
Não conceder privilégios automaticamente. Não utilizar a conta da aplicação para essa manutenção.

1. Executar `CALL pf33_inspecionar_usuario();`. O resultado informa banco, versão,
   **quantidade** de usuários e dependências: FKs de entrada/saída, views, triggers, rotinas e eventos.
   Não lista nomes, emails ou senhas.
2. Auditar também referências externas, SQL dinâmico e objetos cuja definição não possa ser
   inspecionada. A busca textual de rotinas/eventos é conservadora e não substitui essa revisão.
3. Havendo usuários, **preservar a tabela**. Informar quantidade, risco de perda de cadastros,
   retenção de dados e opções: manter isolada do MVP ou planejar exportação/arquivamento com decisão
   específica. O auxiliar nunca apaga tabela com registros, mesmo com variáveis preenchidas.
4. Havendo dependências, preservar e decidir como tratá-las; não apagar dependências em cascata.
5. Com tabela vazia, sem dependências e backup restaurável confirmado, apresentar os resultados
   e obter **aprovação explícita do banco exato** antes do DROP em qualquer alvo não descartável.
   Somente então, na mesma sessão de manutenção:
   ```sql
   SET @pf33_autorizar_remocao_usuario = 'NOME_EXATO_APROVADO';
   SET @pf33_backup_usuario_confirmado = 'NOME_EXATO_APROVADO';
   CALL pf33_remover_usuario();
   ```
   As variáveis devem coincidir com `DATABASE()`; são consumidas antes do DDL.
   O auxiliar revalida contagem e dependências antes do DROP. Reaplicação recusa ausência da tabela.
6. Validar os quatro conjuntos preservados e remover apenas os dois auxiliares conhecidos.
   Nenhuma remoção desta entrega foi executada em banco preexistente da equipe ou `pharmafind_demo`.

### Execução isolada adicional

Os runners agora criam **quatro** bancos: novo, migrado, proteção e
`pharmafind_u01_test_integridade_<identificador>`. O quarto começa no snapshot U01 anterior à #33,
com a seed antiga, e prova a atualização sem recriação/perda dos registros.

O runner CMD aceita `caminho_mysql [identificador] [porta] [--sem-senha]`.
O PS1 aceita `-Port` e `-SkipPassword`. Autenticação sem senha serve somente a uma
instância temporária local previamente preparada; o padrão continua solicitando senha.
O inicializador aceita `caminho_mysql --criar|--reaplicar [clone] [porta] [--sem-senha]`,
mantendo os alvos restritos e consulta prévia de existência.

As fixtures `tests/u01-antes-003.sql`, `tests/seed-antes-003.sql` e `tests/legado.sql`
são snapshots históricos de teste, não instaladores do MVP. Somente elas mantêm a definição
antiga de USUARIO para comprovar migração e proteção contra perda de usuários.

Esta etapa implementa **esquema, migração, massa demonstrativa e testes de integridade**.
A carga em `seeds/demonstracao.sql` prepara 6 medicamentos, 4 farmácias fictícias e 12
ofertas do Gama/arredores; `seeds/ceps-teste.json` contém três CEPs com pontos representativos
documentados. As fixtures de `tests/` existem somente para testes em bancos descartáveis;
não são dados comerciais e não validam os fluxos HTTP ou a interface. Nenhuma migração
é aplicada automaticamente. Veja [a massa e suas fontes](seeds/README.md).

**Validação histórica da U01 anterior à #33:** a suíte ampliada via `Executar-Testes.cmd` passou no MySQL
8.0.45 local, em execução autenticada pelo usuário: instalação nova, migração, massa,
CEPs, preservação e limpeza protegida. O inicializador também passou na criação e
reaplicação de um clone descartável, com sete booleanos em `1` antes/depois e três
hashes idênticos. Evidências, falhas anteriores corrigidas e limitações em
[tests/RESULTADOS.md](tests/RESULTADOS.md). A U01 continua sujeita à revisão humana.

## Requisitos e decisões

- **MySQL 8.0.16 ou posterior**, tabelas InnoDB e modo SQL estrito. As restrições `CHECK`
  são efetivamente aplicadas a partir dessa versão. Não usar `INSERT IGNORE`, `UPDATE IGNORE`
  ou desabilitar `foreign_key_checks` para contornar validações.
- `MEDICAMENTO_FARMACIA.DISPONIVEL`: `BOOLEAN NOT NULL`, sem default de negócio,
  restrito a `0` ou `1`. Cada inclusão informa explicitamente a disponibilidade.
- `PRECO`: `DECIMAL(10,2) NOT NULL CHECK (PRECO > 0)`, inclusive para ofertas indisponíveis.
- O par medicamento/farmácia é único, com FKs obrigatórias. Não misturar dosagens/IDs.
  Excluir ou alterar o ID de uma farmácia/medicamento referenciado é bloqueado; não há cascata.
- `DATA_ATUALIZACAO`: `TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`.
  Novas ofertas recebem a data/hora da inclusão quando o campo é omitido. Mudanças reais
  em outras colunas da oferta, incluindo preço/disponibilidade, atualizam o campo.
  Um `UPDATE` que mantém todos os valores não altera a data. `NULL` representa data
  desconhecida e é preservado até uma atualização real; não significa preço zero.
- Todas as conexões de manutenção/aplicação devem usar `time_zone = '+00:00'` e modo
  estrito. `TIMESTAMP` armazena o instante em UTC e converte conforme o fuso da sessão
  na leitura; não guarda o offset original. A futura API deverá serializar em ISO 8601
  com offset, ou `null`, conforme `docs/API.md`. Não forçar datas antigas nas atualizações
  normais; datas explícitas são usadas apenas quando conhecidas ou em fixtures documentadas.
- `HISTORICO_PRECO` mantém a FK e o campo DATE, com preço positivo e unicidade diária na correção #33. Atualizar uma oferta **não insere pontos
  históricos** nesta etapa; política de gravação e gráfico pertencem à U09.

Os scripts configuram somente a sessão que os executa, sem alterar configuração global.
Reaplique UTC e modo estrito ao abrir outra conexão:

```sql
SET SESSION time_zone = '+00:00';
SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES');
```

## Instalação em banco novo

Crie um banco **novo** de desenvolvimento em uma sessão MySQL autenticada, com nome
escolhido pela equipe. Selecione-o com `USE nome_do_banco;` e execute
`database/PharmaFindDB.sql`. O script não cria bancos nem insere dados; não o execute
novamente sobre tabelas existentes. No cliente `mysql`, a partir da raiz do repositório:

```sql
USE nome_do_banco;
SOURCE database/PharmaFindDB.sql;
```

No PowerShell, abra o cliente instalado (ajuste o caminho real) e digite a senha somente
na solicitação local do MySQL, sem incluí-la no comando:

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --host=127.0.0.1 --user=root --password
```

`root` é uma opção para administração local; a conta da futura aplicação deve ser
definida com a equipe, com privilégios adequados e sem credenciais versionadas.

Para criar um banco de demonstração completo, use `Inicializar-Demonstracao.cmd`, que
cria **somente um banco novo `pharmafind_demo`**, aplica o esquema e a seed. A opção
`--reaplicar` executa apenas a carga idempotente sobre esse banco existente. Não se
sobrescrevem registros incompatíveis. Comandos, cenários, IDs e pontos geográficos em
[seeds/README.md](seeds/README.md#inicializar-e-reproduzir).

## Migração de banco existente

As etapas 001/002 abaixo se destinam ao esquema legado anterior à U01. Após elas, seguir 003a/003b acima e avaliar 003c separadamente.
São de **execução única e ordenada**, não são um instalador idempotente. Faça backup,
confira a versão, `SHOW CREATE TABLE MEDICAMENTO_FARMACIA`, InnoDB e as FKs existentes;
pause escritas concorrentes durante a migração. DDL no MySQL faz commit implícito:
um `ROLLBACK` não desfaz esses `ALTER TABLE`. Pare no primeiro erro e inspecione o estado,
sem usar `--force` no cliente nem reaplicar etapas já concluídas.

1. Selecione explicitamente o banco existente e execute
   `migrations/001-preparar-ofertas.sql`. Os novos campos ficam `NULL` para registros
   antigos, sem disponibilidade presumida nem data da migração atribuída como atualização.
2. Revise **cada oferta pelo ID** e preencha `DISPONIVEL` com `0` ou `1`. Corrija preços
   inválidos com valores demonstrativos acordados. Preencha `DATA_ATUALIZACAO` somente
   quando houver data conhecida; mantenha `NULL` nos demais registros. Nesta fase não
   existe atualização automática da data ao preencher disponibilidade.
3. Confira pendências:

   ```sql
   SELECT ID_MEDICAMENTO_FARMACIA, PRECO, DISPONIVEL, DATA_ATUALIZACAO
   FROM MEDICAMENTO_FARMACIA
   WHERE DISPONIVEL IS NULL OR DISPONIVEL NOT IN (0, 1) OR PRECO <= 0;
   ```

4. Sem pendências, execute `migrations/002-consolidar-ofertas.sql`. Em modo estrito,
   registros inválidos impedem o `ALTER`, em vez de serem convertidos silenciosamente.
   Datas `NULL` existentes continuam `NULL`; novas inclusões passam a receber a data
   automaticamente. Confira `SHOW CREATE TABLE MEDICAMENTO_FARMACIA` e os registros.

As etapas não excluem tabelas nem registros e não alteram o histórico. Não copie
disponibilidade de outra dosagem ou atribua `1` a todas as ofertas sem avaliação.

## Testes reproduzíveis no terminal Windows

O runner exige uma conta local autorizada a criar/remover bancos de teste, tabelas e
procedures. Cria **quatro bancos novos** `pharmafind_u01_test_novo_*`,
`pharmafind_u01_test_migrado_*`, `pharmafind_u01_test_protecao_*` e `pharmafind_u01_test_integridade_*`,
testa instalação, migração e a massa demonstrativa nos dois esquemas e remove somente
esses bancos quando termina com sucesso. Não inicializa `pharmafind_demo`.
Se falhar, interrompe sem `--force` e preserva os bancos que chegou a criar para inspeção;
seus nomes são exibidos. Não recebe o nome de um banco existente como parâmetro.

Na raiz do repositório:

```powershell
.\database\tests\Executar-Testes.ps1 -MySqlPath 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
```

Se o PowerShell bloquear arquivos `.ps1` com `PSSecurityException`, use a alternativa
`.cmd` pelo mesmo terminal, **sem alterar a política de execução**:

```powershell
.\database\tests\Executar-Testes.cmd 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
```

O `.cmd` usa `root` em `127.0.0.1:3306` e envia os mesmos arquivos SQL ao cliente MySQL,
sem chamar PowerShell. A primeira conexão consulta os nomes em `information_schema`;
se algum existir, os testes não começam. A segunda cria os quatro bancos sem `IF NOT EXISTS`,
protegendo também contra criação concorrente. Sucesso os remove; falhas os preservam. O SQL é concatenado
em um arquivo temporário sem credenciais, removido após a chamada ao cliente. Essa é
uma alternativa para o ambiente local, não uma mudança nas permissões do Windows.

Ambos usam **duas conexões**, com duas solicitações de senha quando não há perfil salvo:
consulta de existência e suíte. Se já houver um perfil configurado
no `mysql_config_editor`, use `-LoginPath nome_do_perfil`, sem passar senha. Com esse
parâmetro **no runner `.ps1`**, host/porta/usuário vêm do perfil; caso contrário, nele use
`-HostName`, `-Port` e `-User` conforme a instância de desenvolvimento. A alternativa
`.cmd` recebe o caminho do cliente e, opcionalmente, um identificador de até 24 caracteres
(`0-9`, `a-f`, `_`). No `.ps1`, use `-TestId`. Isso permite informar e autorizar os nomes
exatos **antes de executar qualquer SQL**. Sem identificador, o runner gera um.
Não use um perfil de produção.

### Proteção da limpeza e execução isolada

Cada `DELETE` de `tests/migracao-depois.sql` exige simultaneamente:

1. Banco `pharmafind_u01_test_migrado_<identificador>` no formato permitido.
2. Marcador de sessão `@u01_banco_descartavel` exatamente igual ao banco atual.
3. IDs e conteúdo específicos das fixtures; não há limpeza geral de tabelas.

Os predicados estão no próprio `DELETE`, sem depender de `u01_assert`, de erros anteriores
ou de o cliente interromper o arquivo. Uma execução isolada em outra sessão fica sem
marcador e não seleciona linhas para exclusão. Mudar de banco invalida a autorização.
O runner arma o marcador somente no banco migrado recém-criado e o limpa em seguida.

A suíte mantém os testes anteriores e acrescenta recusa sem marcador, marcador incorreto,
limpeza autorizada e execução do arquivo real em banco descartável fora do prefixo
permitido, inclusive sem asserções instaladas e continuando após erros de rotina ausente.
Esses casos passaram na rodada `b53f735eca4e`, conforme [RESULTADOS.md](tests/RESULTADOS.md).

Cobertura automatizada executada pelo runner CMD:

- FKs, unicidade medicamento/farmácia, IDs obrigatórios e bloqueio de exclusões referenciadas.
- Preço zero, negativo/nulo e disponibilidade ausente, nula ou fora de `0/1`, em modo estrito.
- Data automática em inclusão, alteração de preço/disponibilidade, manutenção em `UPDATE`
  sem mudança, preservação de data desconhecida e equivalência do instante entre fusos.
- Fixtures SQL de CT03/CT05/CT06 e atualização de CT17; isso não comprova os CTs fim a fim.
- Migração com registros anteriores: preservação de IDs/preços, disponibilidade explícita,
  datas conhecidas/desconhecidas e histórico legado de teste; recusa da consolidação com
  disponibilidade desconhecida/inválida ou preço inválido. A mesma suíte de integridade
  é executada também sobre o esquema migrado.
- Carga da seed e reexecução sem duplicar ou alterar dados; recusa de conflitos sem
  sobrescrita/inserção parcial; preservação de registros externos e histórico.
- Cenários da massa, datas fixas e mapa JSON real de CEPs, com formato/unicidade e
  coordenadas válidas. CT09/CT13 são verificados como **dados de entrada**, sem testar
  cálculo de distância ou resposta HTTP, que pertencem à U05.
- Proteção autônoma da limpeza, com preservação dos dados nos contextos bloqueados.

Para validar o inicializador sem usar `pharmafind_demo`, ele aceita somente um clone
`pharmafind_u01_test_inicializado_<identificador>` como terceiro argumento, com modo
explícito `--criar` ou `--reaplicar`. Há consulta de existência em ambos os modos.
`tests/verificar-inicializacao.sql` consulta contagens e hashes antes/depois da reaplicação;
todos os booleanos devem ser `1` e os hashes devem permanecer iguais. Esse arquivo não
altera registros. A existência dos alvos e a autorização da rodada devem ser confirmadas
antes de executar SQL; nenhum resultado novo de banco é presumido.

O relógio fixado em `tests/esquema.sql` afeta somente a sessão de teste e é restaurado
ao fim. Não altera a hora do servidor. Nenhum teste de desempenho, API ou frontend é
executado por esses scripts. Resultados efetivamente obtidos devem ser registrados
após execução, sem confundir a existência dos testes com sua aprovação.

Referências: [SPEC §6.1](../docs/SPEC.md), [ADR 003](../docs/ADR/003-persistencia-demonstrativa.md),
[MySQL: CHECK](https://dev.mysql.com/doc/refman/8.0/en/create-table-check-constraints.html),
[atualização automática](https://dev.mysql.com/doc/refman/8.0/en/timestamp-initialization.html)
[TIMESTAMP e fusos](https://dev.mysql.com/doc/refman/8.0/en/datetime.html)
e [execução de arquivos SQL](https://dev.mysql.com/doc/refman/8.0/en/mysql-batch-commands.html).
