# PharmaFind — CONTEXTO DO PROJETO

> **Base 1.0 (11/11/2026) | Histórico factual de 12 e 16/11 | Decisão de stack atualizada em 23/11/2026**
> **Precedência temporal:** decisões atuais da seção 4 e do registro de 23/11 prevalecem sobre descrições históricas de React/stack em registros datados anteriores. Não confundir documentos com código executado.
> **Fontes:** Documento de Visão do PharmaFind (`DOC.PharmaFind.pdf`); materiais da disciplina (`DocumentoRomes.pdf` e `SDD.pdf`); estado do repositório observado em 11–12/11/2026; inspeção direta da organização `PharmaFind/PharmaFind` em 12/11/2026; decisões do grupo informadas à equipe.
> **Legenda:** `[CONFIRMADO]` decisão aprovada pelo grupo; `[IMPLEMENTADO]` artefato ou comportamento identificável no código versionado, sem implicar teste de execução; `[VERIFICADO]` fato confirmado por inspeção do código ou do GitHub, com sua origem identificada; `[PROPOSTA]` definição ainda não aprovada; `[PENDENTE]` validação, decisão ou implementação não concluída. Rótulos legados preservados neste arquivo: `[DOCUMENTO]` indica origem no Documento de Visão; `[OBSERVADO]` corresponde a inspeção do repositório, **não** a teste executado; `[ATENÇÃO]` indica risco; `[AÇÃO]` indica providência. A combinação de rótulos não transforma uma proposta em decisão confirmada.
>
> **Finalidade:** oferecer a membros da equipe e agentes de IA uma referência comum sobre **o que o PharmaFind é, o que deve fazer, o que já existe, o que fica fora do escopo e como o desenvolvimento será organizado**. Este contexto não substitui a especificação técnica verificável (`docs/SPEC.md`), os testes nem o código.
>
> **Regra de interpretação:** decisões `[CONFIRMADO]` prevalecem sobre descrições genéricas/provisórias do PDF, especialmente na stack e na arquitetura. Em conflitos não explicitamente resolvidos, registrar a dúvida em vez de inventar uma decisão.

## Resumo executivo das decisões

