# AGENTS.md — Orientações para agentes de IA no PharmaFind

> Instruções de colaboração para agentes de codificação. **Documento não comprova a instalação/configuração de qualquer agente.** Leia também [CONTRIBUTING.md](CONTRIBUTING.md), [CONTEXTO.md](CONTEXTO.md), [docs/SPEC.md](docs/SPEC.md), [docs/API.md](docs/API.md) e os [ADRs](docs/ADR/).

## Protocolo de início para agentes de programação

- **Antes de qualquer edição**, confirme a pasta e branch local, leia `AGENTS.md`, `README.md`, `CONTEXTO.md`, `CONTRIBUTING.md`, `docs/SPEC.md`, `docs/API.md`, `docs/GUIA-ONBOARDING-AGENTES.md` e ADRs pertinentes. Se faltar um arquivo ou acesso, reporte a limitação; não invente conteúdo.
- **Não escolha tarefas por conta própria.** Se o usuário ainda não informou qual Issue/unidade está trabalhando, **pergunte explicitamente: "Qual tarefa/Issue do PharmaFind você quer fazer agora?"** e aguarde a resposta. Não comece código, instalação ou Git write nessa fase.
- Com a task definida, consulte a Issue real (ou solicite o texto ao usuário se não tiver acesso), seus critérios de aceite, dependências e trabalho simultâneo. **Apresente um plano e peça autorização antes de alterar arquivos**. Atribuição, revisão e merge continuam sob controle humano.
- Distinga o que existe no código do que está apenas descrito na SPEC; valide o estado da branch. Nunca presuma que um recurso foi implementado só porque o MD menciona o recurso.
- Siga o [manual da equipe](docs/GUIA-ONBOARDING-AGENTES.md), especialmente o **prompt-padrão de primeira conversa** da seção 4.

## Fonte de verdade e status

1. Consulte a Issue atribuída, critérios de aceite, SPEC e ADRs **antes** de alterar o código. Respeite regras aprovadas; alterações propostas na API não são endpoints já existentes.
2. Distingua fatos **implementados e verificados**, decisões de tecnologia para implementação, contratos **propostos** e pendências. Não declare dependências, testes, deploy, agentes ou integração existentes sem verificar.
3. Se houver conflito entre documentos e código, registre a divergência; não invente comportamento nem silenciosamente reescreva o escopo. Requisitos novos exigem decisão rastreável.
4. **Entrega final:** 30/11/2026. A etapa documental de 12/11 é histórica, não o prazo final.

## Arquitetura-alvo para esta entrega

