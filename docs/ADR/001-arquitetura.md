# ADR 001 — Arquitetura em camadas do PharmaFind

- **Status:** **Escolha arquitetural informada pela coordenação, sujeita à revisão da equipe no PR da Issue #18.**
- **Registro inicial:** 12/11/2026; **refinamento:** 16/11/2026.

## 1. Contexto

O repositório ainda contém páginas HTML/CSS/JavaScript tradicionais e esquema MySQL isolado, sem backend Java integrado. A entrega final informada é **30/11/2026**. O projeto deve implementar pesquisa, ofertas e processamento econômico, distância opcional, histórico fictício e correções de interface apontadas pelo professor.

## 2. Escolha técnica para implementação

Usar **frontend React + JavaScript + Vite**, com CSS/identidade visual reaproveitados, consumindo uma **API REST/JSON Java + Spring Boot**, que acessará **MySQL** por Spring JDBC. A arquitetura separa responsabilidades:

1. **Frontend:** rotas/telas, pesquisa, estado visual, validação de usabilidade, gráfico, erros e mensagens; sem cálculos monetários divergentes dos retornados pelo backend.
2. **Controller/DTO:** entrada HTTP, validação, contratos JSON e tratamento uniforme de erros.
3. **Service:** regras de ofertas elegíveis, comparações com precisão monetária, histórico e distância opcional.
4. **Repository:** consultas SQL parametrizadas a medicamentos, farmácias, ofertas e histórico no MySQL.

**O desenho é uma decisão-alvo, não evidência de componentes já implementados.** Detalhes em [ADR 004](004-backend-java.md), [ADR 006](006-frontend-react.md), [SPEC v1.1](../SPEC.md) e [API](../API.md).

## 3. Justificativa

A separação de interface, HTTP, negócio e persistência facilita testar números e contratos, dividir Issues entre integrantes e agentes de IA e evitar código de banco dentro do frontend. React facilita componentes reutilizáveis para novas telas; Spring Boot simplifica API Java. Priorizar o fluxo funcional antes de otimizações e novas abstrações.

## 4. Alternativas consideradas

- JavaScript tradicional + API Java: menor migração inicial, mas menos padronização dos estados de interface definidos para esta versão.
- Servlets/JSP: tecnicamente possível, mas menos alinhado à proposta frontend adotada; confirmar requisitos obrigatórios da disciplina.
- React com TypeScript: capacidade adicional de tipos, mas custo não justificado para este time/prazo.
- Microsserviços, infraestrutura distribuída, Next.js: complexidade desnecessária ao produto acadêmico.

## 5. Consequências

Exige configurar frontend React/Vite, backend Java/Maven e MySQL, tratamento CORS/proxy, dados de teste, migração do layout e validação de endpoints. A revisão do frontend deve incorporar problemas concretos registrados em U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20). A camada de histórico é U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19).

## 6. Estado da decisão

**Arquitetura selecionada pelo responsável do projeto e submetida à revisão humana em PR.** Não declarar aceita coletivamente nem implementada antes das evidências correspondentes.
