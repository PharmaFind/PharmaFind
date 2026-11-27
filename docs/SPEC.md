# PharmaFind — Especificação Técnica (SPEC v1.1)

**Estado:** SPEC v1.1 anterior consolidada na Issue [#18](https://github.com/PharmaFind/PharmaFind/issues/18); **atualização de 23/11/2026** registra a stack aceita pela coordenação e a não adoção de React no MVP, sob revisão humana da [Issue #30](https://github.com/PharmaFind/PharmaFind/issues/30). Nenhum contrato proposto ou código é automaticamente implementado.  
**Data de elaboração da v1.0:** 12/11/2026. **Refinamento v1.1:** 16/11/2026. **Entrega final informada:** 30/11/2026.  
**Fontes:** [`CONTEXTO.md`](../CONTEXTO.md) (prioridade para decisões recentes), Documento de Visão do Produto (RF01–RF30, RNF01–RNF42, RN01–RN05) e apostilas de SDD do professor Romes.  
**Documentos de Visão de origem:** [histórico e versões em Markdown](visao/README.md) (registros históricos, sem substituir esta SPEC).
**Contratos detalhados:** [`docs/API.md`](API.md). **Decisões técnicas:** [`docs/ADR/`](ADR/).

> **Leitura obrigatória:** esta SPEC descreve o **comportamento a implementar**, não a implementação atual. O código observado em `develop` mantém dados fixos em JavaScript, não possui backend Java, não consulta o MySQL e não oferece ainda as estatísticas descritas. Requisitos originários do Documento de Visão preservam seus IDs; novos requisitos derivados de decisões do `CONTEXTO.md` recebem IDs a partir de RF31. As definições técnicas sinalizadas como **[PROPOSTA]** exigem validação da equipe.

## 1. Problema, objetivo e fronteira

### Problema

Consumidores precisam consultar farmácias separadamente para descobrir quanto custa um medicamento e onde há ofertas próximas. A tarefa é dispersa e dificulta comparação objetiva.

### Objetivo verificável do MVP

Permitir que uma pessoa **pesquise medicamentos por nome, selecione um registro exato e visualize as ofertas de farmácias fictícias** com preços/estados de disponibilidade, cálculo de menor preço/média/economia e distância aproximada opcional, em interface responsiva.

### Dentro do escopo

- Medicamentos identificados por ID, com nome, dosagem e outros atributos disponíveis no cadastro.
- Busca por texto completo ou parcial, seguida obrigatoriamente de seleção do medicamento específico.
- Leitura de ofertas demonstrativas persistidas em **MySQL**, contendo medicamento, farmácia, preço e estado de disponibilidade.
- Ofertas indisponíveis visíveis e sinalizadas, mas excluídas dos indicadores econômicos.
- Menor preço, média aritmética, economia potencial (`maior preço válido − menor preço válido`) e ranking crescente das ofertas disponíveis.
- Localização **optativa**: coordenadas fornecidas pelo navegador com permissão ou **CEPs de teste do Gama/região previamente mapeados**, com distância em linha reta calculável.
- Interface HTML/CSS/JavaScript existente reutilizada/adaptada, consumindo a API Java sem migração React/Vite; estados de erro e vazios, sem necessidade de conta.
- Histórico temporal **fictício** por medicamento **e farmácia**, com gráfico de linha e variações calculáveis (U09, #19).
- Auditoria e correções do frontend conforme observações **reais** do professor, ainda a registrar e validar (U10, #20).

### Fora do escopo até 30/11/2026

Autenticação/cadastro (inclusive telas legadas como parte do fluxo ativo), painel de farmácias, pagamentos, reservas/pedidos, recomendação clínica, integração automática de preços reais, previsões de preços, alertas, favoritos, histórico de pesquisa, modo escuro, comparação entre múltiplos medicamentos, score preço/distância, rotas e geocodificação universal de CEP. O **histórico analítico com gráfico** foi acrescentado ao planejamento pela decisão de 16/11/2026 (U09, Issue #19); a existência de tabela SQL não demonstra que a funcionalidade já funciona. A revisão integral do frontend e das observações do professor é U10 (Issue #20).

### Premissas e estado atual

| Item | Natureza | Observação |
|---|---|---|
| HTML, CSS, JavaScript; Java e MySQL | **[CONFIRMADO]** | Linguagens e base persistente definidas pela equipe. |
| Dados de farmácias e preços fictícios, região Gama e arredores | **[CONFIRMADO]** | Não alegar farmácias ou preços comerciais reais. |
| Layout do front-end existente | **[CONFIRMADO]** | Manter identidade e adaptar navegação/consulta. |
| Stack-alvo | **[APROVADA PELA COORDENAÇÃO EM 23/11 / PR EM REVISÃO]** | HTML + CSS + JavaScript; Java 21 + Spring Boot + Spring Web + Spring JDBC + Maven; MySQL. Chart.js pode atender a U09 em JS puro. ADR 001/004 aceitos para implementação; ADR 006 registra React não adotado no MVP. **Não implementada de ponta a ponta.** |
| Dados de disponibilidade e data da oferta | **[IMPLEMENTADO NESTA BRANCH]** | Campos, validações, migração em duas etapas e seed de 6 medicamentos/4 farmácias/12 ofertas. Suíte ampliada, limpeza protegida e inicialização/reaplicação passaram no MySQL 8.0.45 ([evidência](../database/tests/RESULTADOS.md)); revisão humana pendente. |
| CEPs e respectivas coordenadas | **[MAPA DE TESTE VERSIONADO]** | Três CEPs reais em `database/seeds/ceps-teste.json`, com pontos representativos e origem documentada. Dados não certificam geocodificação postal; integração depende da U05/U02. |
| API HTTP v1 documentada aqui | **[PROPOSTA]** | Os três contratos existentes e o novo contrato de leitura de histórico U09 aguardam validação; não há endpoints implementados. |

## 2. Requisitos funcionais (RF)

### 2.1 IDs preservados do Documento de Visão

**Situação:** todos a seguir são **requisitos-alvo**, não evidências de funcionalidade pronta. RF15–RF19 só operam quando a localização é conhecida; a busca sem localização deve continuar funcional.

| ID | Comportamento requerido | Esclarecimento para o MVP |
|---|---|---|
| **RF01** | Permitir pesquisar medicamento pelo nome. | Busca no catálogo da base de demonstração. |
| **RF02** | Aceitar nome completo ou parcial. | Correspondência de texto; regras de normalização em seção 6. |
| **RF03** | Permitir selecionar medicamento entre resultados. | Seleção obrigatória **antes** das ofertas. |
| **RF04** | Exibir dados básicos do medicamento selecionado. | Nome, dosagem e outros campos cadastrados. |
| **RF05** | Listar farmácias com oferta cadastrada ao medicamento. | Inclui ofertas indisponíveis identificadas. |
| **RF06** | Exibir preço por farmácia. | Preço cadastrado e indicação de atualização. |
| **RF07** | Comparar ofertas do **mesmo medicamento**. | Comparar pelo ID exato, sem misturar dosagens. |
| **RF08** | Ordenar ofertas do menor para o maior preço. | Ranking econômico das **disponíveis válidas**. |
| **RF09** | Destacar o menor preço entre ofertas válidas. | Desconsiderar indisponíveis. |
| **RF10** | Permitir informar CEP. | Sem tornar CEP obrigatório. |
| **RF11** | Validar formato do CEP antes do uso. | Oito dígitos brasileiros; CEP mapeado é questão distinta. |
| **RF12** | Solicitar autorização antes de usar geolocalização. | Permissão do navegador e ação explícita. |
| **RF13** | Usar geolocalização só após autorização. | Sem leitura automática ao entrar na página. |
| **RF14** | Permitir CEP quando GPS não estiver disponível/autorizado. | Também permitir seguir **sem localização**. |
| **RF15** | Identificar farmácias próximas à posição informada. | Proximidade por linha reta, não rota de trânsito. |
| **RF16** | Calcular distância aproximada usuário–farmácia. | Coordenadas são necessárias nos dois lados. |
| **RF17** | Exibir distância aproximada nos resultados. | Omitir/indicar não disponível se não calculável. |
| **RF18** | Permitir ordenar por menor distância. | Só quando há coordenadas suficientes. |
| **RF19** | Destacar farmácia mais próxima. | Separada do destaque de menor preço. |
| **RF20** | Mostrar nome e endereço da farmácia. | Endereços da demonstração são fictícios. |
| **RF21** | Mostrar horário de funcionamento, quando cadastrado. | Não inferir “aberto agora” sem regra e dados adequados. |
| **RF22** | Informar quantidade de ofertas encontradas. | Exibir total cadastrado e, quando útil, total disponível. |
| **RF23** | Mostrar mensagem se nenhuma oferta for encontrada. | Diferenciar de ofertas existentes porém indisponíveis. |
| **RF24** | Permitir nova pesquisa sem reiniciar aplicação. | Reutilizar campo e fluxo. |
| **RF25** | Manter termo pesquisado na tela de resultados. | Se exibido, não confundir com nome do produto selecionado. |
| **RF26** | Armazenar dados de medicamentos para consultas. | Persistência efetiva em MySQL no alvo. |
| **RF27** | Armazenar dados de farmácias e suas coordenadas. | CEP/endereço e coordenadas dos dados fictícios. |
| **RF28** | Relacionar oferta ao medicamento e à farmácia. | Relacionamentos íntegros; oferta de ID específico. |
| **RF29** | Permitir atualizar preço e disponibilidade da oferta. | **Nesta entrega, pela equipe diretamente no MySQL**, sem painel. |
| **RF30** | Informar que dados podem mudar e mostrar data de atualização. | Data apenas quando registrada; nunca fabricar. |

### 2.2 Requisitos derivados de decisões mais recentes do contexto

| ID | Comportamento | Fundamentação | Natureza |
|---|---|---|---|
| **RF31** | Exibir ofertas indisponíveis como “Indisponível” e separá-las visualmente dos resultados elegíveis. | CONTEXTO §§7–9. | **[CONFIRMADO]** |
| **RF32** | Calcular e exibir **menor preço**, **média**, **economia potencial** e **ranking** usando apenas ofertas disponíveis válidas do ID selecionado. | CONTEXTO §8. | **[CONFIRMADO]** |
| **RF33** | Aceitar CEP de teste mapeado para coordenadas e continuar comparando preços quando o CEP não estiver contemplado. | CONTEXTO §§6 e 9. | **[CONFIRMADO]** comportamento; formato de retorno é **[PROPOSTA]**. |
| **RF34** | Quando nenhuma oferta elegível existir, mostrar ausência de preços comparáveis sem apresentar médias ou economia inventadas. | CONTEXTO §§7–9. | **[CONFIRMADO]** |
| **RF35** | Consultar histórico de preços fictícios de uma oferta específica (medicamento + farmácia). | U09; usar IDs exatos e registros persistidos, sem misturar ofertas. |
| **RF36** | Exibir evolução dos preços em gráfico de linha com data e valor. | U09; Chart.js planejado; não gerar pontos artificiais durante cada consulta. |
| **RF37** | Mostrar variação nominal e percentual entre primeiro e último registro cronológico quando possível. | U09; requer dois registros de datas distintas e primeiro preço positivo. |
| **RF38** | Exibir estado de histórico insuficiente/ausente sem inventar tendência ou percentual. | U09; retorno com lista vazia ou dados insuficientes e métricas `null`. |

## 3. Requisitos não funcionais (RNF)

IDs seguem o Documento de Visão. O documento original **salta RNF15**; **não existe texto fornecido para RNF15** e nenhum novo requisito foi inventado sob esse número. Critérios operacionais adicionais nesta seção são propostas para tornar a verificação reproduzível.

| IDs | Exigência original preservada | Verificação esperada |
|---|---|---|
| **RNF01–RNF03** | Responsividade em celular, tablet e desktop; layout adaptável; sem rolagem horizontal desnecessária. | Testar larguras **320, 768 e 1280 px** [PROPOSTA de amostragem] com busca, lista e comparação. |
| **RNF04–RNF07** | Interface simples, consistente, legível e mensagens claras. | Revisão visual/teclado com roteiro de busca, erro e estado vazio. |
| **RNF08** | Páginas principais carregarem em até **3 s** em condições normais no ambiente acadêmico. | Medir com mesmo equipamento/rede, 3 repetições, registrar condições e resultados; definição de “normal” pendente. |
| **RNF09** | Busca na base de testes retornar em até **3 s**. | Fixar massa de teste, rede e hardware [PENDENTE] e medir requisição completa em 3 repetições. |
| **RNF10–RNF14** | HTML semântico, rótulos, teclado, foco visível, `alt` nas imagens informativas. | Percorrer todo fluxo apenas por teclado e revisar DOM/imagens. |
| **RNF16–RNF18** | Compatibilidade com leitores de tela, idioma `pt-BR`, ARIA somente onde necessário. | Conferência semântica e leitura assistiva quando possível; `lang="pt-BR"` nas páginas. |
| **RNF19–RNF21** | Consentimento de GPS, coleta mínima, sem armazenamento permanente desnecessário de posição precisa. | Negar GPS, inspecionar requests/cookies/storage/logs; não persistir coordenadas do visitante. |
| **RNF22** | HTTPS em produção. | Verificar protocolo da publicação **se houver implantação em produção**; não impor ao arquivo HTML local. |
| **RNF23–RNF25** | Validação no servidor, SQL parametrizado, proteção contra XSS. | Casos inválidos/maliciosos de entrada e revisão de consulta/renderização. |
| **RNF26** | Não solicitar CPF/telefone/dados pessoais sem necessidade no MVP. | Verificar telas e contratos públicos. |
| **RNF27–RNF29** | Chaves estrangeiras, IDs únicos e oferta por par válido medicamento/farmácia. | Inspecionar schema e testar FKs/UNIQUE no MySQL. |
| **RNF30** | Preço em tipo monetário com duas casas decimais. | `DECIMAL(10,2)` no SQL; `BigDecimal` em Java é **[PROPOSTA]**. |
| **RNF31** | CEP brasileiro com oito dígitos. | Testar oito dígitos, pontuação opcional normalizada [PROPOSTA], incompleto e inválido. |
| **RNF32–RNF33** | Coordenadas com precisão adequada; data de atualização válida quando adotada. | Inspecionar `DECIMAL(10,7)` atual; executar os testes da migração de `TIMESTAMP`/UTC (U01). |
| **RNF34–RNF35** | Compatibilidade com navegadores modernos e uso móvel em conexão comum. | Testar Chrome/Edge/Firefox/Safari onde disponíveis; registrar cobertura real. |
| **RNF36** | Separação MVC entre interface, controle, negócio e persistência. | **[DECISÃO TÉCNICA DA COORDENAÇÃO EM 23/11]** Frontend HTML/CSS/JS → Controller/Service/Repository Java Spring Boot → MySQL; validar na implementação. |
| **RNF37** | Código versionado, alterações relevantes registradas. | Conferir branch/PR/commits no GitHub. |
| **RNF38–RNF40** | Erros tratados, estados vazios, busca continua sem GPS. | Testar falha de banco, nenhuma oferta e GPS negado. |
| **RNF41** | Aviso de possíveis mudanças em preço/disponibilidade. | Inspecionar aviso e exibição da atualização existente. |
| **RNF42** | Regras documentadas para teste e manutenção. | Conferir vínculos SPEC → API → Issue/teste. |

**Critérios adicionais de segurança/observabilidade [PROPOSTA]:** respostas de erro não devem expor SQL, senhas ou stack traces; coordenadas precisas não devem ser guardadas em banco da aplicação nem registradas deliberadamente em log; testes de tempo só serão declarados **aprovados** após execução documentada. Não afirmar conformidade WCAG ou desempenho com base somente na existência desta SPEC.

## 4. Regras de negócio (RN)

| ID | Regra | Origem/estado |
|---|---|---|
| **RN01** | Toda oferta referencia exatamente **um medicamento e uma farmácia** e possui preço válido. | Documento de Visão, preservada. |
| **RN02** | Indicadores de preço utilizam somente ofertas **válidas e disponíveis** do conjunto consultado. | Documento de Visão; reforçada no contexto. |
| **RN03** | A localização opcional poderá vir de CEP informado ou GPS autorizado; se GPS for negado, oferecer CEP de teste ou consulta **sem distância**. | Documento de Visão, esclarecida pelo contexto. |
| **RN04** | O destaque de menor preço e o de maior proximidade são independentes; a decisão final é do visitante. | Documento de Visão, preservada. |
| **RN05** | O PharmaFind não vende, recebe pagamentos, reserva, recebe pedidos nem recomenda medicamentos/tratamentos. | Documento de Visão, preservada. |
| **RN06** | Ofertas de **IDs de medicamentos diferentes** (incluindo dosagem/apresentação) não são somadas nem comparadas entre si. | CONTEXTO §§5,7,12, confirmada. |
| **RN07** | Ofertas indisponíveis **permanecem visíveis**, identificadas, mas nunca determinam menor preço, média, economia, ranking das disponíveis ou destaque de melhor preço. | CONTEXTO §§7–9, confirmada. |
| **RN08** | Menor preço, média e economia só existem quando há pelo menos uma oferta disponível e válida; sem elegíveis, métricas numéricas ficam **ausentes**. | CONTEXTO §§7–8, confirmada. |
| **RN09** | Distância, quando conhecida, é **aproximada e em linha reta**, calculada entre coordenadas, sem prometer rota/tempo de viagem. | CONTEXTO §6, confirmada. |
| **RN10** | O usuário pode consultar e comparar preços **sem fornecer localização**; GPS exige consentimento. | CONTEXTO §§5–6, confirmada. |
| **RN11** | Dados demonstrativos são fictícios e alterados pela equipe **diretamente no MySQL**; não existe painel de farmácias no MVP. | CONTEXTO §§7,9, confirmada. |
| **RN12** | A economia potencial é a diferença entre **maior e menor preço válido disponível** do medicamento exato, não um desconto comercial garantido. | CONTEXTO §8, confirmada no conceito; tratamento de uma oferta é [PROPOSTA] na seção 6. |
| **RN13** | O histórico é exclusivo de uma mesma oferta (medicamento + farmácia) e composto por registros fictícios persistidos em ordem cronológica. | Decisão de escopo 16/11/2026; U09 (#19). |
| **RN14** | Variação absoluta = último preço − primeiro preço; variação percentual = (variação absoluta ÷ primeiro preço) × 100, somente com **duas datas distintas** e primeiro preço positivo. Caso contrário, métricas `null`. | Decisão de escopo 16/11/2026; regras técnicas de arredondamento continuam submetidas à revisão. |

## 5. Critérios de aceite e cenários

Cada teste a seguir é um **caso especificado, não executado**. A identificação `CT` deve ser reproduzida em testes automatizados ou em evidência manual no PR que implementar a unidade.

| CT | Cenário / dados de entrada | Resultado de aceite | RF/RN |
|---|---|---|---|
| **CT01** | Buscar `Dipi` com pelo menos dois medicamentos de dosagens diferentes cadastrados. | Lista contém resultados compatíveis e permite selecionar um ID. **Não** mostra ofertas misturadas antes da seleção. | RF01–RF04, RN06 |
| **CT02** | Selecionar um medicamento com três ofertas, duas disponíveis (R$ 8,99 e R$ 10,99) e uma indisponível (R$ 7,50). | Mostra 3 ofertas, marca 1 indisponível; menor R$ 8,99, média R$ 9,99, economia R$ 2,00; ranking elegível R$ 8,99 → R$ 10,99. | RF05–RF09, RF31–RF32, RN02/RN07 |
| **CT03** | Consulta de medicamento com preço em outra dosagem, ID diferente. | Nenhuma oferta do outro ID aparece; cálculos não a utilizam. | RF03/RF07, RN06 |
| **CT04** | Medicamento com **uma oferta válida** de R$ 12,00. | Menor e média R$ 12,00; economia R$ 0,00 [PROPOSTA]; lista contém 1 elegível. | RF32, RN08/RN12 |
| **CT05** | Medicamento com **zero ofertas cadastradas**. | Lista vazia, aviso “nenhuma oferta cadastrada”; métricas `null`, nunca zero enganoso. | RF23/RF34, RN08 |
| **CT06** | Medicamento com **três ofertas, todas indisponíveis**. | Lista mostra 3 indisponíveis; `totalDisponiveis = 0`; menor/média/economia `null`, nenhum destaque melhor oferta. | RF31/RF34, RN07/RN08 |
| **CT07** | Duas ofertas disponíveis **com o mesmo menor preço**. | Empate respeita critério determinístico [PROPOSTA] da seção 6, sem declarar uma oferta melhor por preço. | RF08/RF09, RN04 |
| **CT08** | Usuário pesquisa sem CEP/GPS. | Comparação de preços funciona; distâncias `null`; ordenar por distância não produz distâncias artificiais. | RF14/RF17, RN10 |
| **CT09** | CEP válido de teste com coordenadas mapeadas. | Distância em km, descrita como linha reta, calculada só para farmácias com coordenadas. | RF10–RF11/RF16–RF18, RN09 |
| **CT10** | CEP com 7 ou 9 dígitos. | Entrada rejeitada com erro de formato; não consulta CEP externo. | RF11, RNF31 |
| **CT11** | CEP de 8 dígitos não cadastrado entre os testes. | Mensagem de CEP não contemplado; comparação por preço continua, sem distância. | RF33, RN10 |
| **CT12** | Usuário nega GPS. | Não usar coordenadas; permitir CEP de teste ou seguir sem localização. | RF12–RF14, RN03/RN10 |
| **CT13** | GPS autorizado, mas farmácia sem latitude/longitude. | Não inventar distância dessa farmácia; demais dados seguem visíveis. | RF16–RF18, RN09 |
| **CT14** | Falha na conexão MySQL / API indisponível. | Erro tratado, não mostrar números falsos, permitir tentar nova pesquisa. | RNF38, RF24 |
| **CT15** | Pesquisa com entrada maliciosa no termo. | Entrada validada e saída tratada; consulta parametrizada, sem SQL injetável nem execução HTML. | RNF23–RNF25 |
| **CT16** | Acessar fluxo principal via teclado em viewport de 320 px. | Campo, seleção, resultado e troca de ordenação operáveis; foco visível e sem rolagem horizontal desnecessária. | RNF01–RNF03/RNF10–RNF13 |
| **CT17** | Ofertas persistidas no MySQL são alteradas pela equipe em ambiente de teste. | A próxima consulta exibe dados atualizados da base, com data real de atualização se registrada. | RF26–RF30, RN11 |
| **CT18** | Pedido de ordenação por distância sem localização válida. | Resposta informativa com ordenação por preço [PROPOSTA]; interface não falha. | RF18, RN10 |
| **CT19** | Duas farmácias equidistantes / uma coordenada ausente. | Empate determinístico [PROPOSTA] e distância ausente posicionada após distâncias conhecidas. | RF18/RF19, RN09 |
| **CT20** | Busca por termo inexistente. | Lista de medicamentos vazia com orientação ao usuário; não equivale a medicamento sem ofertas. | RF01–RF03, RF23 |
| **CT21** | Histórico de uma oferta com 01/11 R$ 9,90, 04/11 R$ 10,50 e 12/11 R$ 8,99 (dados fictícios). | Lista/linha ordenada por data, diferença de **−R$ 0,91** e variação de **−9,19%** com duas casas; sem dados de outra farmácia. | RF35–RF37, RN13/RN14 |
| **CT22** | Histórico vazio ou com apenas um ponto válido. | Sem linha/tendência fabricada; sem variação percentual/nominal calculada (`null`). | RF38, RN14 |
| **CT23** | Histórico solicitado para medicamento e farmácia cujo par não possui oferta ou ID é inválido. | Não mostrar histórico de outra oferta; contrato distingue identificador inválido de oferta não encontrada. | RF35, RN13 |
| **CT24** | Atualização de preços e histórico com datas fictícias reproduzíveis. | Registros permanecem persistidos, com critério documentado de criação/atualização, sem duplicações indevidas ou valores diferentes a cada consulta. | RF35–RF37, RN13 |
| **CT25** | Auditoria de telas após recebimento das observações do professor. | Cada problema efetivamente informado tem evidência anterior, correção rastreável, verificação em mobile/desktop/teclado e resultado documentado; sem inventar feedback. | RNF01–RNF18, U10 |

**Fixtures para CT02–CT06:** os cenários estão materializados na carga `database/seeds/demonstracao.sql`, com IDs/dados fixos e farmácias fictícias. A suíte SQL da massa e a inicialização/reaplicação em clone descartável passaram no MySQL 8.0.45 ([evidência](../database/tests/RESULTADOS.md)); isso não comprova os fluxos HTTP/interface. Ver [massa e verificação](../database/seeds/README.md).

## 6. Contratos e decisões técnicas a validar antes da implementação

Os itens abaixo são **[PROPOSTA]**, exceto as decisões de persistência da seção 6.1 autorizadas pelo usuário para a etapa U01/#10 nesta branch. A autorização de implementação não substitui a revisão humana do PR nem aprova os demais contratos.

### 6.1 Oferta válida e persistência — etapa U01/#10 autorizada em 17/11/2026

- `MEDICAMENTO_FARMACIA.PRECO`: `DECIMAL(10,2) NOT NULL`, **maior que zero**, com `CHECK (PRECO > 0)`. Usar MySQL 8.0.16+ e modo estrito; validação equivalente no futuro servidor continua necessária.
- `DISPONIVEL`: `BOOLEAN NOT NULL`, restrito por `CHECK` a `0/1`, sem default de negócio. **Dados antigos exigem preenchimento explícito** antes de consolidar a migração, sem presumir disponibilidade.
- `DATA_ATUALIZACAO`: `TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`; novas inclusões recebem data automaticamente, e mudanças reais na oferta (inclusive preço/estado) atualizam o campo. `UPDATE` sem mudança mantém a data. Sessões em UTC (`+00:00`); datas antigas desconhecidas continuam `NULL`. O JSON continua proposto: ISO 8601 com offset quando existir, ou `null`.
- Instalação e migração são caminhos separados. A etapa preparatória não atualiza datas automaticamente durante a revisão da disponibilidade; a consolidação mantém datas `NULL` existentes. Procedimento e testes em [database/README.md](../database/README.md). Scripts presentes não significam migração executada nem U01 concluída.
- Uma oferta por par `ID_MEDICAMENTO` + `ID_FARMACIA`, aproveitando `UNIQUE` atual; não armazenar preços como texto ou ponto flutuante no cálculo monetário.
- Se o banco devolver um preço inválido, **não incluí-lo nos cálculos** e registrar falha de integridade para correção; política de visibilidade para esse caso é pendente [PROPOSTA].

#### Massa demonstrativa e mapeamento local — U01/#10 autorizados em 17/11/2026

- `database/seeds/demonstracao.sql`: 6 apresentações (IDs 1001–1006), 4 farmácias fictícias
  (2001–2004) e 12 ofertas (3001–3012), 8 disponíveis/4 indisponíveis. Inclui dosagens
  separadas, medicamento sem ofertas, todas indisponíveis, uma oferta única e empate.
- Datas de oferta fixas de fixture (`2026-11-12T12:00:00Z`), sem alegar coleta comercial.
  Carga transacional sem `UPDATE`/`REPLACE`/`IGNORE`; reexecução idêntica não duplica dados.
  IDs, pares ou conteúdos incompatíveis impedem a carga; dados externos e histórico são preservados.
- `database/Inicializar-Demonstracao.cmd` cria um banco novo `pharmafind_demo`; `--reaplicar`
  só executa a carga idempotente nesse banco. Para validar o executável, admite um alvo
  alternativo exclusivamente `pharmafind_u01_test_inicializado_<identificador>`, após
  consulta de existência. Não recriar nem apagar bancos existentes.
- `database/seeds/ceps-teste.json` é a lista local para U05: `72429005`, `72444240` e
  `72620100`. CEPs confirmados em páginas IFB/UnB; pontos representativos de teste, com
  origem explícita. Não são centroides oficiais nem geocodificação universal. Farmácias
  usam pontos sintéticos; a farmácia 2004 fica sem coordenadas para CT13.
- Não se acrescenta tabela permanente ou endpoint para o mapa. Fontes, estrutura JSON,
  IDs/cenários e comandos em [database/seeds/README.md](../database/seeds/README.md).
  Preparar os dados de CT09 não comprova cálculo de distância nem integração de API.

### 6.2 Cálculo e ordenação

Seja `P` a lista de preços de ofertas do **ID selecionado** com `disponivel = true` e preço válido:

```text
Se |P| = 0:
  menorPreco = mediaPreco = economiaPotencial = null
Se |P| >= 1:
  menorPreco = min(P)
  mediaPreco = arredondar_2_casas(soma(P) / |P|)
  economiaPotencial = max(P) - min(P)
```

- Usar cálculo decimal exato no backend (`BigDecimal` em Java é **[PROPOSTA]**) e **HALF_UP** na média em duas casas (empates no arredondamento para longe de zero).
- Para **uma oferta válida**, `economiaPotencial = 0.00`; não chamar isso de promoção. Para nenhuma válida, retornar `null`.
- Desempate de **preço**: `preco ASC`, depois `farmaciaId ASC` [PROPOSTA]. Duas farmácias com mesmo preço continuam empatadas no valor; evitar atribuir superioridade inexistente.
- Ofertas indisponíveis permanecem em `ofertasIndisponiveis`, não no `rankingDisponiveis`. Para **distância**, aplicar `distanciaKm ASC` apenas às elegíveis; coordenadas ausentes por último, com desempate por `farmaciaId` [PROPOSTA]. Distância física pode ser mostrada em oferta indisponível, mas **não a torna uma opção comprável**.
- `distanciaKm`: fórmula **Haversine** ou equivalente geodésico para ponto a ponto, em linha reta, arredondada a **2 casas** para exibição [PROPOSTA]; não inferir distância de CEP sem coordenadas.
- Pesquisa textual: remover espaços nas pontas, correspondência parcial sem diferenciar maiúsculas/minúsculas [PROPOSTA]; não combinar IDs de apresentações diferentes.

### 6.3 CEP/GPS e erros

- CEP: aceitar **oito dígitos**; aceitar `NNNNN-NNN` e normalizar o hífen **é proposta**, não comportamento confirmado. Um CEP bem formado, porém **não mapeado**, não deve bloquear preço.
- O navegador solicita GPS **somente por ação explícita** do visitante. Ao negar, o front-end não deve simular posição nem gravá-la.
- Enviar coordenadas para comparação somente quando fornecidas/autorizadas; não persistir a localização do usuário no MySQL.
- Contratos HTTP propostos: `GET /api/v1/medicamentos?termo=`, `GET /api/v1/medicamentos/{id}` e `POST /api/v1/medicamentos/{id}/comparacao`. O último `POST` **consulta** sem alterar dados, escolhido provisoriamente para não pôr coordenadas de GPS em uma URL de consulta. Confira exemplos, validações, estados vazios e erros em [`API.md`](API.md).

### 6.4 Histórico de preços (U09 — decisão de escopo e detalhes a implementar)

- O histórico pertence **à mesma oferta**, identificada pelo medicamento exato e pela farmácia; não combinar preços de apresentações ou estabelecimentos diferentes (RN13).
- Utilizar registros **fictícios persistidos em MySQL**. A tabela `HISTORICO_PRECO` existe no SQL legado (`DATA_REGISTRO DATE`), mas ainda não tem dados nem regra de gravação automatizada. A U09 deve definir, testar e documentar se a granularidade será **um ponto por dia** ou registros por evento com migração a `DATETIME` antes de criar dados.
- Gráfico de linha com datas cronológicas e preços em reais; o navegador apresenta valores recebidos da API, não séries simuladas a cada carregamento.
- Exibir `variacaoAbsoluta` e `variacaoPercentual` só com pelo menos **dois registros de datas distintas** e primeiro preço maior que zero. Valor negativo significa queda. Com série insuficiente, métricas `null` (RN14).
- O endpoint adicional **proposto** de leitura é `GET /api/v1/medicamentos/{id}/historico?farmaciaId={id}`, detalhado em [API.md](API.md). Não altera a rota de comparação das ofertas atuais.
- Escopo mínimo: **um medicamento + uma farmácia por gráfico**. Previsões, scraping e séries avançadas não fazem parte desta entrega.

## 7. Contrato de resposta — síntese

> **Toda a seção é PROPOSTA, não endpoint implementado.** O JSON abaixo mostra o formato mínimo da comparação detalhada em `docs/API.md`.

```json
{
  "medicamento": { "id": 10, "nome": "Dipirona", "dosagem": "500 mg" },
  "localizacao": { "status": "nao_informada", "origem": null },
  "ordenacaoAplicada": "preco",
  "resumo": {
    "totalOfertas": 3,
    "totalDisponiveis": 2,
    "menorPreco": 8.99,
    "mediaPreco": 9.99,
    "economiaPotencial": 2.00
  },
  "ofertasDisponiveis": [
    { "ofertaId": 1, "farmaciaId": 2, "preco": 8.99, "disponivel": true, "distanciaKm": null },
    { "ofertaId": 2, "farmaciaId": 3, "preco": 10.99, "disponivel": true, "distanciaKm": null }
  ],
  "ofertasIndisponiveis": [
    { "ofertaId": 3, "farmaciaId": 4, "preco": 7.50, "disponivel": false, "distanciaKm": null }
  ],
  "avisos": ["Dados fictícios para demonstração acadêmica."]
}
```

Campos completos de farmácia, atualização e apresentação são obrigatórios na resposta definida em `API.md`; o exemplo acima é **reduzido**. Nas respostas vazias, arrays serão `[]`, e métricas não calculáveis serão `null`, **nunca preço zero fabricado**.

## 8. Decomposição em unidades testáveis e Issues reais

As dez unidades possuem Issues registradas no repositório (U01–U08 criadas em 12–13/11; U09/U10 em 16/11). **Existir uma Issue não significa tarefa concluída ou responsável designado.** Cada unidade deve ter responsável confirmado, critérios de aceite e PR próprio quando viável.

| Unidade | Escopo permitido (E) | Verificação (V) | Restrições (R) | Dependências |
|---|---|---|---|---|
| **U01 — Ajustar esquema e massa demonstrativa** | SQL de medicamento/farmácia/oferta, disponibilidade, atualização, CEPs de teste mapeados e inserts fictícios. | CT03/CT05/CT06/CT09/CT17 e testes SQL de FKs, `UNIQUE`, preço inválido. | RN01/RN06/RN07/RN11; não trazer cadastro real nem painel. | Nenhuma; esquema, migração, seed/mapa e inicializador passaram na validação SQL; revisão humana pendente. |
| **U02 — Inicializar backend Java e persistência** | Build e acesso controlado ao MySQL, sem interface administrativa. | Iniciar aplicação, conectar localmente, erro de conexão tratado, consultas parametrizadas. | RNF23–RNF25; Spring Boot/Spring JDBC aceitos pela coordenação; nunca versionar senhas. | Decisão ADR004, U01 (para integração). |
| **U03 — Busca/seleção exata** | Consulta e identificação de medicamentos por nome/ID. | CT01/CT03/CT20, validação HTTP/JSON da API. | RN06; não retornar ofertas de vários medicamentos juntas. | U01, U02. |
| **U04 — Ofertas e motor de preços** | Consultar ofertas e produzir números/ranking em função testável isolada. | CT02–CT07; incluir todos-indisponíveis e empate. | RN01/RN02/RN07/RN08/RN12; não score composto. | U01–U03. |
| **U05 — Localização/distância opcional** | CEPs mapeados, GPS autorizado e Haversine, sem rota. | CT08–CT13/CT18/CT19, GPS negado e coordenada ausente. | RN03/RN09/RN10; não tornar localização obrigatória. | U01, U02 e contrato da API. |
| **U06 — Adaptar interface ao fluxo** | Reaproveitar layout, pesquisa, seleção, ofertas, métricas, localização e remoção de login/cadastro da navegação. | CT01/CT02/CT06/CT08/CT12/CT14/CT16/CT20 manual e/ou automatizado. | RN05/RN06/RN07; identidade visual atual. | U03, U04; U05 para proximidade. |
| **U07 — Testes, harness e evidências** | Testes automatizados de negócio/API e casos de borda; registrar comandos e saídas reais. | Reexecutar CT02–CT15 com dados fixos; resultados verificáveis. | Não fabricar testes/logs; a tecnologia deve corresponder à arquitetura aprovada. | Paralela a U02–U06, consolidada ao final. |
| **U08 — Ambiente e instruções de agente** | Decidir/integrar ambiente reprodutível, Docker quando exigido, regras do agente e README de execução. | Clone limpo, comandos reproduzidos por segundo integrante, evidências reais. | Não alegar Docker, agente ou CI existentes antes do PR. | U02 e decisão das ferramentas. |
| **U09 — Histórico de preços e gráfico** | Registros temporais fictícios por oferta, contrato JSON proposto, gráfico de linha e variações nominal/percentual calculáveis. | CT21–CT24 e teste de persistência por oferta. | RF35–RF38/RN13–RN14; não fabricar histórico nem previsão. | U01–U04, U06; integração com U07/U08. |
| **U10 — Auditoria e correções do frontend** | Inventariar feedback real do professor, analisar e corrigir páginas, acessibilidade, navegação, responsividade e integração com JavaScript. | CT25 e evidências antes/depois dos pontos efetivamente reportados. | Não inventar crítica do professor nem duplicar trabalho U06. | U06, coordenação com U03/U04/U05/U09. |

**Critério de separação:** API depende das regras de negócio e da persistência, mas **não deve conter fórmulas de preço embutidas**. A decomposição acima é o plano de implementação, não declaração de camadas/pacotes já existentes.

### Correspondência entre unidades e Issues

| Unidade | Issue | Unidade | Issue |
|---|---|---|---|
| U01 | [#10](https://github.com/PharmaFind/PharmaFind/issues/10) | U06 | [#15](https://github.com/PharmaFind/PharmaFind/issues/15) |
| U02 | [#11](https://github.com/PharmaFind/PharmaFind/issues/11) | U07 | [#16](https://github.com/PharmaFind/PharmaFind/issues/16) |
| U03 | [#12](https://github.com/PharmaFind/PharmaFind/issues/12) | U08 | [#17](https://github.com/PharmaFind/PharmaFind/issues/17) |
| U04 | [#13](https://github.com/PharmaFind/PharmaFind/issues/13) | U09 | [#19](https://github.com/PharmaFind/PharmaFind/issues/19) |
| U05 | [#14](https://github.com/PharmaFind/PharmaFind/issues/14) | U10 | [#20](https://github.com/PharmaFind/PharmaFind/issues/20) |

## 9. Matriz de rastreabilidade mínima

| Requisitos | Unidades | Testes de referência | Contrato API (proposto) |
|---|---|---|---|
| RF01–RF04, RF24–RF25 | U03/U06 | CT01, CT20 | `GET /medicamentos`, `GET /medicamentos/{id}` |
| RF05–RF09, RF22–RF23, RF31–RF32/RF34 | U01/U04/U06 | CT02–CT07, CT14 | `POST /medicamentos/{id}/comparacao` |
| RF10–RF19/RF33 | U01/U05/U06 | CT08–CT13, CT18–CT19 | `POST /medicamentos/{id}/comparacao` |
| RF20–RF21, RF26–RF30 | U01/U02/U04 | CT02, CT17 | `GET /medicamentos/{id}`, `POST /medicamentos/{id}/comparacao` |
| RNF01–RNF18, RNF34–RNF35 | U06/U07 | CT16 | Interface/acessibilidade |
| RNF19–RNF33, RNF38–RNF42 | U01/U02/U05/U07/U08 | CT10–CT15/CT17 | Erros JSON, parâmetros, banco e execução |
| RN01–RN12 | U01/U03/U04/U05/U07 | CT01–CT19 | Contrato e cálculo central |
| RF35–RF38, RN13–RN14 | U01/U09/U06/U07 | CT21–CT24 | `GET /api/v1/medicamentos/{id}/historico?farmaciaId={id}` (proposto) |
| RNF01–RNF18 e feedback real do professor | U06/U10/U07 | CT16, CT25 | Revisão visual/UX e acessibilidade |

**Vinculação operacional:** em cada Issue usar `SPEC: U0X, RFxx, RNxx, CTxx`; a branch deve incluir o **número verdadeiro da Issue**; o PR referencia a Issue com `Refs #...` ou `Closes #...` **somente quando adequado**. Uma alteração substantiva nas regras deve resultar em PR com justificativa e atualização de documentos/testes. **A v1.1 documenta mudança real de prazo, stack, histórico e escopo de revisão do frontend; a aprovação depende do PR da Issue #18.**

## 10. Pendências que precisam de decisão ou execução

1. **[DECIDIDO PELA COORDENAÇÃO EM 23/11]** Stack HTML/CSS/JavaScript (sem React/Vite), Java 21 + Spring Boot + Spring Web + Spring JDBC + Maven e MySQL. ADR 001/004 registram decisão e ADR 006 descarta a migração React no MVP. O professor confirmou liberdade para escolher Spring Boot; validar versões e execução real.
2. **[PERSISTÊNCIA — U01]** Esquema, migração, seed e mapa de CEPs implementados nesta branch (§6.1). Suíte ampliada, limpeza protegida e inicialização/reaplicação passaram no MySQL 8.0.45, com [evidência](../database/tests/RESULTADOS.md). Obter revisão humana e atualizar Issue/Project conforme o trabalho real; os testes SQL não substituem integração ou revisão.
3. **[CÁLCULOS]** Revisar/aceitar arredondamento monetário, empate por preço e ordenação por distância sem coordenadas; não prometer testes concluídos.
4. **[GEOLOCALIZAÇÃO]** Integrar na U05/U02 o mapa JSON de três CEPs/pontos de teste já documentado na U01; testar o fluxo de distância. GPS continua opcional e depende de consentimento.
5. **[API]** Validar contratos/erros de [API.md](API.md) antes da implementação, inclusive a nova consulta de histórico U09 sem alterar indevidamente os três contratos existentes.
6. **[HISTÓRICO — U09]** Definir a gravação/atualização de pontos históricos (por dia ou por evento), massa fictícia cronológica, contrato JSON e testes CT21–CT24. A tabela SQL legada não comprova implementação.
7. **[FRONTEND — U10]** Registrar as **observações exatas do professor** na [Issue #20](https://github.com/PharmaFind/PharmaFind/issues/20), corrigir telas e comprovar avaliações de UX/responsividade/teclado, sem presumir problemas específicos.
8. **[COLABORAÇÃO — ATRIBUIÇÕES EM ESPERA]** Confirmar responsáveis das Issues #11–#16 após validação da coordenação; manter atribuições existentes de U08/U10 sem inventar novos responsáveis; conduzir PRs por desenvolvedores diferentes e revisões cruzadas reais. `AGENTS.md` contém instruções, não comprova configuração operacional de agentes.
9. **[ACADEMIA]** O professor confirmou que Spring Boot é permitido e PDF único de links/evidências deve ir ao AVA; confirmar apenas eventuais detalhes adicionais de agente, Docker e harness. Executar os CTs relevantes; nenhum teste é considerado aprovado apenas por estar descrito.

---

**Revisão de 23/11/2026:** a coordenação aprovou a stack simplificada, **sem congelar o escopo**. Histórico U09 continua planejado; expansão de funcionalidades exige Issue/avaliação de impacto e validação do PO/equipe. Responsáveis U02–U07 aguardam confirmação. Esta atualização documental depende de PR revisado e não comprova implementação.
