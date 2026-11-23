# Banco de dados — U01 / Issue #10

Esta etapa implementa **esquema, migração, massa demonstrativa e testes de integridade**.
A carga em `seeds/demonstracao.sql` prepara 6 medicamentos, 4 farmácias fictícias e 12
ofertas do Gama/arredores; `seeds/ceps-teste.json` contém três CEPs com pontos representativos
documentados. As fixtures de `tests/` existem somente para testes em bancos descartáveis;
não são dados comerciais e não validam os fluxos HTTP ou a interface. Nenhuma migração
é aplicada automaticamente. Veja [a massa e suas fontes](seeds/README.md).

**Validação desta etapa:** a suíte ampliada via `Executar-Testes.cmd` passou no MySQL
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
- `HISTORICO_PRECO` mantém a estrutura existente. Atualizar uma oferta **não insere pontos
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

Os scripts se destinam ao esquema legado de `PharmaFindDB.sql`, anterior a esta etapa.
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
procedures. Cria **três bancos novos** `pharmafind_u01_test_novo_*`,
`pharmafind_u01_test_migrado_*` e `pharmafind_u01_test_protecao_*`,
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
se algum existir, os testes não começam. A segunda cria os três bancos sem `IF NOT EXISTS`,
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
