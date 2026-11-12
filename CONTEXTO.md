# PharmaFind — CONTEXTO DO PROJETO

> **Base 1.0 (11/11/2026) | Atualização factual do GitHub: 12/11/2026 | Contexto consolidado**
> **Fontes:** Documento de Visão do PharmaFind (`DOC.PharmaFind.pdf`); materiais da disciplina (`DocumentoRomes.pdf` e `SDD.pdf`); estado do repositório observado em 11–12/11/2026; inspeção direta da organização `PharmaFind/PharmaFind` em 12/11/2026; decisões do grupo informadas à equipe.
> **Legenda:** `[CONFIRMADO]` decisão expressa do grupo; `[DOCUMENTO]` conteúdo do Documento de Visão; `[OBSERVADO]` estado verificado no código/GitHub, sujeito a mudanças; `[PROPOSTA]` orientação de implementação ainda não aprovada; `[PENDENTE]` detalhe que precisa ser definido; `[ATENÇÃO]` risco/restrição; `[AÇÃO]` próxima providência.
>
> **Finalidade:** oferecer a membros da equipe e agentes de IA uma referência comum sobre **o que o PharmaFind é, o que deve fazer, o que já existe, o que fica fora do escopo e como o desenvolvimento será organizado**. Este contexto não substitui a especificação técnica verificável (`docs/SPEC.md`), os testes nem o código.
>
> **Regra de interpretação:** decisões `[CONFIRMADO]` prevalecem sobre descrições genéricas/provisórias do PDF, especialmente na stack e na arquitetura. Em conflitos não explicitamente resolvidos, registrar a dúvida em vez de inventar uma decisão.

## Resumo executivo das decisões

- **Entrega de 12/11/2026:** GitHub organizado, governança, tarefas, colaboração real e documentação técnica; avaliação diretamente pelo repositório.
- **Entrega de 19/11/2026:** versão funcional, com pesquisa, seleção do medicamento, ofertas, processamento de preços e localização opcional como alvo.
- **Tecnologias base:** HTML, CSS, JavaScript, Java e MySQL; bibliotecas/frameworks podem ser escolhidos para simplificar.
- **Base de demonstração:** **farmácias fictícias e preços fictícios**, gravados em MySQL, representando a região do **Gama e arredores**.
- **Fluxo de pesquisa:** primeiro selecionar o medicamento; depois consultar e comparar as ofertas daquele medicamento.
- **Localização:** **opcional**; distância **aproximada em linha reta**, quando houver coordenadas. A primeira versão usará **CEPs de teste da região e coordenadas previamente cadastradas**. GPS do navegador depende de consentimento.
- **Ofertas indisponíveis:** **aparecem identificadas como indisponíveis**, mas **não participam da média, menor preço, economia, ranking de ofertas disponíveis nem do destaque de melhor preço**.
- **Processamento:** menor preço, média aritmética, economia em relação à oferta mais cara válida e ranking por preço. Sem score combinado preço/distância e sem histórico analítico nesta entrega.
- **Interface:** **manter o visual existente e adaptar as páginas**, retirando login e cadastro do fluxo/MVP.
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
- [CONFIRMADO] **19/11/2026 (quinta-feira):** entrega final da etapa de desenvolvimento do sistema.
- [DOCUMENTO/CHECKLIST INFORMADO] Critérios relevantes da entrega intermediária incluem `main`, `develop` e `feature/*` usadas em trabalho real; governança por PR e revisão; Issues e Project com movimento genuíno; README e ADRs; `docs/SPEC.md` com RFs, RNFs verificáveis e RNs numeradas; exemplos literais de contratos JSON/status/erro; decomposição por unidades ligada às Issues; refinamento real da SPEC, quando ocorrido, registrado por PR.
- [ATENÇÃO] **Não é possível afirmar que nunca houve commit direto na `main` em todo o histórico:** já há commits antigos nessa branch. Preservar o histórico, documentar a data de adoção das novas regras e impedir novos pushes diretos após a proteção; **não reescrever commits para criar aparência de conformidade**.
- [CONFIRMADO] Para 12/11, **não priorizar automações sofisticadas**; foco na organização, documentação e colaboração. Agente de IA, Docker e harness de testes podem ser tratados conforme exigências posteriores e viabilidade.
- [ATENÇÃO] Apenas parte da equipe deve conseguir participar em 11–12/11. Ajustar tarefas e PRs à disponibilidade real, sem falsificar aprovações nem atribuir trabalho inexistente.

## 3. Estado atual da implementação (verificação de 12/11/2026)