- **Entrega de 12/11/2026:** GitHub organizado, governança, tarefas, colaboração real e documentação técnica; avaliação diretamente pelo repositório.
- **Entrega final em 30/11/2026:** pesquisa e comparação, localização opcional, histórico fictício e revisão do frontend. A previsão anterior era 19/11, corrigida em 16/11.
- **Tecnologias base:** HTML, CSS, JavaScript, Java e MySQL; bibliotecas/frameworks podem ser escolhidos para simplificar.
- **Base de demonstração:** **farmácias fictícias e preços fictícios**, gravados em MySQL, representando a região do **Gama e arredores**.
- **Fluxo de pesquisa:** primeiro selecionar o medicamento; depois consultar e comparar as ofertas daquele medicamento.
- **Localização:** **opcional**; distância **aproximada em linha reta**, quando houver coordenadas. A primeira versão usará **CEPs de teste da região e coordenadas previamente cadastradas**. GPS do navegador depende de consentimento.
- **Ofertas indisponíveis:** **aparecem identificadas como indisponíveis**, mas **não participam da média, menor preço, economia, ranking de ofertas disponíveis nem do destaque de melhor preço**.
- **Processamento:** menor preço, média, economia potencial e ranking das ofertas válidas; sem score composto preço/distância. Histórico de preços por oferta e gráfico entram como U09 (#19).
- **Interface:** manter e adaptar HTML/CSS/JavaScript existentes, integrando à API Java e corrigindo observações reais do professor em U10 (#20); React/Vite não serão usados neste MVP, conforme ADR 006.
- **Equipe:** quatro desenvolvedores identificados, mas **apenas alguns podem colaborar em 11–12/11**. Não presumir disponibilidade de todos; revisões precisam ser verdadeiras.
- **Modelo comercial futuro:** farmácias parceiras pagariam pelo serviço e manteriam ofertas atualizadas. **Sem painel de farmácias, cobrança nem autenticação nesta entrega.**

## 1. Identidade do produto

- [CONFIRMADO/DOCUMENTO] **Nome:** PharmaFind.
- [DOCUMENTO] **Slogan:** “O melhor preço, de um jeito mais simples.”
- [CONFIRMADO/DOCUMENTO] Aplicação web para pesquisar medicamentos e comparar ofertas de farmácias, com preço e distância aproximada como critérios de escolha.
- [DOCUMENTO] Público-alvo inicial: consumidores adultos, com foco contextual no Gama e região.
- [DOCUMENTO] O PharmaFind não recomenda tratamentos nem medicamentos; também não realiza venda, pagamento de medicamentos, pedido ou reserva. A escolha e a compra são externas à plataforma.
- [CONFIRMADO] **Modelo de negócio pretendido para o futuro:** as farmácias pagam para utilizar o serviço e são responsáveis por manter suas ofertas, disponibilidade e preços atualizados. A cobrança da farmácia é distinta da compra de medicamentos pelo consumidor. Esse modelo ainda não implica uma cobrança ou painel de farmácia implementado no MVP acadêmico.

## 2. Prazos, critérios e finalidade das entregas

- [CONFIRMADO] **12/11/2026 (quinta-feira):** entrega intermediária de **organização do GitHub e documentação**, avaliada diretamente no repositório pelo professor. A prioridade é demonstrar branches, proteção quando possível, Issues, Project, PRs com colaboração verdadeira, README e documentação de SDD.
- [CONFIRMADO EM 16/11] **30/11/2026 (segunda-feira):** entrega final; substitui o prazo antigo de 19/11. A entrega intermediária de 12/11 permanece histórica.
- [DOCUMENTO/CHECKLIST INFORMADO] Critérios relevantes da entrega intermediária incluem `main`, `develop` e `feature/*` usadas em trabalho real; governança por PR e revisão; Issues e Project com movimento genuíno; README e ADRs; `docs/SPEC.md` com RFs, RNFs verificáveis e RNs numeradas; exemplos literais de contratos JSON/status/erro; decomposição por unidades ligada às Issues; refinamento real da SPEC, quando ocorrido, registrado por PR.
- [ATENÇÃO] **Não é possível afirmar que nunca houve commit direto na `main` em todo o histórico:** já há commits antigos nessa branch. Preservar o histórico, documentar a data de adoção das novas regras e impedir novos pushes diretos após a proteção; **não reescrever commits para criar aparência de conformidade**.
- [CONFIRMADO] Para 12/11, **não priorizar automações sofisticadas**; foco na organização, documentação e colaboração. Agente de IA, Docker e harness de testes podem ser tratados conforme exigências posteriores e viabilidade.
- [ATENÇÃO] Apenas parte da equipe deve conseguir participar em 11–12/11. Ajustar tarefas e PRs à disponibilidade real, sem falsificar aprovações nem atribuir trabalho inexistente.

## 3. Estado atual da implementação (verificação de 12/11/2026)

- [OBSERVADO] **Repositório oficial atual:** https://github.com/PharmaFind/PharmaFind, pertencente à organização GitHub **`PharmaFind`**. A referência antiga `tainayyxy/PharmaFind` descrevia a propriedade anterior e não deve ser usada como URL oficial.
- [VERIFICADO] A branch padrão é `main`. Existem `develop`, `feature/estrutura-documentacao` (histórica) e as branches de documentação `feature/2-readme-contexto`, `feature/3-spec-api` e `feature/4-adrs-colaboracao`.
- [OBSERVADO] A ruleset ativa **“Protecao main e develop”** se aplica a `main` e `develop` e exige PR, **uma aprovação**, resolução das conversas de revisão, bloqueio de exclusão e de atualização não fast-forward. Sua presença foi verificada na API do GitHub; não se afirma que os testes automatizados já sejam exigidos por ela.
- [OBSERVADO] O **PR #1**, “chore: estrutura inicial de documentação”, foi aprovado por `Lucasdsantosb` e integrado à `develop` em 12/11/2026. Ele criou **dez arquivos vazios intencionalmente**: `README.md`, `CONTEXTO.md`, `CONTRIBUTING.md`, `docs/SPEC.md`, `docs/API.md`, dois ADRs e três templates. Isso comprova somente a criação da estrutura, não a conclusão da documentação.
- [VERIFICADO EM 16/11] PRs #5–#8 integraram documentação à `develop`; PR [#9](https://github.com/PharmaFind/PharmaFind/pull/9) aprovado por `@tainayyxy` e integrado à `main` em 16/11. `main` não é mais apenas código original. Issues #2–#4 ainda estavam abertas na última consulta. O Kanban foi criado e demonstrado por captura do usuário; movimentos não verificados por API.
- [IMPLEMENTADO/VERIFICADO POR CÓDIGO] Pastas de implementação na `develop`: `frontend/` (HTML/CSS/JavaScript) e `database/PharmaFindDB.sql` (script de criação de tabelas MySQL), além de `.vscode/settings.json`. Esta constatação decorre da inspeção de arquivos e não comprova execução do banco.
- [IMPLEMENTADO/VERIFICADO POR CÓDIGO] `frontend/consulta.js` contém **dez medicamentos demonstrativos fixados no próprio JavaScript**; a página possui busca textual, filtros de tipo e farmácia, ordenação local por preço e cartões com botão demonstrativo que abre um `alert`, **sem consulta HTTP ao backend**. Não há seleção seguida de comparação de várias ofertas de um mesmo medicamento. `frontend/index.html` ainda inclui links de login e cadastro. A presença dos scripts não equivale à validação funcional no navegador.
- [ESTADO LOCAL DA BRANCH U02] `backend/` contém aplicação Spring Boot, configuração JDBC e repositórios de leitura; esta presença não comprova compilação ou conexão MySQL. Endpoints de negócio e integração efetiva do frontend continuam pendentes. O JavaScript `frontend/script.js` obtém coordenadas pelo navegador e as registra em `console.log`, mas não calcula distâncias nem integra o GPS ao backend.
- [CONFERÊNCIA LOCAL U02 EM 26/11/2026] O merge `21eec81` incorpora a `develop` em `53c7ae2` (PR #34): `database/PharmaFindDB.sql` define quatro tabelas, sem USUARIO, e inclui `APRESENTACAO` obrigatória. A branch U02 contém os repositórios Java correspondentes; evidências de execução em `backend/tests/RESULTADOS.md`. Não há endpoints de negócio nem integração do frontend.
- [CONFIRMADO] **Não existe código mais recente fora do GitHub que deva ser integrado:** o repositório é o ponto de partida real da continuação.
- [AÇÃO] Preservar o visual existente; implementar o novo fluxo por Issue e PR; tirar login/cadastro da navegação ativa sem atribuir a mudança a uma implementação já feita.

## 4. Stack e escolha de ferramentas

- [CONFIRMADO] **Núcleo tecnológico:** HTML, CSS, JavaScript, Java e MySQL.
- [CONFIRMADO] **Frameworks e bibliotecas são permitidos e bem-vindos** quando simplificarem o desenvolvimento. As tecnologias não precisam ser usadas de forma “pura”.
- [CONFIRMADO] A seção de stack/arquitetura do Documento de Visão foi preenchida provisoriamente; **não é uma decisão técnica vinculante**.
- [APROVADA PELA COORDENAÇÃO EM 23/11; PR EM REVISÃO] Frontend **HTML/CSS/JavaScript**, com backend **Java 21 + Spring Boot (Spring Web) + Spring JDBC + Maven** e **MySQL**. Chart.js pode ser utilizado no histórico U09 sem React. ADR 001/004 vigentes; ADR 006 registra React/Vite não adotados no MVP. Nada disso comprova integração implementada.
- [DIRETRIZ ATUAL] Reutilizar páginas existentes e simplificar componentes em JS; não criar estrutura React/Vite nesta entrega. Evitar TypeScript, Next.js e microsserviços. A prioridade funcional é U02–U04, seguida de interface, testes e U09 planejada.

## 5. Fluxo principal do usuário

1. [CONFIRMADO] O usuário digita um nome completo ou parcial de medicamento (por exemplo, “Dipirona”).
2. [CONFIRMADO] O sistema **primeiro lista os medicamentos correspondentes** (por exemplo, “Dipirona 500 mg”, “Dipirona 1 g”).
3. [CONFIRMADO] O usuário seleciona um medicamento específico.
4. [CONFIRMADO] Em uma tela de detalhes/consulta, o sistema mostra as farmácias que possuem ofertas para **aquele medicamento**, com preço e informações da farmácia.
5. [CONFIRMADO] O usuário compara preço, identifica menor preço e, se tiver informado localização, observa as distâncias aproximadas.
6. [CONFIRMADO] O usuário toma sua decisão de compra fora do PharmaFind.

## 6. Localização e proximidade

- [CONFIRMADO] **Localização não é obrigatória.** O visitante pode pesquisar medicamentos e comparar preços sem CEP nem GPS.
- [CONFIRMADO] Exibir **distância aproximada em quilômetros, calculada em linha reta entre coordenadas**, quando houver localização do usuário e da farmácia. Não representar a distância como tempo de deslocamento ou rota por ruas.
- [CONFIRMADO] Primeira implementação por CEP: usar **CEPs de teste selecionados para o Gama e arredores, com coordenadas correspondentes previamente cadastradas**. Não prometer cobertura de qualquer CEP brasileiro nessa versão.
- [CONFIRMADO] Farmácias demonstrativas terão coordenadas **cadastradas na base de teste**, mesmo sendo estabelecimentos fictícios; dados e endereços devem ser marcados como demonstrativos.
- [DOCUMENTO/CONFIRMADO] Geolocalização do navegador só será consultada mediante autorização do usuário; se recusada/indisponível, o visitante pode usar um CEP de teste ou continuar sem distância.
- [PROPOSTA] Quando a localização não estiver disponível: não exibir distâncias inventadas, indicar que a ordenação por proximidade depende da localização e manter normalmente a comparação por preços.
- [U01 VERIFICADA NA MAIN] Três CEPs de teste com coordenadas documentadas em `database/seeds/ceps-teste.json`; ainda falta integrar cálculo/resposta na U05 e testar CEP não mapeado, permissão negada e coordenadas ausentes.
- [ATENÇÃO] **ViaCEP não fornece latitude e longitude**; uma consulta de CEP não produz automaticamente distância. Serviço externo de geocodificação para todos os CEPs pertence a evolução futura, se necessário.

## 7. Base de dados, ofertas e disponibilidade

- [CONFIRMADO] **Usar farmácias fictícias e preços fictícios**, com dados persistidos de verdade no **MySQL**. A região representada pela demonstração é o **Gama e arredores**.
- [CONFIRMADO] Atualizações de preços e disponibilidade na entrega atual serão executadas **diretamente no MySQL pela equipe**, sem interface administrativa.
- [DOCUMENTO] Cada oferta corresponde a um medicamento específico e a uma farmácia específica; deve possuir preço válido e permitir associar sua disponibilidade. Medicamentos de dosagens/apresentações diferentes não devem ter ofertas misturadas.
- [CONFIRMADO] **Ofertas indisponíveis devem permanecer visíveis**, com identificação explícita como “Indisponível”, para dar transparência ao usuário. Elas **não são elegíveis para menor preço, média, economia potencial, ranking de preços disponíveis nem indicação de melhor oferta**.
- [CONFIRMADO] Quando não houver ofertas disponíveis para o medicamento, não calcular média/economia fictícias; mostrar estado vazio/aviso claro, podendo listar ofertas indisponíveis separadamente.
- [DOCUMENTO] Informar nome, endereço e horário da farmácia quando cadastrados, além de aviso de que valores podem mudar.
- [ATUALIZAÇÃO 23/11] A U01 foi integrada à `main` no PR #27: oferta tem disponibilidade e data de atualização, migrações e seed com 6 medicamentos, 4 farmácias e 12 ofertas. O PR #29 propõe sincronizar essas mudanças à `develop` (ainda requer revisão/merge). O professor testou as restrições existentes, apontando ajustes adicionais em HISTORICO_PRECO, FARMACIA e MEDICAMENTO; **API/Java/frontend integrados ainda não existem**.
- [CONFIRMADO] **Modelo de negócio futuro:** farmácias pagariam para participar e seriam responsáveis pelo cadastro e pela atualização de suas ofertas. Não implementar login/painel de farmácias, cobranças ou integração de preços reais até 30/11.
- [U01 ATUALIZADA] Disponibilidade e data de atualização estão definidas no banco de `main`; os detalhes constam em `database/README.md` e `docs/SPEC.md`. Pendentes as restrições adicionais indicadas pelo professor (histórico, CEP/coordenadas e unicidade da apresentação).

## 8. Processamento e critérios de comparação

- [CONFIRMADO] Os cálculos usam **apenas ofertas disponíveis e válidas do medicamento exato selecionado**. Ofertas indisponíveis permanecem identificadas na interface, mas são excluídas dos cálculos.
- [CONFIRMADO] Exibir **menor preço disponível**, **média aritmética** dos preços válidos, **economia potencial** comparando a menor e a maior oferta válida e **ranking de ofertas/farmácias do menor para o maior preço**.
- [PROPOSTA] `media = soma(precos_validos) / quantidade_de_ofertas_validas`; `economia_potencial = maior_preco_valido - menor_preco_valido`. Para uma única oferta válida, economia = R$ 0,00; para nenhuma, não apresentar números calculados sem base.
- [CONFIRMADO] **Não adicionar score que combine preço e distância** nesta etapa. Distância pode ser ordenada separadamente quando disponível.
- [CONFIRMADO, ALTERAÇÃO EM 16/11] Histórico fictício por medicamento e farmácia, gráfico de linha e variações temporais entram no escopo de U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19), após estabilizar a comparação. Previsão e integração de preços reais continuam fora.
- [PENDENTE] Especificar desempate de preços, precisão/arredondamento de valores monetários e formato de números nos testes da `docs/SPEC.md`.

## 9. Escopo do MVP (entrega até 30/11)

### Incluído / alvo de implementação

- Pesquisa por nome completo ou parcial e listagem de medicamentos correspondentes.
- **Seleção de um medicamento específico antes de mostrar suas ofertas**.
- Farmácias e preços de demonstração persistidos em MySQL; ofertas disponíveis e indisponíveis mostradas distintamente.
- Comparação de preços com menor preço, média, economia em relação à oferta mais cara e ranking por menor preço.
- Localização opcional: CEPs de teste do Gama/região mapeados para coordenadas, geolocalização do navegador com permissão e distância em linha reta em km quando possível.
- Ordenação por distância quando houver coordenadas, sem interromper pesquisa/consulta se não houver.
- Estados de busca sem correspondências, medicamento sem oferta, todas ofertas indisponíveis, CEP não contemplado, geolocalização negada/indisponível e falhas de integração.
- **Manter a identidade visual atual**, adaptando as páginas e o caminho de navegação necessários para o fluxo principal.

### Explicitamente fora da entrega

- Login/cadastro de consumidores no fluxo do MVP; páginas e links existentes devem ser retirados/adaptados por trabalho rastreado.
- Login/painel de farmácias, cobrança, assinaturas ou pagamentos de medicamentos.
- Preços reais capturados automaticamente; as ofertas demonstrativas serão atualizadas pela equipe via banco.
- Favoritos, alertas, histórico de pesquisas, modo escuro, comparador lateral de vários medicamentos.
- Score composto preço + distância, previsões, scraping de valores reais e gráficos históricos avançados com várias séries.
- Rotas pelas ruas ou cobertura automática de todos os CEPs do Brasil.

**Princípio de priorização:** deixar o fluxo **pesquisar → selecionar → comparar → visualizar distância opcional** demonstrável de ponta a ponta antes de ampliar o escopo.

## 10. Equipe, papéis e colaboração

- [CONFIRMADO] A divisão geral do Documento de Visão permanece:
  - **Lucas Marques (`@lucasmarques07`)** — Scrum Master; organização/governança do GitHub e apoio ao banco de dados.
  - **Tainá do Amaral (`@tainayyxy`)** — desenvolvimento; antiga proprietária na conta pessoal. O repositório agora é da organização `PharmaFind`.
  - **Everton Gabriel (`@MrEve3`, confirmado em 16/11)** — desenvolvimento.
  - **Lucas dos Santos Bezerra (`@Lucasdsantosb`)** — desenvolvimento.
  - **Júlia Gabrielle** — analista/engenheira de requisitos; validação de requisitos e documentação.
  - **Roberto Carlos** — Product Owner; prioridades, esclarecimentos e aceite do produto.
- [CONFIRMADO, CONFORME CONTEXTO DA EQUIPE] Os **quatro primeiros** participam do desenvolvimento no GitHub; conferir o acesso individual atual à organização antes de atribuir tarefas. **Júlia e Roberto não atuam no desenvolvimento via GitHub nesta etapa**, embora continuem com responsabilidades de requisitos/produto fora do repositório.
- [CONFIRMADO] **Apenas alguns desenvolvedores conseguem colaborar no período imediato 11–12/11**. **Ainda não foi informado quais**, nem seus horários. Não planejar quatro PRs simultâneos ou aprovações de pessoas indisponíveis como condição para a entrega.
- [CONFIRMADO] Lucas Marques atua na governança do GitHub como Scrum Master. [OBSERVADO] O repositório já está na organização `PharmaFind`, com regras ativas sobre as branches principais; a antiga pendência de transferir o repositório pessoal foi superada. As permissões de cada membro e a administração organizacional ainda devem ser geridas pela equipe.
- [CONFIRMADO EM 16/11] O GitHub correto do Everton é `@MrEve3`. [PENDENTE] Confirmar responsáveis e revisores disponíveis antes de atribuir as Issues #10–#17, #19 e #20.
- [CONFIRMADO, INFORMADO PELA EQUIPE] O professor verificará o repositório. [DOCUMENTO] A apostila `DocumentoRomes.pdf`, p. 25–26, **também descreve uma submissão em PDF único no Moodle** e evidências de ambiente, agente e testes. [PENDENTE] Confirmar se essa orientação integral se aplica à data e turma atuais; não ignorar a divergência.

## 11. Governança GitHub e documentação SDD

### Entrega intermediária — 12/11/2026

- [CONFIRMADO/OBSERVADO] **Branches:** `main` como versão estável, `develop` como integração e `feature/<id-issue>-<descricao>` para novos trabalhos. PRs de `feature/*` para `develop`; PR de integração `develop` para `main` quando houver entrega estável. Já existe `feature/estrutura-documentacao` como branch histórica sem ID de Issue.
- [OBSERVADO] **Proteção ativa:** uma ruleset cobre `main` e `develop`, exige PR com pelo menos **uma aprovação**, resolve conversas de revisão e impede exclusões e atualizações não fast-forward. Manter a configuração e não adulterar os commits antigos de `main`.
- [VERIFICADO] **Rastreabilidade:** Issues documentais #2–#4 abertas na última consulta; PRs #5–#8 integrados à `develop`, PR #9 integrado à `main` em 16/11. U01–U08 são Issues #10–#17; atualização documental [#18](https://github.com/PharmaFind/PharmaFind/issues/18), U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19) e U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20). Project Kanban criado pelo usuário, movimentação não verificada diretamente.
- [OBSERVADO/DIRETRIZ] O PR #1 foi aprovado e integrado à `develop` com uma aprovação real. Novos PRs devem trazer mudanças legítimas e revisão de outro integrante; não inventar comentários, commits, aprovadores, refinamentos ou atividade.
- [IMPLEMENTADO/VERIFICADO POR ARQUIVO] **README e CONTEXTO:** `README.md` e `CONTEXTO.md` foram preenchidos na branch `feature/2-readme-contexto` e **integrados à `develop` pelo PR #5** (relacionado à Issue #2). O README distingue a demonstração estática da integração futura, com instruções para os componentes versionados; conteúdo documental não comprova execução do MVP.
- [IMPLEMENTADO/VERIFICADO POR ARQUIVO] **SPEC e API:** `docs/SPEC.md` e `docs/API.md` foram preenchidos na branch `feature/3-spec-api` e **integrados à `develop` pelo PR #6** (relacionado à Issue #3), com requisitos, regras, cenários e **contratos HTTP/JSON propostos**. A publicação desses contratos **não equivale à aprovação das propostas técnicas nem à implementação de endpoints**.
- [IMPLEMENTADO/VERIFICADO POR ARQUIVO] **ADRs e colaboração:** `docs/ADR/001` a `005`, `CONTRIBUTING.md` e templates foram preenchidos na branch `feature/4-adrs-colaboracao` e **integrados à `develop` pelo PR #7** (relacionado à Issue #4). Os ADRs distinguem decisões de produto confirmadas de propostas técnicas; o framework Java no ADR004 continua **[PROPOSTA]**. Uma revisão `v1.0 → v1.1` só conta como evolução quando houver **mudança substantiva justificada** e PR que a registre; não criar diferença cosmética para fabricar evidência.
- [ATENÇÃO] `main` tem commits diretos históricos, anteriores à governança atual; o requisito de “nenhum commit direto em todo o histórico” não é recuperável sem manipular o histórico. Reconhecer a transição e preservar os registros.

### Desenvolvimento — até 30/11/2026

- [CONFIRMADO/ALVO] Integração do front-end atual com backend Java/MySQL, busca e seleção de medicamento, ofertas válidas/indisponíveis, comparação e métricas definidas, CEPs de teste/GPS opcional e distância em linha reta.
- [PROPOSTA] Testes automatizados de regras de negócio e casos de borda; ambiente de execução reproduzível quando viável (Docker se exigido); documentação técnica e PRs de revisão.
- [PRIORIDADE] Implementar e validar o fluxo fim a fim antes de investir em automação sofisticada.

## 12. Regras transversais, qualidade e segurança

- [DOCUMENTO/CONFIRMADO] **Não misturar** ofertas de medicamentos com diferentes IDs, dosagens ou apresentações.
- [CONFIRMADO] Ofertas **indisponíveis** devem aparecer sinalizadas, porém nunca determinar menor preço, média, economia ou ranking de ofertas disponíveis.
- [CONFIRMADO] Comparar preço e proximidade **separadamente**; a mais próxima pode não ser a mais barata. Decisão de compra pertence ao usuário, fora do PharmaFind.
- [DOCUMENTO] Validação de entradas no servidor, consultas SQL parametrizadas e tratamento de erros; não expor dados sensíveis em logs ou no navegador sem necessidade.
- [DOCUMENTO] Coletar localização apenas quando necessária ao recurso solicitado, com consentimento do GPS; não guardar localização precisa permanentemente sem necessidade/autorização.
- [DOCUMENTO] Interface responsiva, com HTML semântico, labels, foco visível, contraste, navegação por teclado e estados de erro claros. Usar a identidade visual atual como base.
- [DOCUMENTO] Explicitar que preços/farmácias desta versão são **fictícios**, não representam ofertas comerciais reais e podem estar desatualizados; mostrar data de atualização quando houver no registro.
- [PENDENTE NA SPEC] Decidir e testar: critérios de oferta válida; preço zero/negativo; regra de empate; arredondamento de média; comportamento sem ofertas disponíveis e de CEP não cadastrado.

## 13. Plano de trabalho imediato (referência, não execução registrada)

### Histórico de 11–12/11: organização do GitHub

1. Confirmar **quem está disponível de fato** e quem pode fazer a revisão de ao menos um PR. Se só uma pessoa estiver online, não fingir uma revisão; antecipar documentação/Issues e registrar o trabalho real.
2. Repositório já transferido à organização; Lucas coordena a governança e os administradores mantêm as regras. Não reabrir como tarefa uma migração que já aconteceu.
3. As Issues #2–#4 foram abertas, e os PRs #5–#7 tiveram seus conteúdos documentais **integrados à `develop` em 12/11/2026**. Conferir o atendimento dos critérios de aceite antes de encerrar as Issues, que continuam abertas.
4. Conferir `CONTEXTO.md`/`README.md` e `docs/SPEC.md`/`docs/API.md` já integrados, harmonizando o contexto com decisões da equipe e mantendo contratos ainda não aprovados como propostas.
5. Verificar separadamente se há Project configurado, responsáveis disponíveis e movimentação real; não confundir Issues abertas com tarefas concluídas.
6. Para novas alterações, abrir PRs reais e cumprir a revisão independente prevista na ruleset. Refinamentos substantivos da SPEC exigem justificativa e rastreabilidade, não retoques de fachada.
7. Conferir tudo pelo link do próprio repositório que será avaliado: branches, proteção, Project, Issues, PRs, README, SPEC e ADRs.

### 16–30/11: construir, integrar e validar o MVP

1. Selecionar a variante mais simples de backend Java compatível com a equipe; registrar a decisão com motivo e instruções de execução.
2. Ajustar SQL para preço, disponibilidade e datas quando necessário; cadastrar farmácias fictícias, medicamentos e ofertas de demonstração, incluindo **ofertas indisponíveis** e coordenadas de farmácias.
3. Implementar busca e seleção de medicamento, consulta de ofertas e cálculo de menor preço/média/economia/ranking com testes.
4. Integrar frontend e backend mantendo layout; retirar autenticação do caminho principal sem causar links quebrados.
5. Implementar CEPs de teste com coordenadas mapeadas, consentimento do GPS e distância em linha reta; tratar ausência de localização sem bloquear preço.
6. Validar casos críticos, revisar PRs, registrar configurações de execução e garantir demonstração de ponta a ponta.

## 14. Pendências reais para a SPEC e execução (não bloqueiam este contexto)

1. **Disponibilidade da equipe:** confirmar integrantes responsáveis pelas Issues e revisões até 30/11, sem presumir participação; GitHub de Everton é `@MrEve3`.
2. **Permissões e revisões:** a organização GitHub e a ruleset já existem; conferir administração delegada por integrante, quem pode revisar, e se a ruleset permanece ativa após ajustes futuros.
3. **Base de testes geográfica:** escolher os **CEPs concretos do Gama/arredores** e suas coordenadas; documentar a origem dos pontos e criar uma resposta clara a CEP não mapeado. A abordagem (mapeamento local) já está decidida.
4. **Detalhes de persistência:** especificar disponibilidade, data de atualização e regras de validação no SQL, incluindo como uma oferta indisponível será distinguida visualmente.
5. **Regras técnicas:** aprovar/revisar propostas efetivas da SPEC v1.1 e API, em especial regras de preço, histórico, desempate e persistência. Documentar não equivale a implementar.
6. **Stack decidida em 23/11:** HTML/CSS/JavaScript + Java 21 + Spring Boot + Spring JDBC + Maven + MySQL; Chart.js poderá atender a U09 em JS puro. ADRs 001/004 refletem a escolha, ADR 006 registra a não adoção de React no MVP. Revisão humana dos PRs pendente.
7. **Evidência de colaboração:** PR #9 revisado por `@tainayyxy` e integrado à `main` em 16/11. Issues #2–#4 ainda precisam de validação/encerramento; novas Issues não são prova de código concluído.

8. **Apostila e submissão:** conferir com o professor as exigências do documento `DocumentoRomes.pdf` sobre agente configurado, Docker, harness, evidências e PDF único de submissão. Esses artefatos não foram implementados na etapa de produção dos Markdown.

## 15. Referências técnicas para governança GitHub

- Docs GitHub (permissões em repositório pessoal; referência histórica): https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/permission-levels-for-a-personal-account-repository
- Docs GitHub (papéis em repositórios de organização): https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/repository-roles-for-an-organization
- Issue de 2026 relatando comportamento divergente da API sobre admin em repositórios pessoais: https://github.com/github/docs/issues/45537

## Observação editorial histórica de 12/11/2026

Esta atualização **não altera decisões de produto**. Corrige informações factuais sobre proprietário, branches, proteção, **Issues #2–#4, PRs #5–#7**, estrutura documental, SQL e implementação. Em 12/11/2026, os PRs #5–#7 já foram integrados à `develop`, mas as Issues correspondentes ainda estavam abertas. Publicar documentação não demonstra execução de funcionalidades nem aprovação automática de propostas técnicas. As datas de entrega são as relatadas pela equipe, não certificações de aceite.

## Atualização de decisões e riscos — 16/11/2026 (registro histórico, superado onde houver decisões de 23/11)

- **Entrega final confirmada:** 30/11/2026; a antiga previsão de 19/11 foi corrigida. A etapa documental de 12/11 permanece histórico real.
- **Equipe:** Everton usa `@MrEve3`. A atribuição de Issues depende de conversa com a equipe.
- **Arquitetura-alvo:** React + JavaScript + Vite, reaproveitando CSS; Java 21 + Spring Boot + Spring Web + Spring JDBC + Maven; MySQL; Chart.js para gráfico histórico e JUnit/Vitest planejados. Escolha da coordenação submetida à equipe em PR; **não implementada**.
- **Novo escopo:** histórico fictício por oferta U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19); auditoria e correção do frontend U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20), dependendo de registrar as observações **exatas** do professor. As decisões estão refinadas em SPEC v1.1/ADRs, mas a implementação exige código e testes.
- **GitHub:** PR #9 integrado à `main`, Issues U01–U08 = #10–#17, atualização documental #18. Não atribuir trabalho nem alegar testes inexistentes.

