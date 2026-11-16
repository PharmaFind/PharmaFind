# AGENTS.md — Orientações para agentes de IA no PharmaFind

> Instruções de colaboração para agentes de codificação. **Documento não comprova a instalação/configuração de qualquer agente.** Leia também [CONTRIBUTING.md](CONTRIBUTING.md), [CONTEXTO.md](CONTEXTO.md), [docs/SPEC.md](docs/SPEC.md), [docs/API.md](docs/API.md) e os [ADRs](docs/ADR/).

## Fonte de verdade e status

1. Consulte a Issue atribuída, critérios de aceite, SPEC e ADRs **antes** de alterar o código. Respeite regras aprovadas; alterações propostas na API não são endpoints já existentes.
2. Distingua fatos **implementados e verificados**, decisões de tecnologia para implementação, contratos **propostos** e pendências. Não declare dependências, testes, deploy, agentes ou integração existentes sem verificar.
3. Se houver conflito entre documentos e código, registre a divergência; não invente comportamento nem silenciosamente reescreva o escopo. Requisitos novos exigem decisão rastreável.
4. **Entrega final:** 30/11/2026. A etapa documental de 12/11 é histórica, não o prazo final.

## Arquitetura-alvo para esta entrega

- **Frontend:** React + JavaScript + Vite; aproveitar a identidade visual e CSS atual. **Não usar TypeScript** sem alteração aprovada. U06 [#15](https://github.com/PharmaFind/PharmaFind/issues/15); auditoria visual/UX do professor U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20).
- **Backend:** Java 21, Spring Boot (Spring Web), Maven e Spring JDBC; separar Controller, Service, Repository e modelos de resposta. U02 [#11](https://github.com/PharmaFind/PharmaFind/issues/11). O código Java ainda precisa ser implementado.
- **Persistência:** MySQL e dados fictícios de Gama e região, U01 [#10](https://github.com/PharmaFind/PharmaFind/issues/10); preparar migrações/dados de teste reproduzíveis. Não versionar credenciais.
- **Histórico de preços:** U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19), associado a medicamento **e** farmácia; exibir gráfico com Chart.js e dados fictícios persistidos. Não gerar tendências aleatórias, previsões ou valores reais.
- **Testes:** JUnit para backend e Vitest para frontend são ferramentas planejadas; implementar e registrar testes **reais** conforme U07 [#16](https://github.com/PharmaFind/PharmaFind/issues/16).
- As escolhas de ferramentas estão submetidas à revisão colaborativa nos ADR 004 e 006; não confundir plano com implementação.

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
5. Evite ampliar a solução com microsserviços, autenticação, Docker ou CI sem exigência e decisão explícitas. Ambiente reproduzível é tratado em U08 [#17](https://github.com/PharmaFind/PharmaFind/issues/17).
6. Cada PR deve referenciar Issue e requisitos, descrever alterações, comandos/testes **efetivamente executados**, resultados, falhas e limitações. Uma pessoa **diferente do autor** precisa revisar; o agente não substitui o revisor.

## Segurança e integridade

- Nunca commitar senhas, tokens, dados pessoais desnecessários ou arquivos `.env` reais; disponibilize exemplos sem credenciais reais se necessário.
- Valide entradas no servidor, use consultas SQL parametrizadas e não vaze stack traces, SQL ou dados sensíveis em respostas de API.
- Nunca falsifique testes, logs, datas, histórico de preços, aprovações, PRs ou participação de integrantes.
- Se não conseguir executar o projeto ou um teste, informe a limitação com precisão.

## Definição de pronto

Código implementado e revisado, caso de uso comprovado, testes aplicáveis executados, documentação afetada atualizada, critérios de aceite atendidos e Issue/Project atualizados conforme o trabalho **real**. A simples criação de arquivos ou respostas geradas por IA não representa conclusão.