- [OBSERVADO] **Repositório oficial atual:** https://github.com/PharmaFind/PharmaFind, pertencente à organização GitHub **`PharmaFind`**. A referência antiga `tainayyxy/PharmaFind` descrevia a propriedade anterior e não deve ser usada como URL oficial.
- [OBSERVADO] A branch padrão é `main`. Existem `develop` e `feature/estrutura-documentacao`.
- [OBSERVADO] A ruleset ativa **“Protecao main e develop”** se aplica a `main` e `develop` e exige PR, **uma aprovação**, resolução das conversas de revisão, bloqueio de exclusão e de atualização não fast-forward. Sua presença foi verificada na API do GitHub; não se afirma que os testes automatizados já sejam exigidos por ela.
- [OBSERVADO] O **PR #1**, “chore: estrutura inicial de documentação”, foi aprovado por `Lucasdsantosb` e integrado à `develop` em 12/11/2026. Ele criou **dez arquivos vazios intencionalmente**: `README.md`, `CONTEXTO.md`, `CONTRIBUTING.md`, `docs/SPEC.md`, `docs/API.md`, dois ADRs e três templates. Isso comprova somente a criação da estrutura, não a conclusão da documentação.
- [OBSERVADO] A `main` conserva o código original; a `develop` contém esse código e a estrutura documental. No momento da consulta, não havia Issues identificadas por busca no repositório. O Project não foi auditado.
- [OBSERVADO] Pastas de implementação: `frontend/` (HTML/CSS/JavaScript) e `database/PharmaFindDB.sql` (estrutura das tabelas MySQL), além de `.vscode/settings.json`.
- [OBSERVADO] `frontend/consulta.js` usa **dez medicamentos demonstrativos fixados no próprio JavaScript**; sua tela atualmente lista cartões de medicamento/oferta, com filtros locais, sem a seleção seguida de comparação de várias ofertas do mesmo medicamento. `frontend/index.html` ainda inclui links de login e cadastro.
- [OBSERVADO] Não há backend Java, configuração de execução Java, dados iniciais SQL, testes automatizados ou integração efetiva do front-end ao MySQL no conteúdo inspecionado da `develop`.
- [OBSERVADO] `database/PharmaFindDB.sql` define `USUARIO`, `FARMACIA`, `MEDICAMENTO`, `MEDICAMENTO_FARMACIA` e `HISTORICO_PRECO`. A associação de ofertas possui preço decimal e unicidade medicamento/farmácia, mas **não contém `disponibilidade` nem `data_atualizacao`**. O script não cria o database nem insere dados demonstrativos.
- [CONFIRMADO] **Não existe código mais recente fora do GitHub que deva ser integrado:** o repositório é o ponto de partida real da continuação.
- [AÇÃO] Preservar o visual existente; implementar o novo fluxo por Issue e PR; tirar login/cadastro da navegação ativa sem atribuir a mudança a uma implementação já feita.

## 4. Stack e escolha de ferramentas

- [CONFIRMADO] **Núcleo tecnológico:** HTML, CSS, JavaScript, Java e MySQL.
- [CONFIRMADO] **Frameworks e bibliotecas são permitidos e bem-vindos** quando simplificarem o desenvolvimento. As tecnologias não precisam ser usadas de forma “pura”.
- [CONFIRMADO] A seção de stack/arquitetura do Documento de Visão foi preenchida provisoriamente; **não é uma decisão técnica vinculante**.
- [PROPOSTA] Manter o front-end atual HTML/CSS/JS, usar um backend Java simples de consumir pela interface, Maven para dependências, MySQL para persistência e JUnit para testes. Avaliar Spring Boot como opção de agilidade, sem fixar framework/versões até validação prática da equipe. O PDF que cita Spring Boot/MVC não obriga essa implementação.
- [DIRETRIZ] Não adotar React, microsserviços ou outras tecnologias complexas apenas por parecerem mais profissionais. Minimizar retrabalho e otimizar o que a equipe consegue configurar, entender, executar e testar até 19/11.

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
- [PENDENTE] Selecionar os CEPs de teste concretos e suas coordenadas, definir a origem/documentação dos valores e descrever a mensagem para CEPs fora da base; incluir casos de teste de autorização negada e coordenadas ausentes.
- [ATENÇÃO] **ViaCEP não fornece latitude e longitude**; uma consulta de CEP não produz automaticamente distância. Serviço externo de geocodificação para todos os CEPs pertence a evolução futura, se necessário.

## 7. Base de dados, ofertas e disponibilidade

