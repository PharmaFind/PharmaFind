# ADR 001 — Arquitetura em camadas do PharmaFind

- **Status:** **Aceita para a implementação do MVP pela coordenação em 23/11/2026; revisão humana do PR pendente.**
- **Registro inicial:** 12/11/2026; refinamento: 16/11/2026; decisão atual: 23/11/2026.
- **Referência:** [avaliação do professor em 23/11/2026](https://github.com/PharmaFind/PharmaFind/issues/30), ADR 004, ADR 006 e Documento de Visão.

## 1. Contexto

O PharmaFind tem frontend estático HTML/CSS/JavaScript e scripts MySQL, mas ainda não dispõe de backend/API integrada na versão inspecionada em 23/11. A proposta anterior de reescrever o frontend em React + Vite foi registrada em 16/11, sem implementação. O relatório do professor recomendou preservar HTML/CSS/JavaScript para concentrar o esforço na funcionalidade principal antes da entrega de **30/11/2026**.

## 2. Decisão

Adotar **arquitetura em camadas**, com:

1. **Apresentação:** HTML, CSS e JavaScript existentes, refatorados para consumir a API REST/JSON; busca, seleção, listagem, estados de carregamento/erro, responsividade, acessibilidade, CEP/GPS opcional e gráfico de histórico (quando implementado).
2. **Controller/DTO:** Java 21 + Spring Boot / Spring Web para endpoints, validação HTTP e contratos JSON.
3. **Service:** regras de negócio, preço válido, média, economia, ranking, histórico e distância opcional; aritmética monetária com `BigDecimal`.
4. **Repository:** Spring JDBC (`JdbcTemplate`) para consultas SQL **parametrizadas** e persistência em MySQL.

**Build:** Maven no backend; frontend estático sem obrigatoriedade de Node, npm ou Vite. Uma biblioteca JS para gráfico, como Chart.js, pode ser usada na U09 sem React. Não adotar TypeScript, Next.js, microsserviços ou troca de framework sem nova decisão registrada.

Detalhes: [ADR 004](004-backend-java.md), [ADR 006](006-frontend-react.md), [SPEC](../SPEC.md) e [API](../API.md).

## 3. Justificativa

Reutilizar o frontend reduz retrabalho, respeita a tecnologia descrita no Documento de Visão e concentra o esforço em uma aplicação de ponta a ponta, que hoje não existe. Java/Spring Boot/Spring JDBC mantém separação entre HTTP, regras e dados. A resposta do professor na avaliação de 23/11 confirmou que Spring Boot é aceito, sem obrigatoriedade de JSP/Servlets.

## 4. Alternativas consideradas

- **React + Vite:** proposto em 16/11; não adotado para o MVP atual pelo custo da migração, sem descartar possível evolução futura (ver ADR 006).
- **Servlets/JSP + JDBC:** permitido, mas exige mais configuração manual para rotas JSON.
- **Spring JPA/Hibernate:** possível, sem necessidade para o escopo das consultas propostas.
- **Microsserviços/Next.js/TypeScript:** custo desproporcional.

## 5. Consequências e escopo

- **U02–U04:** implementar e integrar API, MySQL, busca e comparação antes de alegar aplicação funcional.
- **U05:** distância opcional; consulta por preço não depende de localização.
- **U06/U10:** adaptar páginas atuais, corrigir menu, foco, contraste, navegação e comunicação com API sem migração React.
- **U07:** registrar execução de testes integrados; scripts SQL da U01 não comprovam API funcional.
- **U09:** histórico/gráfico **permanece no planejamento** da entrega, após estabilizar o fluxo central, sem adiamento automático para versão futura.
- **Escopo:** não foi congelado. Propostas de ampliação precisam de Issue, avaliação de dependências e decisão rastreável com o Product Owner/equipe, sem substituir o fluxo central por extras.
- **Responsáveis U02–U07:** aguardam validação; não atribuir automaticamente.

Nenhum componente, teste ou endpoint é considerado implementado apenas pela aprovação desta arquitetura.

## 6. Estado da decisão

Decisão **aprovada pela coordenação do projeto em 23/11/2026**, sujeita à revisão humana na integração deste documento. A decisão arquitetural não equivale à aceitação coletiva, à execução do código nem a mudanças já aprovadas no Documento de Visão.