## 16. Materiais de referência

- `DOC.PharmaFind.pdf`: Documento de Visão do Produto (38 páginas), especialmente seções 4, 10, 14, 16, 17, 19, 22, 26 e 27.
- `DocumentoRomes.pdf`: roteiro de entrega e governança por Issue, PR, SPEC, agente e testes.
- `SDD.pdf`: visão geral da abordagem Spec-Driven Development.
- [ADR 006](docs/ADR/006-frontend-react.md): registro histórico da proposta React/Vite, não adotada no MVP em 23/11. [AGENTS.md](AGENTS.md): orientações para agentes de IA.
- GitHub: https://github.com/PharmaFind/PharmaFind (repositório atual, observado em 12/11/2026; acesso anterior `tainayyxy/PharmaFind`).

## Decisões e acompanhamento — 23/11/2026

- **Stack aprovada pela coordenação:** HTML/CSS/JavaScript no frontend; Java 21 + Spring Boot + Spring Web + Spring JDBC + Maven no backend; MySQL. React/Vite não faz parte desta entrega; ver ADRs 001, 004 e 006. A revisão humana do PR formalizará a alteração no repositório.
- **Escopo não congelado:** U09 (histórico/gráfico) e U10 permanecem no planejamento; a coordenação autorizou considerar ampliação, mas toda nova funcionalidade exige Issue, análise de impacto em prazo/dependências e alinhamento com PO/equipe. A busca/seleção/comparação integrada continua sendo critério central.
- **Distribuição de trabalho:** responsáveis das U02–U07 aguardam validação; não atribuir tarefas por inferência. U08/U10 têm assignees já registrados no GitHub.
- **Governança:** PR #29 integrado para sincronização excepcional `main` → `develop`; PR #31 também integrado, porém a checagem de origem/destino **ainda não é obrigatória na ruleset** até ser testada e configurada. Issue #30 acompanha prioridades. A aprovação de PR não comprova testes de aplicação.
- **Correções da avaliação do professor:** banco da U01 atende com ressalvas e requer restrições adicionais; front-end não está integrado à API. O relatório não atribuiu nota. Os registros anteriores datados neste arquivo são históricos, não uma descrição do estado técnico em 23/11.

