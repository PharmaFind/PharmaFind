# ADR 004 — Backend Java com Spring Boot, Spring JDBC e Maven

- **Status:** **Aceita para implementação pela coordenação em 23/11/2026; PR de documentação sujeito a revisão humana.**
- **Registro inicial:** 12/11/2026; refinamento em 16/11/2026; confirmação em 23/11/2026.

## 1. Contexto

A funcionalidade central exige API Java que consulte ofertas reais da massa **fictícia** no MySQL. Na avaliação de 23/11/2026 ainda não existiam arquivos Java, `pom.xml` ou endpoints integrados. O professor esclareceu na seção 14 do relatório que **JSP/Servlets não são obrigatórios**: o grupo pode escolher a tecnologia, desde que justifique.

## 2. Decisão técnica

Adotar **Java 21 + Spring Boot + Spring Web + Spring JDBC (`JdbcTemplate`) + Maven + MySQL**. Persistir ofertas e consultar dados demonstrativos por SQL parametrizado; não adicionar ORM apenas por preferência. Versões concretas de Spring Boot, driver MySQL e dependências devem ser fixadas **após teste de compilação/execução** e registradas no README.

- **Controller:** receber entradas HTTP, validar e responder JSON/erros.
- **Service:** aplicar regras de preço e disponibilidade, usar `BigDecimal` nas operações monetárias e calcular histórico/distância quando cabível.
- **Repository:** consultar tabelas MySQL por comandos SQL parametrizados.
- **DTOs:** contratos de saída independentes da estrutura interna do banco, conforme [API](../API.md).

As rotas de pesquisa, detalhes, comparação e histórico da [API](../API.md) ainda são **propostas**, não endpoints já implementados. Não adicionar autenticação, painel de farmácias ou processamento de compras por causa desta decisão.

## 3. Justificativa

Spring Boot simplifica a publicação de endpoints REST e os testes. Spring JDBC facilita SQL explícito sobre o esquema existente. Maven proporciona build reproduzível. O professor autorizou a escolha da tecnologia no relatório de 23/11, reduzindo a dúvida anterior sobre Servlets/JSP.

## 4. Alternativas avaliadas

- **Servlets/JSP + JDBC:** academicamente possível, porém mais configuração manual.
- **Spring Boot com JPA/Hibernate:** possível, mas custo de abstração dispensável no momento.
- **Node.js no backend:** diverge da escolha de Java do grupo.
- **Microsserviços:** fora da arquitetura prevista.

## 5. Consequências

A U02 [#11](https://github.com/PharmaFind/PharmaFind/issues/11) deve produzir o `pom.xml`, estrutura executável e acesso ao MySQL; U03/U04 entregam o fluxo de busca e comparação, U05 localiza opcionalmente, U09 implementa histórico planejado e U07 registra testes. O frontend permanece **HTML/CSS/JavaScript** conforme ADR 001; React/Vite não é requisito.

Usar segredos fora do Git, parâmetros em SQL e mensagens de erro sem dados internos. Não declarar a aplicação funcional até verificação real: buscar `Dipi`, escolher a Dipirona 500 mg e conferir três ofertas, menor R$ 8,99, média R$ 9,99 e economia R$ 2,00.

## 6. Estado da decisão

Decisão aprovada pela coordenação em 23/11/2026, com revisão de PR e validação de ambiente pendentes. Não implica aprovação de código ou fechamento da Issue U02.
