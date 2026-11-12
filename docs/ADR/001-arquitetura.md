# ADR 001 — Organização arquitetural do PharmaFind

- **Status:** **Proposta** (organização das camadas ainda não aprovada).
- **Data de elaboração:** 12/11/2026.
- **Escopo:** arquitetura do MVP, sem decidir framework Java neste registro.

## 1. Contexto

O PharmaFind possui front-end HTML/CSS/JavaScript e esquema SQL MySQL, mas ainda não possui backend Java integrado. O Documento de Visão cita MVC e uma arquitetura em camadas, porém o `CONTEXTO.md` esclarece que essa seção era provisória. O sistema precisa separar consultas, regras de comparação e persistência para cumprir a SPEC e permitir testes objetivos.

## 2. Decisão

**[PROPOSTA]** Manter a interface atual, criar uma API Java para o fluxo de busca/consulta e isolar: **requisições/validação HTTP**, **regras de preços/localização** e **consultas MySQL**. As unidades de cálculo devem ser testáveis sem renderizar HTML e, sempre que possível, sem exigir banco real. Os contratos previstos estão em [`../API.md`](../API.md), e a decomposição está em [`../SPEC.md`](../SPEC.md).

**[CONFIRMADO, sem escolha de framework]** HTML, CSS, JavaScript, Java e MySQL fazem parte da base tecnológica. O visual existente deve ser mantido/adaptado.

## 3. Justificativa

Separar responsabilidades reduz regras duplicadas entre front-end e backend, facilita testar valores monetários e evita tratar dados fixos no JavaScript como se fossem persistência real. O prazo acadêmico favorece estrutura simples, sem microsserviços.

## 4. Alternativas consideradas

- Regras inteiramente em JavaScript: rápido para prototipar, mas não integra a persistência Java/MySQL solicitada.
- JSP/Servlets com lógica de consulta misturada às páginas: possível, mas tende a dificultar testes e contratos isolados.
- API Java simples + front-end estático: **recomendada para avaliação**, preservando o código existente.
- React, microsserviços e arquitetura distribuída: desnecessários ao prazo e escopo atuais.

## 5. Consequências

Se a proposta for aprovada, surgirão classes/módulos para HTTP, serviço e persistência, testes para cálculos e uma migração para abandonar dados fixos como fonte principal. **Nenhum desses componentes existe ainda** na `develop` inspecionada. Antes de desenvolver, a equipe deve escolher a solução de build e framework no ADR 004.

## 6. Status da decisão

**Proposta.** A escolha de manter a stack e o visual é confirmada; **a divisão arquitetural específica ainda precisa de aprovação por PR**. Não citar este ADR como prova de arquitetura já implementada.
