# PharmaFind — Especificação Técnica (SPEC v1.0)

**Estado:** proposta inicial para revisão e publicação em PR; **não é aceite formal da equipe**.  
**Data de elaboração:** 12/11/2026. **Entrega funcional prevista pela equipe:** 19/11/2026.  
**Fontes:** [`CONTEXTO.md`](../CONTEXTO.md) (prioridade para decisões recentes), Documento de Visão do Produto (RF01–RF30, RNF01–RNF42, RN01–RN05) e apostilas de SDD do professor Romes.  
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
- Interface existente reutilizada e adaptada, com mensagens de erro e estados vazios; sem necessidade de conta.

### Fora do escopo até 19/11/2026

Autenticação/cadastro (inclusive telas legadas como parte do fluxo ativo), painel de farmácias, pagamentos, reservas/pedidos, recomendação clínica, integração automática de preços reais, histórico analítico de preços, gráficos, alertas, favoritos, histórico de pesquisa, modo escuro, comparação entre múltiplos medicamentos, score preço/distância, rotas e geocodificação universal de CEP. A tabela SQL de histórico existente não autoriza implementar gráficos/histórico no MVP.

### Premissas e estado atual

| Item | Natureza | Observação |
|---|---|---|
| HTML, CSS, JavaScript; Java e MySQL | **[CONFIRMADO]** | Linguagens e base persistente definidas pela equipe. |
| Dados de farmácias e preços fictícios, região Gama e arredores | **[CONFIRMADO]** | Não alegar farmácias ou preços comerciais reais. |
| Layout do front-end existente | **[CONFIRMADO]** | Manter identidade e adaptar navegação/consulta. |
| Framework Java, biblioteca de teste, build, estrutura de pacotes | **[PROPOSTA]** | Decisão arquitetural ainda aberta; conferir ADR 001/004. |
| Dados de disponibilidade e data da oferta | **[PENDENTE]** | SQL atual não tem campos, migração e semeadura ainda não existem. |
| CEPs e respectivas coordenadas | **[PENDENTE]** | A escolha concreta e a origem dos dados não foram informadas. |
| API HTTP v1 documentada aqui | **[PROPOSTA]** | Não há endpoints implementados nem chamados no front-end atual. |

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
| **RNF32–RNF33** | Coordenadas com precisão adequada; data de atualização válida quando adotada. | Inspecionar `DECIMAL(10,7)` atual; validar migração de data pendente. |
| **RNF34–RNF35** | Compatibilidade com navegadores modernos e uso móvel em conexão comum. | Testar Chrome/Edge/Firefox/Safari onde disponíveis; registrar cobertura real. |
| **RNF36** | Separação MVC entre interface, controle, negócio e persistência. | **[PROPOSTA DE ARQUITETURA]** O Documento de Visão indicou MVC, mas a equipe definiu a stack/arquitetura do PDF como provisória; validar antes de tratar como decisão fechada. |
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

**Fixtures para CT02–CT06:** os preços e estabelecimentos dos cenários são **exemplos de teste**, não dados comprovadamente inseridos no MySQL. O PR da base deverá criar uma massa pequena reproduzível.

## 6. Contratos e decisões técnicas a validar antes da implementação

Os itens abaixo são **[PROPOSTA]**. Eles detalham questões abertas no contexto para tornar API/testes consistentes; a publicação do arquivo **não equivale a aprovação** da equipe.

### 6.1 Oferta válida e persistência

- `MEDICAMENTO_FARMACIA.PRECO`: decimal **maior que zero**, duas casas, sem `NaN` ou valores negativos. O SQL atual usa `DECIMAL(10,2)` mas não possui `CHECK (PRECO > 0)`; alinhar validação e migração.
- `DISPONIVEL`: campo booleano obrigatório no banco (MySQL `BOOLEAN`/`TINYINT(1)`), sem valor nulo; **dados antigos precisam de migração explícita** para não supor disponibilidade verdadeira sem avaliação.
- `DATA_ATUALIZACAO`: data/hora da atualização da oferta (`DATETIME`/`TIMESTAMP` a decidir), preenchida ao editar preço/estado; definir fuso e regra de ausência na migração. No contrato JSON, usar ISO 8601 com offset quando existir; ausência representada por `null` [PROPOSTA].
- Uma oferta por par `ID_MEDICAMENTO` + `ID_FARMACIA`, aproveitando `UNIQUE` atual; não armazenar preços como texto ou ponto flutuante no cálculo monetário.
- Se o banco devolver um preço inválido, **não incluí-lo nos cálculos** e registrar falha de integridade para correção; política de visibilidade para esse caso é pendente [PROPOSTA].

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

## 8. Decomposição em unidades testáveis (para futuras Issues)

**Não existem números de Issue atribuídos a estas unidades.** São títulos sugeridos para criação **real** de Issues na ordem indicada; cada unidade deve ter responsável disponível, critérios de aceite e PR próprios, quando a divisão for viável.