## Correção complementar de persistência — U01/#33

Escopo autorizado pelo solicitante em 23/11/2026: apresentação comercial própria e identidade
única (nome/dosagem/apresentação), preço histórico positivo e um ponto por oferta/dia, CEP válido
ou ausente e coordenadas ambas válidas ou ambas ausentes. A implementação preserva IDs e dados
válidos, sem criar pontos históricos nem implementar backend/frontend.
O MVP não possui autenticação nem cadastro; a instalação nova não cria USUARIO.
Bancos anteriores mantêm a tabela até inspeção de registros/dependências, backup recuperável
e remoção controlada aprovada por alvo, independente das etapas 003a/003b.
As menções anteriores às cinco tabelas e à ausência de apresentação são registros históricos.
Os PRs #29/#32 estão integrados; esta alteração complementar exige revisão humana própria.
Testes desta correção e limites de ambiente em database/tests/RESULTADOS.md.

## Validação local da fundação U02 — 26/11/2026

Na branch `feature/11-backend-java-persistencia`, o merge `21eec81` de `develop` em
`53c7ae2` combina os PRs #34/#36. Compilação, 19 testes com MySQL habilitado,
empacotamento e inicialização do JAR passaram. A integração usou somente `pharmafind_test`
em instância temporária isolada; CT17 foi revertido e os hashes dos dados foram preservados.
Evidências em [backend/tests/RESULTADOS.md](backend/tests/RESULTADOS.md). Os registros anteriores
datados permanecem históricos. Não há endpoints de negócio, motor de preços ou frontend integrado.
Reprodução por outro integrante e revisão humana independente continuam pendentes.