- [CONFIRMADO] **Usar farmácias fictícias e preços fictícios**, com dados persistidos de verdade no **MySQL**. A região representada pela demonstração é o **Gama e arredores**.
- [CONFIRMADO] Atualizações de preços e disponibilidade na entrega atual serão executadas **diretamente no MySQL pela equipe**, sem interface administrativa.
- [DOCUMENTO] Cada oferta corresponde a um medicamento específico e a uma farmácia específica; deve possuir preço válido e permitir associar sua disponibilidade. Medicamentos de dosagens/apresentações diferentes não devem ter ofertas misturadas.
- [CONFIRMADO] **Ofertas indisponíveis devem permanecer visíveis**, com identificação explícita como “Indisponível”, para dar transparência ao usuário. Elas **não são elegíveis para menor preço, média, economia potencial, ranking de preços disponíveis nem indicação de melhor oferta**.
- [CONFIRMADO] Quando não houver ofertas disponíveis para o medicamento, não calcular média/economia fictícias; mostrar estado vazio/aviso claro, podendo listar ofertas indisponíveis separadamente.
- [DOCUMENTO] Informar nome, endereço e horário da farmácia quando cadastrados, além de aviso de que valores podem mudar.
- [AÇÃO] O script SQL atual (`database/PharmaFindDB.sql`) contém medicamentos, farmácias, associação de ofertas e histórico, mas **precisa ser revisado** para acomodar disponibilidade e data de atualização coerentes com o escopo; não afirmar que isso já está implementado.
- [CONFIRMADO] **Modelo de negócio futuro:** farmácias pagariam para participar e seriam responsáveis pelo cadastro e pela atualização de suas ofertas. Não implementar login/painel de farmácias, cobranças ou integração de preços reais até 19/11.
- [PENDENTE] Definir na SPEC valores e validações dos campos de disponibilidade/data de atualização (ex.: booleano, data e regras de ausência), com migração SQL compatível.

## 8. Processamento e critérios de comparação

- [CONFIRMADO] Os cálculos usam **apenas ofertas disponíveis e válidas do medicamento exato selecionado**. Ofertas indisponíveis permanecem identificadas na interface, mas são excluídas dos cálculos.
- [CONFIRMADO] Exibir **menor preço disponível**, **média aritmética** dos preços válidos, **economia potencial** comparando a menor e a maior oferta válida e **ranking de ofertas/farmácias do menor para o maior preço**.
- [PROPOSTA] `media = soma(precos_validos) / quantidade_de_ofertas_validas`; `economia_potencial = maior_preco_valido - menor_preco_valido`. Para uma única oferta válida, economia = R$ 0,00; para nenhuma, não apresentar números calculados sem base.
- [CONFIRMADO] **Não adicionar score que combine preço e distância** nesta etapa. Distância pode ser ordenada separadamente quando disponível.
- [CONFIRMADO] Histórico de preços, gráficos, variações ao longo do tempo e integrações reais ficam fora do foco até 19/11; podem ser melhorias posteriores.
- [PENDENTE] Especificar desempate de preços, precisão/arredondamento de valores monetários e formato de números nos testes da `docs/SPEC.md`.

## 9. Escopo do MVP (entrega até 19/11)

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
- Histórico analítico de preços, gráficos de evolução e score composto preço + distância.
- Rotas pelas ruas ou cobertura automática de todos os CEPs do Brasil.

**Princípio de priorização:** deixar o fluxo **pesquisar → selecionar → comparar → visualizar distância opcional** demonstrável de ponta a ponta antes de ampliar o escopo.

## 10. Equipe, papéis e colaboração

- [CONFIRMADO] A divisão geral do Documento de Visão permanece:
  - **Lucas Marques (`@lucasmarques07`)** — Scrum Master; organização/governança do GitHub e apoio ao banco de dados.
  - **Tainá do Amaral (`@tainayyxy`)** — desenvolvimento; antiga proprietária na conta pessoal. O repositório agora é da organização `PharmaFind`.
  - **Everton Gabriel (`@MrEve3`, a confirmar)** — desenvolvimento.
  - **Lucas dos Santos Bezerra (`@Lucasdsantosb`)** — desenvolvimento.
  - **Júlia Gabrielle** — analista/engenheira de requisitos; validação de requisitos e documentação.
  - **Roberto Carlos** — Product Owner; prioridades, esclarecimentos e aceite do produto.
