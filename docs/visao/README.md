# Documento de Visão — histórico do PharmaFind

Esta pasta preserva a visão acadêmica do produto em dois momentos e conecta seus requisitos às especificações e decisões técnicas posteriores. Os documentos históricos não substituem a [SPEC](../SPEC.md) nem descrevem necessariamente o estado atual da implementação.

## Versões

| Versão documental | Fonte | Data de criação do PDF (Brasília) | Registro |
| --- | --- | --- | --- |
| [v1.0 — visão anterior](DOCUMENTO-DE-VISAO-v1.0.md) | `DOCUMENTO_DE_VISAO_PHARMAFIND_REVISADO__281_29_assinado_assinado__281_29_assinado_assinado_assinado_assinado.pdf` | 15/09/2026 | 40 páginas; seis assinaturas digitais com datas de 17 a 21/09/2026. |
| [v2.0 — visão posterior](DOCUMENTO-DE-VISAO-v2.0.md) | `DOC.PharmaFind.pdf` | 01/10/2026 | 38 páginas; sem assinaturas digitais identificadas. |

A sequência foi inferida pelos metadados de criação e pelas assinaturas do primeiro PDF, não por uma numeração formal preexistente. As datas não equivalem necessariamente a datas de aprovação. A numeração v1.0/v2.0 é atribuída retrospectivamente para organização; não corresponde às versões da SPEC.

## Evolução entre os dois PDFs

| Tema | v1.0 | v2.0 |
| --- | --- | --- |
| Identificação (§1) | Professor identificado como Romes; e-mails a definir. | Nome completo do professor e cinco e-mails preenchidos (omitidos nas versões públicas). |
| Domínio pretendido (§2) | `www.PharmaPhind.com.br`. | `www.PharmaFind.com.br`. |
| Justificativa (§6) | Redução do esforço de pesquisa, inclusive para pessoas com menor familiaridade tecnológica. | Ênfase na autonomia, transparência, economia, organização de dados e design orientado à decisão. |
| Consulta de ofertas (§14) | Prioridade alta; pertence ao MVP. | Prioridade média; continua no MVP. RF05 continua com prioridade alta. |
| Funcionalidades (§14) | Sete funcionalidades, todas no MVP. | Mantém as sete e lista outras sete de baixa prioridade e fora do MVP: login simulado, alertas por e-mail, histórico de buscas, favoritos, comparador lado a lado, modo escuro e avaliação simulada de farmácias. |
| Protótipos (§24) | Espaço reservado sem imagens visíveis na página 31. | Quatro imagens de protótipo visíveis nas páginas 29 e 30. |
| Requisitos (§16, §17 e §19) | 30 RF, 41 RNF efetivamente preenchidos (RNF15 ausente), cinco RN. | Mesma numeração e conteúdo dos RF e RNF, e mesmas cinco RN. |
| Modelo de dados e stack (§20–22) | Arquitetura de três camadas; HTML/CSS/JS, Java/Spring Boot e MySQL; quatro entidades principais. | Mantidos. |

As versões registram uma tensão sobre autenticação: ambas indicam que login não se aplica (§21) e descrevem a futura remoção das telas de login/cadastro (§27), mas a v2.0 inclui login simulado como ideia fora do MVP (§14). Não se deve interpretar essa inclusão como retorno da autenticação à entrega. A motivação exata da mudança de prioridade da consulta de ofertas não consta nos PDFs.

## Da visão acadêmica à especificação técnica

A tabela abaixo conecta as duas versões históricas ao que está documentado na `develop` (consulta em 26/11/2026, SPEC com atualização datada de 23/11/2026). Registra planejamento e decisões, não certifica implementação ou aprovação humana.

| Tema | Visão dos PDFs | Refinamento documentado na SPEC v1.1 / contexto |
| --- | --- | --- |
| Busca e identidade do medicamento | Pesquisa por nome e seleção; comparação do mesmo medicamento (RF01–RF09). | Seleção obrigatória de ID específico, sem misturar dosagens ou apresentações. |
| Processamento de dados | Comparação e menor preço; ofertas válidas/disponíveis (RN02). | Média aritmética, economia potencial e ranking; ofertas indisponíveis sinalizadas, excluídas dos cálculos (RF31–RF34). |
| Localização | CEP e geolocalização; ViaCEP previsto; proximidade (RF10–RF19). | Localização opcional; CEPs de teste previamente mapeados, GPS consentido e distância em linha reta, sem rotas. |
| Natureza dos dados | Base de teste controlada prevista nos riscos. | Farmácias, preços e históricos fictícios do Gama e região, sem ofertas comerciais reais. |
| Autenticação e extras | Login não necessário; funcionalidades complementares fora do MVP na v2.0. | Login/cadastro, alertas, favoritos, histórico de buscas, modo escuro e comparação de múltiplos medicamentos fora da entrega. |
| Histórico de preços | Entidade prevista no modelo e funcionalidade complementar na Sprint 6. | Histórico analítico por oferta (medicamento + farmácia), gráfico e variação nominal/percentual; U09, RF35–RF38. Não confundir com histórico de buscas. |
| Stack | HTML/CSS/JS, Bootstrap Icons, Java/Spring Boot e MySQL. | HTML/CSS/JS mantido; Java 21, Spring Web, Spring JDBC e Maven; React/Vite não adotados no MVP. Chart.js como opção. Decisão de 23/11 registrada sob revisão humana. |
| Governança | Git/GitHub, Trello e planejamento por sprints. | GitHub Issues, Kanban, branches de trabalho, PR e revisão humana; entrega informada de 30/11/2026. |
| Interface | Identidade visual, responsividade e protótipos. | U10: revisão do frontend e validação das observações do professor. |

## Rastreabilidade

- [SPEC.md](../SPEC.md): requisitos herdados da visão e requisitos acrescentados (RF31 em diante), comportamento-alvo e critérios técnicos.
- [CONTEXTO.md](../../CONTEXTO.md): decisões recentes, premissas e estado conhecido do projeto.
- [API.md](../API.md): contratos técnicos.
- [ADRs](../ADR/): decisões e justificativas arquiteturais; consultar o estado de cada ADR.
- [Issue #18](https://github.com/PharmaFind/PharmaFind/issues/18): refinamento documental da SPEC.
- [Issue #19](https://github.com/PharmaFind/PharmaFind/issues/19): histórico de preços (U09).
- [Issue #20](https://github.com/PharmaFind/PharmaFind/issues/20): revisão de frontend (U10).
- [Issue #30](https://github.com/PharmaFind/PharmaFind/issues/30): decisão de stack simplificada.

## Critérios de preservação

Os arquivos Markdown mantêm as 30 seções preenchidas, anexos, IDs, prioridades e marcações dos checklists, com adaptação de layout para leitura no GitHub. Foram retiradas as instruções e exemplos genéricos do formulário e omitidas matrículas e e-mails para evitar exposição desnecessária em repositório público. As imagens visíveis relevantes foram extraídas dos PDFs e estão disponíveis em `assets/`. As assinaturas digitais não são transferíveis ao Markdown; conservar os PDFs originais em local controlado. Não foram corrigidas divergências históricas, nem atribuídas datas de decisão sem evidência.

Para mudanças futuras de escopo, registrar a decisão na Issue/ADR correspondente e atualizar a SPEC por PR; manter as versões históricas intactas. Uma nova visão consolidada, caso necessária, deve ser elaborada e validada separadamente pela equipe.