| Unidade | Escopo permitido (E) | Verificação (V) | Restrições (R) | Dependências |
|---|---|---|---|---|
| **U01 — Ajustar esquema e massa demonstrativa** | SQL de medicamento/farmácia/oferta, disponibilidade, atualização, CEPs de teste mapeados e inserts fictícios. | CT03/CT05/CT06/CT09/CT17 e testes SQL de FKs, `UNIQUE`, preço inválido. | RN01/RN06/RN07/RN11; não trazer cadastro real nem painel. | Nenhuma; decisão técnica dos campos pendente. |
| **U02 — Inicializar backend Java e persistência** | Build e acesso controlado ao MySQL, sem interface administrativa. | Iniciar aplicação, conectar localmente, erro de conexão tratado, consultas parametrizadas. | RNF23–RNF25; framework pendente; nunca versionar senhas. | Decisão ADR004, U01 (para integração). |
| **U03 — Busca/seleção exata** | Consulta e identificação de medicamentos por nome/ID. | CT01/CT03/CT20, validação HTTP/JSON da API. | RN06; não retornar ofertas de vários medicamentos juntas. | U01, U02. |
| **U04 — Ofertas e motor de preços** | Consultar ofertas e produzir números/ranking em função testável isolada. | CT02–CT07; incluir todos-indisponíveis e empate. | RN01/RN02/RN07/RN08/RN12; não score composto. | U01–U03. |
| **U05 — Localização/distance opcional** | CEPs mapeados, GPS autorizado e Haversine, sem rota. | CT08–CT13/CT18/CT19, GPS negado e coordenada ausente. | RN03/RN09/RN10; não tornar localização obrigatória. | U01, U02 e contrato da API. |
| **U06 — Adaptar interface ao fluxo** | Reaproveitar layout, pesquisa, seleção, ofertas, métricas, localização e remoção de login/cadastro da navegação. | CT01/CT02/CT06/CT08/CT12/CT14/CT16/CT20 manual e/ou automatizado. | RN05/RN06/RN07; identidade visual atual. | U03, U04; U05 para proximidade. |
| **U07 — Testes, harness e evidências** | Testes automatizados de negócio/API e casos de borda; registrar comandos e saídas reais. | Reexecutar CT02–CT15 com dados fixos; resultados verificáveis. | Não fabricar testes/logs; a tecnologia deve corresponder à arquitetura aprovada. | Paralela a U02–U06, consolidada ao final. |
| **U08 — Ambiente e instruções de agente** | Decidir/integrar ambiente reprodutível, Docker quando exigido, regras do agente e README de execução. | Clone limpo, comandos reproduzidos por segundo integrante, evidências reais. | Não alegar Docker, agente ou CI existentes antes do PR. | U02 e decisão das ferramentas. |

**Critério de separação:** API depende das regras de negócio e da persistência, mas **não deve conter fórmulas de preço embutidas**. A decomposição acima é o plano de implementação, não declaração de camadas/pacotes já existentes.

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

**Vinculação futura:** em cada Issue usar `SPEC: U0X, RFxx, RNxx, CTxx`; a branch deve incluir o **número verdadeiro da Issue**; o PR referencia a Issue com `Refs #...` ou `Closes #...` **somente quando adequado**. Uma alteração substantiva nas regras deve resultar em PR com justificativa e atualização de documentos/testes. **Não há histórico fictício de v1.1.**

## 10. Pendências que precisam de decisão ou execução

1. **[DECISÃO]** Escolher implementação de backend Java, framework/build/testes e separar interface, regras de negócio e persistência com um arranjo viável (ADR001/ADR004).
2. **[DECISÃO]** Aprovar/revisar preço válido (`> 0`), booleano de disponibilidade, obrigatoriedade/fuso de atualização e forma de migrar registros existentes sem adivinhar valores (U01).
3. **[DECISÃO]** Aprovar/revisar arredondamento `HALF_UP`, desempate e ordenação por distância quando parte das ofertas não possui coordenadas (U04/U05).
4. **[DADOS]** Escolher CEPs concretos da região e suas coordenadas com fonte documentada, além da massa fictícia de demonstração (U01).
5. **[VALIDAÇÃO]** Aprovar o desenho de rotas/JSON da `API.md` ou registrar alternativa antes de codificar (U02–U05).
6. **[EVIDÊNCIA]** Criar Issues reais, registrar responsáveis disponíveis, implementar testes/ambiente do professor e executar CTs; não chamar esta matriz de teste executado.
7. **[ACADEMIA]** Conferir exigência da apostila sobre agente, Docker, harness, PDF Moodle e evidências. Estes arquivos Markdown **não cobrem sozinhos** esses artefatos.

---

**Aprovação:** ainda não registrada. A revisão deste arquivo deve acontecer por PR real para `develop`; os itens marcados **[PROPOSTA]** não se tornam decisões confirmadas simplesmente por estarem escritos aqui.