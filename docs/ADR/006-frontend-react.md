# ADR 006 — Frontend com React e JavaScript (Vite)

- **Status:** **Escolha técnica informada pela coordenação em 16/11/2026; submetida à revisão da equipe neste PR.**
- **Data:** 16/11/2026.
- **Relacionamento:** ADR 001 (arquitetura), ADR 004 (backend), U06 [#15](https://github.com/PharmaFind/PharmaFind/issues/15), U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19), U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20).

## 1. Contexto

O frontend existente consiste em páginas HTML, CSS próprio, JavaScript e Pico CSS via CDN, com busca demonstrativa baseada em dados fixos. O fluxo final exigirá componentes reutilizáveis para resultados, detalhes, ofertas, filtros, estados vazios, localização e histórico com gráfico. A entrega final foi corrigida para **30/11/2026**. A equipe pretende utilizar agentes de IA como apoio à implementação, mantendo revisão humana.

## 2. Escolha técnica para implementação

Adotar **React com JavaScript (sem TypeScript)**, inicializado pelo **Vite**, para o frontend do MVP. Preservar a linguagem visual e aproveitar o CSS existente, refatorando apenas o necessário. Usar **Chart.js** para o gráfico de histórico de preços; uma integração React pode utilizar `react-chartjs-2` se facilitar o trabalho.

O backend será uma API Java separada, documentada no ADR 004. O frontend deve consumir JSON de endpoints documentados em `docs/API.md`; não manter listas fixas como fonte principal após a integração. Não introduzir Next.js, Redux, bibliotecas extensas de UI ou TypeScript sem nova justificativa e aceite.

**Distinção obrigatória:** esta é uma decisão de tecnologia **para desenvolver**, não evidência de que React, Vite ou Chart.js já estejam instalados. A aceitação arquitetural pela equipe ocorrerá pela revisão do PR; a implementação depende das Issues próprias.

## 3. Justificativa

Componentes ajudam a centralizar padrões visuais, reutilizar cartões e formulários e controlar estados de consulta. JavaScript sem TypeScript evita ampliar a curva de aprendizado do grupo. Vite simplifica ambiente e build. O uso de agentes de IA exige contratos e organização claros, não dispensa revisão, testes nem entendimento básico da aplicação.

## 4. Alternativas consideradas

- **HTML/CSS/JavaScript tradicionais:** menor migração, mas maior risco de duplicação e dificuldade para coordenar vários estados e páginas na proposta atual.
- **React + TypeScript:** tipos estáticos seriam úteis, mas adicionam complexidade de aprendizagem considerada desnecessária nesta entrega.
- **JSP/Servlets renderizando interface:** possível, mas não é a abordagem frontend escolhida; verificar exigências obrigatórias da disciplina antes de eliminar alternativa acadêmica.
- **Next.js/SPA complexa e bibliotecas de UI extensas:** não justificadas pelo MVP e pelo prazo.

## 5. Plano de migração e validação

1. Criar o projeto Vite/React com dependências versionadas e instruções de execução em U06/U08; não apagar o legado antes da migração funcional.
2. Criar componentes para navegação, pesquisa, seleção, ofertas, métricas, localização e gráfico (U09), preservando elementos de identidade visual viáveis.
3. Coordenar a auditoria do professor (U10): registrar problemas reais, telas afetadas e critérios de correção antes de tratá-los como aceitos.
4. Usar o contrato JSON documentado, com estados de carregamento, falha, ausência de resultados e indisponibilidade.
5. Validar desktop/mobile/teclado, fluxos reais com backend/MySQL e testes aplicáveis, com evidências em PRs.

## 6. Consequências e status

O repositório passará a ter processo de build do frontend, dependências npm e uma etapa explícita de migração. A estrutura final de diretórios, portas, proxy/CORS e scripts deve ser documentada **após existir e ser testada**, sem inventar comandos. O frontend original permanece referência visual, não se pressupõe que React já esteja implementado.

**Status final deste ADR:** escolha informada pela coordenação e sujeita à revisão humana do PR; registrar eventuais ajustes de equipe antes de tratá-la como aceita coletivamente.
