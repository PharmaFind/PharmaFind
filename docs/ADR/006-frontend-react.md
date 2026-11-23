# ADR 006 — React/Vite no frontend: proposta não adotada para o MVP atual

- **Status:** **Não adotada no MVP de 30/11/2026** (opção de evolução futura), conforme decisão da coordenação em **23/11/2026**; revisão humana do PR pendente.
- **Data da proposta original:** 16/11/2026.
- **Decisão relacionada:** [ADR 001](001-arquitetura.md), [ADR 004](004-backend-java.md), U06 [#15](https://github.com/PharmaFind/PharmaFind/issues/15), U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20).

## 1. Contexto

Em 16/11 foi proposta migração do frontend HTML/CSS/JavaScript para **React + JavaScript + Vite**, visando componentes reutilizáveis, estados de interface e gráficos. A proposta foi documentada, mas **não foi implementada** no repositório avaliado em 23/11. O professor recomendou manter HTML, CSS e JavaScript para evitar ampliação desnecessária do esforço de migração pouco antes da entrega.

## 2. Decisão vigente

**Manter HTML, CSS e JavaScript no MVP** e fazer essas páginas consumirem a API Java/Spring Boot. Centralizar recursos comuns e corrigir problemas observados de menu mobile, contraste, semântica, acessibilidade e segurança. Não exigir `npm`, `package.json`, Node ou Vite para rodar o frontend estático.

**Chart.js permanece uma alternativa de biblioteca JavaScript para o gráfico da U09**, sem dependência de React ou `react-chartjs-2`; a biblioteca e o modo de distribuição devem ser definidos e testados na própria U09.

React + Vite não foi proibido para sempre; qualquer adoção posterior requer nova decisão e justificativa registrada em ADR, Issue e PR. Não fazer migração implícita em U06/U10.

## 3. Justificativa

A prioridade é integrar o que já existe com banco e API, evitando uma segunda frente de arquitetura sem benefício demonstrado para os requisitos centrais. A recomendação do professor e a data de entrega favorecem essa escolha.

## 4. Alternativas e consequências

- **React + Vite:** facilitaria componentes reutilizáveis, mas exigiria configuração, migração e novos testes. Mantido apenas como opção para outra etapa.
- **HTML/CSS/JS modular:** escolhido para o MVP; pode usar módulos/funções compartilhadas e carregamento de dados por `fetch`.
- **JSP/Servlets renderizando HTML:** opção acadêmica, mas o backend foi definido como API REST.

## 5. Plano vigente para U06/U10

1. Reaproveitar páginas e visual existentes, sem reiniciar o frontend em React.
2. Buscar e selecionar um ID exato; recuperar ofertas e indicadores da API, eliminando a lista fixa como fonte final.
3. Corrigir menu mobile, links, `innerHTML` inseguro, alertas, contraste, rótulos e navegação por teclado conforme evidências reais.
4. Validar HTML/JS em desktop e mobile, com e sem rede, registrando dependências externas.
5. Somente considerar a interface concluída após teste integrado com Java/MySQL e revisão humana.

## 6. Registro da decisão

A proposta React foi **substituída** pela escolha HTML/CSS/JS para esta entrega. O histórico de 16/11 permanece preservado por este ADR; a revisão e merge do PR serão as evidências formais da atualização documental.