- **Frontend:** HTML + CSS + JavaScript existentes, sem migração React/Vite no MVP aprovado em 23/11; aproveitar visual e CSS, corrigir navegação e integrar via `fetch` com a API. Mudança de framework depende de novo ADR/Issue/PR. U06 [#15](https://github.com/PharmaFind/PharmaFind/issues/15); auditoria visual/UX do professor U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20).
- **Backend:** Java 21, Spring Boot (Spring Web), Maven e Spring JDBC; separar Controller, Service, Repository e modelos de resposta. U02 [#11](https://github.com/PharmaFind/PharmaFind/issues/11). O código Java ainda precisa ser implementado.
- **Persistência:** MySQL e dados fictícios de Gama e região, U01 [#10](https://github.com/PharmaFind/PharmaFind/issues/10); preparar migrações/dados de teste reproduzíveis. Não versionar credenciais.
- **Histórico de preços:** U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19), associado a medicamento **e** farmácia; exibir gráfico com Chart.js e dados fictícios persistidos. Não gerar tendências aleatórias, previsões ou valores reais.
- **Testes:** JUnit/Spring Boot Test para backend; testes JavaScript e de interface a selecionar e executar de fato conforme U07 [#16](https://github.com/PharmaFind/PharmaFind/issues/16).
- **Decisão de 23/11/2026:** ADRs 001 e 004 aceitos para implementação pela coordenação; ADR 006 mantém React como alternativa futura, não requisito da entrega. A revisão humana de PR e a execução real continuam pendentes.

**Responsáveis das Issues U02–U07:** em validação pela coordenação; não assumir pessoa/designação sem confirmação.

## Regras de negócio essenciais

- Usuário pesquisa, seleciona o ID **exato** de um medicamento/apresentação e só então consulta as ofertas desse ID.
- Ofertas indisponíveis são visíveis com aviso, mas **nunca** entram em menor preço, média, economia, classificação de disponíveis ou destaque de melhor preço.
- Quando não existir oferta válida, apresentar números não calculáveis como `null`, sem inventar R$ 0,00.
- O histórico associa cada ponto à oferta da combinação medicamento + farmácia; variação só quando houver amostras suficientes e preço inicial válido.
- Localização/CEP são opcionais. GPS exige ação/consentimento; distância é em linha reta e **não** uma rota. Não guardar GPS preciso desnecessariamente.
- Não há venda, recomendação clínica, login, painel de farmácia, dados comerciais reais, scraping nem cálculo ponderado preço/distância no MVP.
- Os campos JSON, rotas e validações constam em `docs/API.md`. Endpoints são contrato proposto até implementação e aprovação; preservar erros/estados vazios especificados.

## Fluxo de trabalho e limites

1. Trabalhe apenas no escopo da Issue e na branch `feature/<numero-real>-<descricao>` criada de `develop`.
2. Não fazer push direto em `main` ou `develop`, não remover regras de proteção nem forçar merge.
3. Antes de alterar arquivos compartilhados, verificar PRs/Issues simultâneos. Evite reescrever páginas de outra frente; coordene U06 e U10 para não duplicar correções visuais.
4. Não criar novos frameworks, endpoints ou tabelas fora do contrato sem justificar e registrar decisão.
5. O escopo não foi congelado, mas **não amplie por conta própria**: registre proposta em Issue e alinhe critérios e impactos com PO/equipe. Evite microsserviços, autenticação, Docker ou CI sem exigência e decisão explícitas. Ambiente reproduzível é tratado em U08 [#17](https://github.com/PharmaFind/PharmaFind/issues/17).
6. Cada PR deve referenciar Issue e requisitos, descrever alterações, comandos/testes **efetivamente executados**, resultados, falhas e limitações. Uma pessoa **diferente do autor** precisa revisar; o agente não substitui o revisor.

## Segurança e integridade

- Nunca commitar senhas, tokens, dados pessoais desnecessários ou arquivos `.env` reais; disponibilize exemplos sem credenciais reais se necessário.
- Valide entradas no servidor, use consultas SQL parametrizadas e não vaze stack traces, SQL ou dados sensíveis em respostas de API.
- Nunca falsifique testes, logs, datas, histórico de preços, aprovações, PRs ou participação de integrantes.
- Se não conseguir executar o projeto ou um teste, informe a limitação com precisão.

## Definição de pronto

Código implementado e revisado, caso de uso comprovado, testes aplicáveis executados, documentação afetada atualizada, critérios de aceite atendidos e Issue/Project atualizados conforme o trabalho **real**. A simples criação de arquivos ou respostas geradas por IA não representa conclusão.

## Persistência complementar — U01/#33

- O MVP não possui autenticação nem cadastro: esquema novo com quatro tabelas, sem USUARIO.
- Bancos anteriores: 003a prepara APRESENTACAO sem inferir valores; preenchimento revisado;
  003b consolida identidade única, CEP/coordenadas e histórico positivo/único por oferta/dia.
- A 003c é separada: nunca apagar usuários existentes. Inspecionar registros/dependências,
  confirmar backup e obter aprovação explícita do alvo antes de DROP em banco não descartável.
- Manter nomes SQL canônicos em maiúsculas e a collation documentada. Alterações de collation,
  histórico intradiário ou preenchimento desconhecido exigem decisão específica.
- Fixtures históricas com USUARIO são apenas testes de migração, não o esquema vigente.
