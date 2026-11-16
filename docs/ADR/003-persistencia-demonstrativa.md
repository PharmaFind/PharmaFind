# ADR 003 — Persistência em MySQL e dados de demonstração

- **Status:** **Aceita para a escolha MySQL e dados fictícios**; evolução do esquema **pendente**.
- **Data de registro:** 12/11/2026.

## 1. Contexto

O MVP precisa comparar ofertas persistidas. O `database/PharmaFindDB.sql` atual cria tabelas `FARMACIA`, `MEDICAMENTO`, `MEDICAMENTO_FARMACIA`, `USUARIO` e `HISTORICO_PRECO`, com `PRECO DECIMAL(10,2)` e restrição de unicidade por par medicamento/farmácia. Não há dados inseridos, coluna de disponibilidade nem data de atualização na tabela de ofertas.

## 2. Decisão

**[CONFIRMADO]** Usar **MySQL** e **medicamentos, farmácias e preços fictícios** para representar Gama e arredores. A equipe atualizará as ofertas **diretamente no banco durante a etapa acadêmica**, sem painel, autenticação ou preços reais automáticos. Cada oferta é de um medicamento exato em uma farmácia; ofertas indisponíveis devem continuar visíveis, mas não entram em cálculos de preço.

**[PROPOSTA SEPARADA]** Adicionar `DISPONIVEL` booleano obrigatório e `DATA_ATUALIZACAO` na associação de oferta; impor preço positivo e definir migração sem presumir estado dos registros antigos. Os campos, defaults e fuso precisam de aceite antes do SQL.

## 3. Justificativa

O MySQL já foi escolhido pela equipe e existe um esquema inicial reaproveitável. A massa fictícia permite um teste controlado sem depender de farmácias reais nem de integrações externas instáveis.

## 4. Alternativas consideradas

- Usar somente array JavaScript fixo: útil na demonstração já existente, insuficiente para persistência real.
- Consumir APIs/preços comerciais reais: fora do escopo e sujeito a indisponibilidade/mudanças de terceiros.
- Criar painel administrativo de farmácias: ampliaria o esforço com autenticação e não é necessário para validar o MVP.

## 5. Consequências

Criar scripts de dados de teste e migração, conferir integridade referencial e assegurar que o backend consulta MySQL. A tabela `HISTORICO_PRECO` pode permanecer no esquema legado **sem implementar gráficos/histórico analítico** nesta entrega. Não expor dados fictícios como ofertas comerciais reais.

## 6. Status da decisão

**Aceita:** banco MySQL, base fictícia e atualização pela equipe. **Pendente:** detalhes da migração, campos de disponibilidade/atualização, conjunto de farmácias e medicamentos e aprovação de validações propostas na SPEC.
