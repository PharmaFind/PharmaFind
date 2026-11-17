# ADR 003 — Persistência em MySQL e dados de demonstração

- **Status:** **Aceita para MySQL e dados fictícios**; esquema e massa U01 autorizados pelo usuário e implementados nesta branch, sujeitos à revisão humana. Suíte ampliada de esquema/migração/seed/CEPs, limpeza protegida e inicialização/reaplicação passaram no MySQL 8.0.45.
- **Data de registro:** 12/11/2026; **atualização de escopo:** 16/11/2026; **etapa de esquema U01:** 17/11/2026.

## 1. Contexto

O MVP precisa comparar ofertas persistidas. Antes desta etapa U01, `database/PharmaFindDB.sql` criava `FARMACIA`, `MEDICAMENTO`, `MEDICAMENTO_FARMACIA`, `USUARIO` e `HISTORICO_PRECO`, com preço decimal e par medicamento/farmácia único, sem disponibilidade, data de atualização ou dados iniciais.

## 2. Decisão

**[CONFIRMADO]** Usar **MySQL** e **medicamentos, farmácias e preços fictícios** para representar Gama e arredores. A equipe atualizará as ofertas **diretamente no banco durante a etapa acadêmica**, sem painel, autenticação ou preços reais automáticos. Cada oferta é de um medicamento exato em uma farmácia; ofertas indisponíveis devem continuar visíveis, mas não entram em cálculos de preço.

**[DECISÃO U01 AUTORIZADA EM 17/11/2026]** Adicionar `DISPONIVEL BOOLEAN NOT NULL`, sem default de negócio e com `CHECK` de `0/1`; exigir `PRECO > 0` em `DECIMAL(10,2)`. Usar MySQL 8.0.16+, InnoDB e sessões em modo estrito. Preservar FKs e unicidade do par, com bloqueio de exclusão/alteração de IDs referenciados.

Usar `DATA_ATUALIZACAO TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` e sessões em UTC. Novas ofertas recebem a data de inclusão quando omitida; alterações reais na oferta, inclusive preço/disponibilidade, atualizam o instante. Um `UPDATE` sem mudança mantém a data. `NULL` representa data desconhecida; não atribuir a data da migração como atualização histórica.

Em bases existentes, primeiro adicionar campos anuláveis **sem** atualização automática; revisar disponibilidade por oferta e preencher datas somente se conhecidas. Depois consolidar `NOT NULL`, `CHECK`s e automatismo da data, preservando datas desconhecidas. Scripts de execução única, com backup e sem escritas concorrentes; não recriar tabelas. Ver [procedimento e testes](../../database/README.md).

**[MASSA U01 AUTORIZADA EM 17/11/2026]** Versionar `database/seeds/demonstracao.sql`
com 6 apresentações, 4 farmácias fictícias e 12 ofertas, incluindo preços variados,
indisponibilidade, medicamento sem ofertas e todas indisponíveis. IDs e datas de fixture
fixos; carga transacional, repetível sem duplicação ou alteração de registros idênticos.
Conflitos de IDs, conteúdo ou pares impedem a carga; dados externos e histórico são
preservados. Não usar `UPDATE`, `REPLACE` ou `IGNORE` para forçar a seed.

`database/Inicializar-Demonstracao.cmd` cria um banco novo `pharmafind_demo` e aplica
esquema/carga; `--reaplicar` executa só a carga sobre esse banco. A seed não grava usuários
nem histórico. CEPs de teste ficam em JSON versionado para a U05, sem tabela permanente
adicional (ADR 005). [IDs, fontes e comandos](../../database/seeds/README.md).

## 3. Justificativa

O MySQL já foi escolhido pela equipe e existe um esquema inicial reaproveitável. A massa fictícia permite um teste controlado sem depender de farmácias reais nem de integrações externas instáveis.

## 4. Alternativas consideradas

- Usar somente array JavaScript fixo: útil na demonstração já existente, insuficiente para persistência real.
- Consumir APIs/preços comerciais reais: fora do escopo e sujeito a indisponibilidade/mudanças de terceiros.
- Criar painel administrativo de farmácias: ampliaria o esforço com autenticação e não é necessário para validar o MVP.

## 5. Consequências

Criar scripts de dados de teste e migração, conferir integridade referencial e assegurar que o backend consulta MySQL. O histórico de preços com gráfico foi incluído no planejamento em 16/11 (U09, Issue #19). A tabela `HISTORICO_PRECO` **já existe**, mas não há massa fictícia histórica, política de registros ou consultas implementadas. Sua migração/uso deve preservar vínculo com a oferta exata medicamento/farmácia, com datas e valores reproduzíveis. Não expor dados fictícios como ofertas comerciais reais.

## 6. Status da decisão

**Aceita:** MySQL, base fictícia e atualização pela equipe. **Autorizado nesta tarefa:** esquema, migração e massa descritos acima. Suíte ampliada e criação/reaplicação do clone descartável passaram, com sete booleanos em `1` e três hashes preservados; ver [evidência](../../database/tests/RESULTADOS.md). **Pendente:** obter revisão humana, integrar backend e definir a política de histórico na U09 (`DATA_REGISTRO DATE`). A validação ocorreu em bancos descartáveis, sem inicializar um banco integrado à aplicação. As demais propostas da SPEC/API continuam com seu status próprio.
