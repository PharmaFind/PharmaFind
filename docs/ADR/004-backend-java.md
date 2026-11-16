# ADR 004 — Escolha do backend e das ferramentas Java

- **Status:** **Proposta**.
- **Data de elaboração:** 12/11/2026.

## 1. Contexto

O MVP exige Java, acesso ao MySQL, contratos JSON e regras de preço testáveis. O repositório contém apenas front-end estático e SQL. O Documento de Visão menciona tecnologias de modo provisório; o grupo ainda não aprovou Spring Boot, Maven, JUnit, versões nem forma de hospedar a API. O prazo de 19/11 favorece implementação que todos consigam executar.

## 2. Decisão

**[PROPOSTA, NÃO APROVADA]** Avaliar inicialmente **Java + Spring Boot + Maven + JDBC** (ou uma biblioteca de acesso equivalente simples) para expor os três contratos HTTP em [`../API.md`](../API.md) e consultar MySQL. Avaliar **JUnit** para testes unitários da lógica econômica e de proximidade, separado de testes de integração HTTP/DB.

Se o grupo tiver mais familiaridade com **Servlets + Tomcat**, preferir essa alternativa em vez de adotar framework novo sem tempo de aprender. Em ambos os casos, manter os contratos da SPEC e evitar lógica monetária dentro de controllers/JSP.

## 3. Justificativa

Uma API Java pequena aproveita a interface existente e centraliza cálculos. Maven e um framework consolidado podem acelerar configuração, mas apenas se a equipe já conseguir utilizá-los e testá-los com segurança.

## 4. Alternativas consideradas

- **Spring Boot + Maven:** potencialmente mais rápido para rotas/JSON; custo de aprendizado/configuração.
- **Servlets + Tomcat e JDBC:** compatível com conhecimento acadêmico prévio; pode exigir maior configuração manual de JSON/rotas.
- **Aplicação desktop, React obrigatório ou microsserviços:** não correspondem à entrega web curta.
- **Manter apenas JavaScript estático:** não atende ao objetivo de integração com Java/MySQL.

## 5. Consequências

Aprovada a opção, deverão existir projeto executável, instruções de instalação, dependências com versões, variáveis de ambiente, consultas SQL parametrizadas, testes e instruções reproduzíveis. A apostila pede também harness e ambiente padronizado; **Docker/CI/agente não foram configurados por este ADR**.

## 6. Status da decisão

**Proposta.** Escolher uma opção com demonstração executável mínima e registrar o resultado em PR, atualizando este ADR com aprovação real, e então o README. Não inventar versão ou comando de inicialização antes de existir código correspondente.