- [CONFIRMADO, CONFORME CONTEXTO DA EQUIPE] Os **quatro primeiros** participam do desenvolvimento no GitHub; conferir o acesso individual atual à organização antes de atribuir tarefas. **Júlia e Roberto não atuam no desenvolvimento via GitHub nesta etapa**, embora continuem com responsabilidades de requisitos/produto fora do repositório.
- [CONFIRMADO] **Apenas alguns desenvolvedores conseguem colaborar no período imediato 11–12/11**. **Ainda não foi informado quais**, nem seus horários. Não planejar quatro PRs simultâneos ou aprovações de pessoas indisponíveis como condição para a entrega.
- [CONFIRMADO] Lucas Marques atua na governança do GitHub como Scrum Master. [OBSERVADO] O repositório já está na organização `PharmaFind`, com regras ativas sobre as branches principais; a antiga pendência de transferir o repositório pessoal foi superada. As permissões de cada membro e a administração organizacional ainda devem ser geridas pela equipe.
- [PENDENTE] Confirmar se o username do Everton é **`@MrEve3`** (esse autor aparece em commits; a mensagem combinou `MrEve3Everton`) e **quais integrantes estarão disponíveis para PR/revisão até 12/11**.
- [CONFIRMADO, INFORMADO PELA EQUIPE] O professor verificará o repositório. [DOCUMENTO] A apostila `DocumentoRomes.pdf`, p. 25–26, **também descreve uma submissão em PDF único no Moodle** e evidências de ambiente, agente e testes. [PENDENTE] Confirmar se essa orientação integral se aplica à data e turma atuais; não ignorar a divergência.

## 11. Governança GitHub e documentação SDD

### Entrega intermediária — 12/11/2026

- [CONFIRMADO/OBSERVADO] **Branches:** `main` como versão estável, `develop` como integração e `feature/<id-issue>-<descricao>` para novos trabalhos. PRs de `feature/*` para `develop`; PR de integração `develop` para `main` quando houver entrega estável. Já existe `feature/estrutura-documentacao` como branch histórica sem ID de Issue.
- [OBSERVADO] **Proteção ativa:** uma ruleset cobre `main` e `develop`, exige PR com pelo menos **uma aprovação**, resolve conversas de revisão e impede exclusões e atualizações não fast-forward. Manter a configuração e não adulterar os commits antigos de `main`.
- [PROPOSTA] **Planejamento:** Issues reais com descrição, responsáveis **disponíveis**, critérios de aceite e dependências; GitHub Project em `Backlog`, `Em andamento`, `Em revisão`, `Concluído`, com movimentação verdadeira e rastreável.
- [OBSERVADO/DIRETRIZ] O PR #1 foi aprovado e integrado à `develop` com uma aprovação real. Novos PRs devem trazer mudanças legítimas e revisão de outro integrante; não inventar comentários, commits, aprovadores, refinamentos ou atividade.
- [PROPOSTA] **README:** visão do produto, objetivos, estado real de implementação, stack confirmada/proposta claramente diferenciadas, instruções de executar **o que já funciona** e links para SPEC, ADRs, Issues e Project.
- [PROPOSTA] **`docs/SPEC.md`:** problema, requisitos funcionais, não funcionais mensuráveis, regras de negócio numeradas, contratos JSON de entrada/saída com status HTTP e formato de erro, critérios verificáveis e decomposição em unidades vinculáveis às Issues. Endpoints e contratos publicados antes de existir backend devem ser rotulados **propostos**.
- [PROPOSTA] **ADRs sintéticos** para decisões técnicas de fato tomadas. Uma revisão `v1.0 → v1.1` só conta como evolução quando houver **mudança substantiva justificada** e PR que a registre; não criar diferença cosmética para fabricar evidência.
- [ATENÇÃO] `main` tem commits diretos históricos, anteriores à governança atual; o requisito de “nenhum commit direto em todo o histórico” não é recuperável sem manipular o histórico. Reconhecer a transição e preservar os registros.

### Desenvolvimento — até 19/11/2026

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

### 11–12/11: organizar o GitHub sem pressupor disponibilidade de todos

