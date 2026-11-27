# PharmaFind — Contratos HTTP/JSON propostos (alinhados à SPEC v1.1)

**Status de toda esta API: PROPOSTA, NÃO IMPLEMENTADA.**  
**Documento de referência:** [SPEC v1.1](SPEC.md). **Registro inicial:** 12/11/2026. **Refinamento:** 16/11/2026.  
**Arquitetura-alvo aprovada pela coordenação em 23/11/2026:** Java 21 + Spring Boot / Spring Web + Spring JDBC + Maven + MySQL; API consumida por **HTML/CSS/JavaScript sem React/Vite**, conforme ADRs 001/004 e a não adoção de React registrada no ADR 006. A implementação e os contratos HTTP continuam pendentes. A árvore atualmente inspecionada **não contém servidor nem rotas HTTP**.

## 1. Princípios

- Base provisória: `/api/v1`; conteúdo `application/json; charset=utf-8`; valores monetários em reais, representados no JSON como **números decimais**, com cálculo exato no servidor (Java `BigDecimal` **proposto**).
- Rotas de **leitura** para visitantes, **sem login e sem painel administrativo**. Preços/disponibilidade são modificados pela equipe **diretamente no MySQL**, fora desta API.
- Nunca misturar medicamentos por nome parecido: a consulta de ofertas usa **ID exato**, inclusive quando as dosagens diferem (SPEC RN06).
- Arrays vazios são `[]`; informação não disponível é `null`, e não `0` inventado. Respostas de erro têm formato uniforme.
- A API não conhece trajetos de ruas, vendas, reservas, disponibilidade comercial real, previsão de preços ou medicamentos recomendados. O histórico demonstrativo (U09) usa dados fictícios persistidos da oferta exata.
- Todos os exemplos deste documento são **dados artificiais apenas para especificação e teste**. Os IDs, CEPs, preços e datas de exemplo **não descrevem registros já gravados**.
- Todos os formatos, rotas, critérios de desempate e códigos de erro abaixo dependem de aprovação da equipe em PR antes de virarem contrato implementado.

## 2. Visão geral dos endpoints

