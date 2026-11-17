# ADR 004 — Backend Java com Spring Boot, Spring JDBC e Maven

- **Status:** **Escolha técnica informada pela coordenação em 16/11/2026; sujeita à revisão da equipe no PR da Issue #18.**
- **Registro original:** 12/11/2026; **refinamento:** 16/11/2026.

## 1. Contexto

O projeto exige backend Java e MySQL com API JSON, regras de preço testáveis e localização opcional. Em 16/11/2026, a inspeção encontrou apenas frontend demonstrativo e SQL inicial, sem backend Java. A entrega final foi confirmada pela equipe para **30/11/2026**. Será necessário integrar também um histórico temporal de preços (U09), sem comprometer o fluxo central.

## 2. Escolha técnica para implementação

Adotar **Java 21 + Spring Boot + Spring Web + Spring JDBC (`JdbcTemplate`) + Maven + MySQL**. Usar **JUnit / Spring Boot Test** para testes automatizados quando configurados. As versões concretas de Spring Boot, Maven/driver e demais dependências devem ser fixadas no projeto e registradas após validação. Uma linha compatível com Java 21 deve ser escolhida, sem pressupor versão já instalada.

- **Controller:** receber requisições, validar entrada e devolver HTTP/JSON e erros padronizados.
- **Service:** aplicar regras de comparação, disponibilidade, economia e histórico; cálculo monetário com `BigDecimal`.
- **Repository:** consultar MySQL por SQL parametrizado, sem concatenação de dados do usuário.
- **DTO:** expor campos correspondentes à `docs/API.md`, desacoplados de tabelas SQL.

API atual proposta inclui pesquisa, detalhe e comparação; a U09 justifica um contrato adicional de **leitura do histórico por medicamento e farmácia** (documentado como proposto, não implementado). Não adicionar autenticação, painel ou APIs de atualização de farmácias nesta etapa.

## 3. Justificativa

Spring Boot facilita inicialização de API REST, configuração e testes; Spring JDBC permite consultas claras e controladas para o domínio relacional de farmácias e ofertas, sem introduzir um ORM por obrigação. Maven torna a construção reproduzível. Uma aplicação monolítica simples é suficiente para o prazo acadêmico.

## 4. Alternativas consideradas

- **Servlets + Tomcat + JDBC:** atende à linguagem Java e a conteúdos tradicionais da disciplina, mas exigiria mais configuração manual para JSON, dependências e roteamento.
- **Spring Boot + JPA/Hibernate:** viável, mas adiciona abstrações cujo custo não se justifica para as consultas planejadas.
- **JavaScript/Node no backend:** não atenderia à escolha de Java feita no projeto.
- **Microsserviços:** complexidade operacional desnecessária.

Confirmar se existe exigência obrigatória de JSP/Servlets/Tomcat nas instruções do professor. Caso exista, registrar e aprovar a adaptação arquitetural antes da implementação final.

## 5. Consequências

A U02 [#11](https://github.com/PharmaFind/PharmaFind/issues/11) deve criar projeto executável e acesso MySQL; a U01 [#10](https://github.com/PharmaFind/PharmaFind/issues/10) prepara schema e dados; U03/U04/U05 implementam domínio e contratos; U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19) trata histórico. U07 cria testes e U08 documenta ambiente. Nunca versionar senhas; registrar comandos, logs e resultados reais nos PRs.

## 6. Estado da decisão

**Escolha submetida à revisão pela equipe.** O registro de uma stack-alvo não significa que dependências, controllers, testes ou endpoints já existam no repositório.