1. Confirmar **quem está disponível de fato** e quem pode fazer a revisão de ao menos um PR. Se só uma pessoa estiver online, não fingir uma revisão; antecipar documentação/Issues e registrar o trabalho real.
2. Repositório já transferido à organização; Lucas coordena a governança e os administradores mantêm as regras. Não reabrir como tarefa uma migração que já aconteceu.
3. `develop`, ruleset, PR #1 e arquivos vazios já criados: **preencher os documentos** em nova `feature/*`, atualizar templates e testar o fluxo, sem alegar que os arquivos estão concluídos antes do merge.
4. Produzir a SPEC inicial a partir deste contexto, com contratos propostos, RF/RNF/RN, unidades, critérios de aceite e ligações para as Issues.
5. Montar Project, abrir Issues reais, atribuir **somente tarefas efetivamente assumidas** e movimentá-las conforme o trabalho.
6. Fazer PRs com alterações reais e revisão de outro membro, **se houver membro disponível**. Registrar aprimoramento efetivo de SPEC em PR, sem alterações de fachada.
7. Conferir tudo pelo link do próprio repositório que será avaliado: branches, proteção, Project, Issues, PRs, README, SPEC e ADRs.

### 13–19/11: construir o fluxo central

1. Selecionar a variante mais simples de backend Java compatível com a equipe; registrar a decisão com motivo e instruções de execução.
2. Ajustar SQL para preço, disponibilidade e datas quando necessário; cadastrar farmácias fictícias, medicamentos e ofertas de demonstração, incluindo **ofertas indisponíveis** e coordenadas de farmácias.
3. Implementar busca e seleção de medicamento, consulta de ofertas e cálculo de menor preço/média/economia/ranking com testes.
4. Integrar frontend e backend mantendo layout; retirar autenticação do caminho principal sem causar links quebrados.
5. Implementar CEPs de teste com coordenadas mapeadas, consentimento do GPS e distância em linha reta; tratar ausência de localização sem bloquear preço.
6. Validar casos críticos, revisar PRs, registrar configurações de execução e garantir demonstração de ponta a ponta.

## 14. Pendências reais para a SPEC e execução (não bloqueiam este contexto)

1. **Disponibilidade da equipe:** identificar quais membros podem trabalhar e revisar PRs em **12/11** e até 19/11, sem assumir que todos participarão; confirmar o username exato do Everton (`@MrEve3`, provável).
2. **Permissões e revisões:** a organização GitHub e a ruleset já existem; conferir administração delegada por integrante, quem pode revisar, e se a ruleset permanece ativa após ajustes futuros.
3. **Base de testes geográfica:** escolher os **CEPs concretos do Gama/arredores** e suas coordenadas; documentar a origem dos pontos e criar uma resposta clara a CEP não mapeado. A abordagem (mapeamento local) já está decidida.
4. **Detalhes de persistência:** especificar disponibilidade, data de atualização e regras de validação no SQL, incluindo como uma oferta indisponível será distinguida visualmente.
5. **Regras técnicas:** fixar na `docs/SPEC.md` empate, arredondamento monetário, ausência de ofertas elegíveis, endpoints/contratos e erros.
6. **Escolha da implementação Java:** avaliar alternativa simples e documentar decisão (Spring Boot/Maven/JUnit são proposta, não requisitos confirmados).
7. **Evidência de colaboração:** o PR #1 possui aprovação real; não inferir que isso cumpre sozinho todas as exigências. Evolução `SPEC v1.0 → v1.1` exige refinamento verdadeiro, motivo e PR.

8. **Apostila e submissão:** conferir com o professor as exigências do documento `DocumentoRomes.pdf` sobre agente configurado, Docker, harness, evidências e PDF único de submissão. Esses artefatos não foram implementados na etapa de produção dos Markdown.

## 15. Referências técnicas para governança GitHub

- Docs GitHub (permissões em repositório pessoal; referência histórica): https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/permission-levels-for-a-personal-account-repository
- Docs GitHub (papéis em repositórios de organização): https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/repository-roles-for-an-organization
- Issue de 2026 relatando comportamento divergente da API sobre admin em repositórios pessoais: https://github.com/github/docs/issues/45537

## Observação editorial de 12/11/2026

Esta atualização **não altera decisões de produto**. Corrige informações factuais desatualizadas sobre proprietário, branches, proteção, PR, estrutura documental, SQL e implementação. Contratos de API e escolhas técnicas permanecem **propostas**, até revisão da equipe. As datas de entrega são as relatadas pela equipe, não certificações de aceite.

## 16. Materiais de referência

- `DOC.PharmaFind.pdf`: Documento de Visão do Produto (38 páginas), especialmente seções 4, 10, 14, 16, 17, 19, 22, 26 e 27.
- `DocumentoRomes.pdf`: roteiro de entrega e governança por Issue, PR, SPEC, agente e testes.
- `SDD.pdf`: visão geral da abordagem Spec-Driven Development.
- GitHub: https://github.com/PharmaFind/PharmaFind (repositório atual, observado em 12/11/2026; acesso anterior `tainayyxy/PharmaFind`).