| Método | Rota | Finalidade | Requisitos da SPEC |
|---|---|---|---|
| `GET` | `/api/v1/medicamentos?termo={texto}` | Buscar lista de medicamentos por nome completo ou parcial, sem ofertas. | RF01–RF03, RF25, RN06 |
| `GET` | `/api/v1/medicamentos/{id}` | Ler detalhes de um medicamento específico para seleção. | RF03–RF04, RF26, RN06 |
| `POST` | `/api/v1/medicamentos/{id}/comparacao` | **Consulta sem alteração de dados**: obter ofertas, resumo econômico e, opcionalmente, distância/ordenação. | RF05–RF23, RF30–RF34, RN01–RN12 |
| `GET` | `/api/v1/medicamentos/{id}/historico?farmaciaId={id}` | Ler histórico temporal **fictício** de uma oferta medicamento/farmácia, sem modificar preços. | RF35–RF38, RN13/RN14, U09 (#19) |

**Por que POST para comparação?** É uma **proposta** para transportar o GPS no corpo da requisição, em vez de expor coordenadas precisas na URL e no histórico convencional de parâmetros. O endpoint é de leitura (não cria pedido nem modifica ofertas). A equipe pode preferir outro desenho, desde que preserve privacidade, critérios de aceite e documentação.

## 3. GET `/api/v1/medicamentos?termo={texto}`

**Entrada:** parâmetro de query `termo` obrigatório, string não vazia após remover espaços nas pontas. Busca parcial sem diferenciar maiúsculas/minúsculas **[PROPOSTA]**. Limite de 100 caracteres **[PROPOSTA]** para entrada previsível. Quando o campo está em branco, o cliente deve orientar a informar um termo; se requisitar em branco, o servidor retorna `400`.

```http
GET /api/v1/medicamentos?termo=Dipi HTTP/1.1
Accept: application/json
```

**Resposta 200 — correspondências (exemplo artificial):**

```json
{
  "termo": "Dipi",
  "quantidade": 2,
  "medicamentos": [
    {
      "id": 10,
      "nome": "Dipirona",
      "dosagem": "500 mg",
      "categoria": "Analgésico",
      "principioAtivo": "Dipirona sódica",
      "descricao": "Apresentação demonstrativa de 500 mg"
    },
    {
      "id": 11,
      "nome": "Dipirona",
      "dosagem": "1 g",
      "categoria": "Analgésico",
      "principioAtivo": "Dipirona sódica",
      "descricao": "Apresentação demonstrativa de 1 g"
    }
  ]
}
```

**Resposta 200 — sem correspondências:**

```json
{
  "termo": "termo-inexistente",
  "quantidade": 0,
  "medicamentos": []
}
```

É importante **não** transformar dois registros de dosagens diferentes em um único medicamento. A seleção de um `id` acontece na interface antes de consultar suas ofertas (RF03/RN06).

**Erros:** `400` se `termo` ausente/vazio/com mais de 100 caracteres; `503` se fonte de dados indisponível; `500` para erro inesperado tratado. Exemplos de erro na seção 7.

## 4. GET `/api/v1/medicamentos/{id}`

**Parâmetro de caminho:** `id` inteiro positivo existente em `MEDICAMENTO`. Não se aceitam nome de medicamento nem dosagem como substitutos do ID.

```http
GET /api/v1/medicamentos/10 HTTP/1.1
Accept: application/json
```

**Resposta 200 — exemplo artificial:**

```json
{
  "id": 10,
  "nome": "Dipirona",
  "dosagem": "500 mg",
  "categoria": "Analgésico",
  "principioAtivo": "Dipirona sódica",
  "descricao": "Apresentação demonstrativa de 500 mg"
}
```

**Erros:** `400` para ID fora do formato permitido (por exemplo, `abc` ou zero), `404` para ID válido não cadastrado, `503` para banco indisponível.

## 5. POST `/api/v1/medicamentos/{id}/comparacao`

Essa rota agrega as informações do medicamento selecionado e de **todas as suas ofertas cadastradas**, distinguindo as elegíveis das indisponíveis. O backend deve consultar o MySQL, aplicar regras de preço do medicamento **por ID** e retornar métricas. A ordenação e a localização são opcionais.

### 5.1 Requisição: sem localização (padrão)

```http
POST /api/v1/medicamentos/10/comparacao HTTP/1.1
Content-Type: application/json
Accept: application/json

{
  "ordenacao": "preco",
  "localizacao": null
}
```

Também se propõe aceitar `{}` como corpo equivalente (ordenar por preço, sem localização); **corpo ausente não deve quebrar o serviço** e poderá ser tratado como `{}` se a equipe aprovar.

### 5.2 Requisição: usando CEP de teste

```json
{
  "ordenacao": "distancia",
  "localizacao": {
    "origem": "cep",
    "cep": "72429-005"
  }
}
```

O CEP `72429-005` corresponde à entrada `72429005` do mapa versionado em `database/seeds/ceps-teste.json`, autorizada na U01 com ponto representativo de demonstração. A aceitação/normalização do hífen continua proposta. O comportamento para CEP **bem formado mas não mapeado**, como `99999-999`, é retornar preços normalmente, com `status: "nao_mapeado"` (seção 6). O mapa também inclui `72444240` e `72620100`; [fontes e limitações](../database/seeds/README.md#ceps-e-pontos-de-teste). Nenhuma rota está implementada.

### 5.3 Requisição: usando GPS já consentido pelo navegador

```json
{
  "ordenacao": "distancia",
  "localizacao": {
    "origem": "gps",
    "latitude": -16.0000000,
    "longitude": -48.0000000
  }
}
```

Coordenadas acima são **somente exemplo de contrato**, não localização real de farmácia ou usuário. O front-end pede permissão **antes** da chamada. O backend **não assume** que permissão foi concedida por existir o campo; o consentimento é mediado pelo navegador e a equipe deve garantir que a interface só envie GPS após ação autorizada. Sem consentimento, o cliente envia `localizacao: null` ou oferece CEP.

### 5.4 Validação de entrada [PROPOSTA]

| Campo | Regras |
|---|---|
| `id` | Inteiro positivo; `404` se válido mas inexistente. |
| `ordenacao` | Opcional: `"preco"` (padrão) ou `"distancia"`; outro valor → `400`. |
| `localizacao` | Opcional: `null`, ou objeto de CEP, ou objeto de GPS. Não misturar origens no mesmo objeto. |
| `localizacao.origem` | Se informado, deve ser `"cep"` ou `"gps"`. |
| `cep` | Oito algarismos, podendo receber hífen `NNNNN-NNN` **[PROPOSTA]**; validar e normalizar no servidor. CEP válido não cadastrado **não é erro de formato**. |
| `latitude` | Número de `-90` a `90`; obrigatório para `origem: gps`. |
| `longitude` | Número de `-180` a `180`; obrigatório para `origem: gps`. |
| Coordenadas de farmácia | Só calcular distância quando as duas coordenadas existem e são válidas. Nunca usar `(0,0)` como substituto de ausência. |

### 5.5 Resposta 200 — comparação com duas ofertas válidas e uma indisponível

Exemplo integral para **nenhuma localização informada**. Os dados são fictícios, independentes da base atual.

```json
{
  "medicamento": {
    "id": 10,
    "nome": "Dipirona",
    "dosagem": "500 mg",
    "categoria": "Analgésico",
    "principioAtivo": "Dipirona sódica",
    "descricao": "Apresentação demonstrativa de 500 mg"
  },
  "localizacao": {
    "origem": null,
    "status": "nao_informada"
  },
  "ordenacaoSolicitada": "preco",
  "ordenacaoAplicada": "preco",
  "resumo": {
    "totalOfertas": 3,
    "totalDisponiveis": 2,
    "menorPreco": 8.99,
    "mediaPreco": 9.99,
    "economiaPotencial": 2.00
  },
  "ofertasDisponiveis": [
    {
      "ofertaId": 1,
      "farmaciaId": 2,
      "farmacia": {
        "nome": "Farmácia Exemplo A",
        "endereco": "Endereço fictício A - Gama/DF",
        "cep": null,
        "horarioAbertura": "08:00",
        "horarioFechamento": "20:00"
      },
      "preco": 8.99,
      "disponivel": true,
      "dataAtualizacao": "2026-11-12T09:00:00-03:00",
      "distanciaKm": null,
      "menorPreco": true
    },
    {
      "ofertaId": 2,
      "farmaciaId": 3,
      "farmacia": {
        "nome": "Farmácia Exemplo B",
        "endereco": "Endereço fictício B - Gama/DF",
        "cep": null,
        "horarioAbertura": null,
        "horarioFechamento": null
      },
      "preco": 10.99,
      "disponivel": true,
      "dataAtualizacao": null,
      "distanciaKm": null,
      "menorPreco": false
    }
  ],
  "ofertasIndisponiveis": [
    {
      "ofertaId": 3,
      "farmaciaId": 4,
      "farmacia": {
        "nome": "Farmácia Exemplo C",
        "endereco": "Endereço fictício C - Gama/DF",
        "cep": null,
        "horarioAbertura": null,
        "horarioFechamento": null
      },
      "preco": 7.50,
      "disponivel": false,
      "dataAtualizacao": null,
      "distanciaKm": null,
      "menorPreco": false
    }
  ],
  "avisos": [
    "Ofertas demonstrativas: farmácias e preços fictícios.",
    "Preço e disponibilidade podem mudar após a data informada."
  ]
}
```

**Observações contratuais:**

- A oferta C custa menos, porém está **indisponível**: permanece identificada, mas não participa das estatísticas e nunca recebe `menorPreco: true` (RN02/RN07).
- `menorPreco`, `mediaPreco` e `economiaPotencial` são valores monetários **numéricos**; a interface formata `R$ 8,99`. Os exemplos exibem duas casas, mas o JSON numérico não garante preservação textual de zeros finais: **a formatação é responsabilidade do cliente**.
- `horarioAbertura`/`horarioFechamento`: `HH:mm` quando cadastrados, senão `null`. **Não** se declara “aberta agora” por comparação ingênua de horários.
- `dataAtualizacao`: ISO 8601 com offset quando disponível, ou `null` para data desconhecida. A coluna `TIMESTAMP` e a política UTC estão definidas na etapa U01; a serialização Java continua não implementada. A data do exemplo é artificial, não um registro comprovado.
- Para preço empatado, todas as ofertas disponíveis no menor valor podem receber `menorPreco: true` **[PROPOSTA]**; ordenação estável é `preco ASC`, depois `farmaciaId ASC`.
- O campo `farmacia` retorna somente dados demonstrativos de exibição. No futuro, a equipe pode decidir um contrato separado para detalhes; **não há endpoint administrativo** no MVP.

### 5.6 Resposta 200 — nenhuma oferta cadastrada

```json
{
  "medicamento": {
    "id": 10,
    "nome": "Dipirona",
    "dosagem": "500 mg",
    "categoria": "Analgésico",
    "principioAtivo": "Dipirona sódica",
    "descricao": "Apresentação demonstrativa de 500 mg"
  },
  "localizacao": { "origem": null, "status": "nao_informada" },
  "ordenacaoSolicitada": "preco",
  "ordenacaoAplicada": "preco",
  "resumo": {
    "totalOfertas": 0,
    "totalDisponiveis": 0,
    "menorPreco": null,
    "mediaPreco": null,
    "economiaPotencial": null
  },
  "ofertasDisponiveis": [],
  "ofertasIndisponiveis": [],
  "avisos": ["Nenhuma oferta cadastrada para este medicamento."]
}
```

**Todas as ofertas indisponíveis:** mesmo envelope, `totalOfertas > 0`, `totalDisponiveis: 0`, `ofertasDisponiveis: []`, array `ofertasIndisponiveis` preenchido e **métricas `null`**. Mensagem deve explicar que há ofertas registradas, mas nenhuma disponível; não confundir com ausência de medicamentos na busca.

## 6. Localização e distância

### Estado da localização na resposta [PROPOSTA]

| `localizacao.status` | Significado | Resultado |
|---|---|---|
| `nao_informada` | Nenhuma posição enviada. | `distanciaKm: null` e preços normais. |
| `calculavel` | GPS válido ou CEP **mapeado**. | Distâncias calculadas apenas para farmácias com coordenadas. |
| `nao_mapeado` | CEP tem formato correto, mas não está na pequena base de teste. | `distanciaKm: null`; ordenação por preço substitui distância; aviso claro. |

**Exemplo mínimo de estado sem mapeamento:**

```json
{
  "localizacao": { "origem": "cep", "status": "nao_mapeado" },
  "ordenacaoSolicitada": "distancia",
  "ordenacaoAplicada": "preco",
  "avisos": ["CEP não contemplado na base de testes. Exibindo preços sem distância."]
}
```

O exemplo é **recorte de campos** da resposta `200`, não outro tipo de resposta. As listas de ofertas e `resumo` seguem presentes como na seção 5.5.

**Distância:** calcular em linha reta entre `(latitude, longitude)` do usuário e da farmácia, em quilômetros, por Haversine ou equivalente. Não utilizar ViaCEP como serviço de latitude/longitude: ele **não fornece coordenadas**. O arredondamento de distância a 2 casas e a ordenação de coordenadas ausentes por último são **propostas**. Pontos de teste e origem estão em `database/seeds/ceps-teste.json`; a farmácia fictícia 2004 fica sem coordenadas para verificar ausência de distância. O cálculo e a leitura do mapa pelo backend ainda dependem da U05/U02.

**GPS negado/indisponível:** é um evento tratado **no navegador**, portanto não há resposta HTTP específica para “permissão negada”. O front-end deve oferecer CEP de teste ou consulta sem posição; **não simular coordenadas**.

## 7. Erros HTTP padronizados

### Estrutura comum [PROPOSTA]

```json
{
  "erro": {
    "codigo": "PARAMETRO_INVALIDO",
    "mensagem": "O termo de busca deve ser preenchido.",
    "detalhes": [
      { "campo": "termo", "motivo": "Obrigatório e não vazio." }
    ]
  }
}
```

| HTTP | Código de erro | Quando utilizar |
|---|---|---|
| **400 Bad Request** | `PARAMETRO_INVALIDO` | Termo vazio, CEP com formato inválido, ID malformado, GPS incompleto/fora do intervalo, ordenação desconhecida ou JSON inválido. |
| **404 Not Found** | `MEDICAMENTO_NAO_ENCONTRADO` | ID bem formado inexistente na base. |
| **503 Service Unavailable** | `DADOS_INDISPONIVEIS` | Banco de dados indisponível ou conexão impossível. |
| **500 Internal Server Error** | `ERRO_INTERNO` | Falha não esperada, sem vazar SQL, caminho de arquivo, stack trace ou credenciais. |

**Exemplo 404:**

```json
{
  "erro": {
    "codigo": "MEDICAMENTO_NAO_ENCONTRADO",
    "mensagem": "Medicamento não encontrado.",
    "detalhes": []
  }
}
```

**Exemplo 503:**

```json
{
  "erro": {
    "codigo": "DADOS_INDISPONIVEIS",
    "mensagem": "Não foi possível consultar as ofertas agora.",
    "detalhes": []
  }
}
```

**Distinções essenciais:** busca por termo sem resultados → `200` com `medicamentos: []`; medicamento cadastrado sem ofertas → `200` com arrays vazios e métricas `null`; CEP de formato válido sem mapeamento → `200` com aviso, **não** `404`; ID de medicamento desconhecido → `404`; falta de permissão de GPS → evento da interface, **não** erro HTTP.

## 8. Modelo de dados e implementação em Java

**Estado do código nesta branch:** o esquema e seed U01 fornecem 6 medicamentos, 4 farmácias e 12 ofertas. `backend/` contém fundação Spring Boot/JDBC e repositórios de leitura; a persistência integrada requer teste com MySQL. Não há endpoints de negócio nem serialização HTTP implementados. A compatibilidade com `APRESENTACAO` depende da integração do PR #34.

**Separação prevista para os endpoints de negócio (ainda não implementados):**

1. **Controller** recebe HTTP, valida campos e devolve códigos/JSON, sem fórmulas monetárias embutidas.
2. **Service** filtra ofertas válidas/disponíveis, calcula resumo com decimal exato, ordena e calcula distâncias opcionalmente.
3. **Repository** consulta medicamentos/farmácias/ofertas no MySQL com parâmetros vinculados, sem concatenar entradas do usuário em SQL.
4. **DTOs** representam os contratos JSON definidos aqui, separando-os das entidades persistidas.

O uso previsto de Spring Boot, Spring JDBC e Java 21 consta no ADR 004, sujeito à revisão do PR documental. Nomes concretos de classes, versões de dependências e portas só serão registrados após implementação. Não persistir GPS do usuário; não criar login administrativo para fazer updates no banco; registrar erros sem dados sensíveis.

## 9. Critérios de aceitação do contrato

| CA | Verificação | Relacionamento |
|---|---|---|
| **CA-API01** | `GET /medicamentos` lista apresentações separadas e permite selecionar o ID certo. | SPEC CT01, CT20; RF01–RF04/RN06 |
| **CA-API02** | `POST /comparacao` retorna estatísticas corretas para 8.99/10.99 e exclui 7.50 indisponível. | CT02; RF31/RF32/RN07 |
| **CA-API03** | Sem oferta: `[]`/`null`, sem valores numéricos inventados. | CT05/CT06; RN08 |
| **CA-API04** | Sem localização e GPS negado não impedem preços. | CT08/CT12; RN10 |
| **CA-API05** | CEP inválido dá `400`; CEP correto mas não mapeado dá `200` + aviso. | CT10/CT11; RF33 |
| **CA-API06** | ID inexistente dá `404`; falha de banco dá `503` sem rastros internos. | CT14; RNF38 |
| **CA-API07** | Entrada é validada também no servidor e consulta SQL é parametrizada. | CT15; RNF23/RNF24 |
| **CA-API08** | A resposta mantém nomes/preços/datas fictícios e identifica indisponibilidade. | CT02/CT17; RF20/RF30/RF31 |
| **CA-API09** | Histórico recupera somente pontos da oferta correspondente ao medicamento e à farmácia consultados, em ordem cronológica. | SPEC CT21/CT23; RF35/RN13 |
| **CA-API10** | Variação nominal e percentual corretas apenas com dois pontos de datas distintas e preço inicial positivo; caso contrário `null`. | SPEC CT21/CT22; RF37/RF38/RN14 |
| **CA-API11** | A consulta de histórico não gera valores aleatórios; dados fictícios persistidos e estados vazios estão documentados e verificados. | SPEC CT22/CT24; U09 |

**Status dos testes:** acima são **cenários a executar**, não resultados observados. A implementação deve anexar evidências reais nos PRs; nenhum teste foi executado como parte da redação documental.

## 10. Decisões em aberto

- Aprovar rotas, nomes de campos, limites de busca e formato de erros deste contrato.
- Stack aprovada pela coordenação em 23/11: Java 21 + Spring Boot + Spring JDBC + Maven + MySQL e frontend HTML/CSS/JavaScript. A decisão será revisada por PR, e versões/testes/harness continuam pendentes. O professor informou que Spring Boot é permitido.
- Fixar regras de preço válido, empate, arredondamento da média e da distância com atualização explícita da SPEC.
- Integrar o backend à massa fictícia; a suíte SQL ampliada e o inicializador/reaplicação da U01 passaram ([evidência](../database/tests/RESULTADOS.md)). O contrato HTTP e o mapeamento SQL/JSON ainda não foram implementados ou testados.
- Integrar o mapa local de CEPs/pontos de teste já versionado e documentado; nenhuma cobertura geográfica universal é prometida.
- Definir eventual política de cache/logs que evite retenção indevida de GPS; exigir HTTPS se houver publicação em produção.

**Não há endpoints de autenticação (`/login`), administração de farmácias (`/farmacias/atualizar`), pagamentos (`/pagamentos`) ou alertas (`/alertas`) neste MVP.** Também **não há um endpoint genérico `/historico`**: a única rota de histórico prevista é a **consulta de leitura específica** `GET /api/v1/medicamentos/{id}/historico?farmaciaId={id}`, descrita nas seções 2 e 11 para a U09. Não criar endpoints administrativos ou funcionalidades além da SPEC por inferência de tabelas legadas.

## 11. Histórico demonstrativo de preços — U09 (contrato novo proposto)

A decisão de incluir histórico e gráfico no produto foi informada em 16/11/2026. Este endpoint de **leitura** é um acréscimo justificado por U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19); os outros três endpoints da seção 2 permanecem conceitualmente inalterados.

### 11.1 Requisição

```http
GET /api/v1/medicamentos/10/historico?farmaciaId=2 HTTP/1.1
Accept: application/json
```

- `id`: inteiro positivo correspondente ao medicamento exato.
- `farmaciaId`: inteiro positivo **obrigatório**; o histórico é restrito à oferta formada pelo par medicamento/farmácia.
- Datas/preços devem vir de `HISTORICO_PRECO` associado à oferta; não gerar uma série aleatória em cada consulta.
- A gravação de histórico por dia ou por evento dependerá de política explícita de persistência na U09 (a tabela existente usa `DATA_REGISTRO DATE`).

### 11.2 Resposta 200 (dados totalmente fictícios)

```json
{
  "medicamentoId": 10,
  "farmaciaId": 2,
  "ofertaId": 1,
  "historico": [
    { "data": "2026-11-01", "preco": 9.90 },
    { "data": "2026-11-04", "preco": 10.50 },
    { "data": "2026-11-12", "preco": 8.99 }
  ],
  "resumo": {
    "primeiroPreco": 9.90,
    "ultimoPreco": 8.99,
    "variacaoAbsoluta": -0.91,
    "variacaoPercentual": -9.19
  },
  "avisos": ["Histórico ilustrativo com preços fictícios de demonstração."]
}
```

O gráfico Chart.js integrado ao JavaScript existente deverá exibir pontos em ordem cronológica crescente, com preço em reais. **Variação absoluta = último − primeiro**; **percentual = (variação absoluta / primeiro) × 100**. Neste exemplo, de R$ 9,90 para R$ 8,99: **−R$ 0,91** e **−9,19%** (arredondamento a duas casas, regra final ainda sujeita à aprovação). `BigDecimal` é a escolha para cálculo monetário no backend, sem confiar no número formatado do frontend.

### 11.3 Histórico insuficiente

Uma oferta com zero pontos deve retornar `200` e `historico: []`; com um ponto, retornar esse ponto. Em ambos os casos, **`variacaoAbsoluta` e `variacaoPercentual` são `null`**, sem gráfico ou tendência fabricada. `primeiroPreco`/`ultimoPreco` podem refletir o único preço existente, e devem ser `null` na ausência total de pontos.

```json
{
  "medicamentoId": 10,
  "farmaciaId": 2,
  "ofertaId": 1,
  "historico": [],
  "resumo": {
    "primeiroPreco": null,
    "ultimoPreco": null,
    "variacaoAbsoluta": null,
    "variacaoPercentual": null
  },
  "avisos": ["Ainda não existem registros históricos para esta oferta fictícia."]
}
```

**Tratamento de erros [PROPOSTA]:** `400` para `id`/`farmaciaId` inválidos ou ausentes; `404` para medicamento ou par medicamento/farmácia inexistente; `503` para indisponibilidade de dados; `500` para erro inesperado tratado. Usar o envelope de erro da seção 7. Não usar dados de outra farmácia como fallback nem devolver `0` para variação não calculável.

**Verificações:** CT21–CT24 da SPEC v1.1, além de integridade e testes de persistência registrados em PR. Nenhuma resposta acima comprova implementação ou execução real.
