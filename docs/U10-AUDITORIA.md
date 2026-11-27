# U10 — Auditoria do frontend

## Feedback preservado

O feedback registrado pela equipe sobre a experiência anterior indicou necessidade de maior objetividade e sugeriu referências de pesquisa como a Decolar. Os princípios adotados são pesquisa como ação principal, hierarquia clara, separação entre pesquisa e comparação, seleção fácil e menor distração. Nenhuma identidade visual da referência foi copiada.

Não foi atribuído ao professor nenhum diagnóstico específico além do feedback geral descrito pela equipe.

## Correções implementadas

- A consulta passou a usar uma etapa de pesquisa e uma etapa de comparação visual separada.
- Os dados temporários agora representam os seis medicamentos, quatro farmácias e doze ofertas da seed oficial.
- A seleção mantém somente o ID da apresentação escolhida e mostra apenas suas ofertas.
- Foram preparados os cenários 1003 (todas indisponíveis), 1004 (sem ofertas) e 1006 (preços iguais).
- Ofertas indisponíveis aparecem separadamente e não são ordenadas como opções elegíveis de menor preço.
- Nova pesquisa limpa a seleção anterior.
- As páginas legadas de login/cadastro e seus scripts simulados foram retiradas do frontend público.
- A inscrição para novidades foi retirada da página “Como funciona”.
- GPS informa autorização sem afirmar comparação por distância; negar GPS não impede a consulta.
- CEP aceita oito dígitos com ou sem hífen e informa formato inválido.
- Coordenadas precisas não são registradas em log nem armazenadas.
- Diálogos receberam semântica modal, rótulos, foco inicial, retorno de foco, Escape e contenção básica de Tab.
- Links de salto direcionam para o conteúdo principal, não para elementos que contêm a navegação.
- O vermelho principal foi escurecido pontualmente e placeholders receberam contraste mais elevado.
- O sistema continua usando `textContent` e `replaceChildren`, sem interpolação de dados externos em `innerHTML`.

## Evidências reais da atualização

- Branch atual: `feature/20-auditoria-frontend`.
- Commit base auditado preservado: `5011f01`.
- Massa temporária alinhada ao arquivo `database/seeds/demonstracao.sql`.
- `git diff --check` executado após as alterações.
- Não foi possível executar Node pelo terminal disponível nesta sessão; não foi declarado teste automatizado JavaScript aprovado.
- Navegadores com Playwright/servidor visual não estavam disponíveis como ferramentas nesta execução.

## Responsividade e acessibilidade

Os breakpoints existentes foram preservados e foram adicionadas regras para largura pequena no painel de busca e ofertas. Ainda são necessárias verificações visuais reais em 320, 390, 768 e 1280 px.

A contenção de foco nos diálogos foi implementada no JavaScript, mas o fluxo completo por teclado deve ser revisado em navegador real. O contraste indicado foi ajustado, sem declarar conformidade WCAG completa.

## Limitações

- Não há backend/API implementada nesta entrega; os dados continuam demonstrativos.
- O histórico de preços e os cálculos econômicos não foram implementados nesta unidade.
- U05 permanece responsável pela geolocalização funcional e por distância em linha reta.
- U06 permanece responsável pela integração HTTP futura.
- U07 permanece responsável pela infraestrutura e execução dos testes aplicáveis.
- Imagens externas podem estar indisponíveis sem impedir o uso da navegação e da consulta.

## Rodada final de UX/UI e acessibilidade — 26/11/2026

Referências: Issue [#20](https://github.com/PharmaFind/PharmaFind/issues/20), PR [#35](https://github.com/PharmaFind/PharmaFind/pull/35), branch `feature/20-auditoria-frontend`, base `54f8a4a`, destino `develop`. Alterações locais, sem commit, push ou merge. Os registros acima descrevem a rodada anterior; as correções de semântica/foco e as evidências abaixo atualizam esse estado.

### Diagnóstico e princípio de UX

O responsável relatou no Brave: pesquisa abaixo de um hero extenso; cards de medicamentos altos, imagens desproporcionais e ações desalinhadas; duas ofertas de Dipirona 1 g ocupando altura excessiva. São observações da equipe, não novas críticas atribuídas ao professor. As evidências manuais anteriores (inicial, `dip`, duas apresentações, seleção de 1 g e ofertas de R$ 14,00/R$ 16,00) pertencem à versão anterior e não comprovam esta rodada. As três imagens em `references/` são referências de cards de outros produtos, não capturas desses defeitos.

Adotou-se o princípio de organização indicado na referência Decolar e na Issue: ferramenta de pesquisa imediatamente após a navegação, seleção da apresentação e só depois comparação; banner e explicações são secundários. Não houve cópia de marca ou nova auditoria do site externo.

As causas identificadas no código foram combinadas:

- Hero com altura mínima de 490 px, padding chegando a 5 rem e título chegando a 5 rem; no mobile, conteúdo absoluto e outras alturas mínimas.
- `article` herdava margens/padding e sombras do Pico; os cards de medicamentos não neutralizavam esses valores e `.product-content` usava `height: 100%`.
- Grid com cinco colunas fixas, imagens dimensionadas separadamente e botões sem margem automática ao final do conteúdo.
- Preços reutilizavam `.product-price { margin-top: auto }`, desalinhando-os nas ofertas; margens de `article` somavam-se ao gap da lista.
- Cabeçalho flex recebia `grid-template-columns` no mobile; placeholder local sobrescrevia o contraste global; IDs de salto estavam duplicados; CEP não modal recebia semântica e contenção de foco modais.
- O tema automático do Pico podia apresentar campos escuros em páginas claras. Foi fixado `data-theme="light"`, coerente com a identidade existente.

### Alterações desta rodada

- Inicial: seção compacta de pesquisa antes do hero, com os mesmos IDs/eventos de botão e Enter e encaminhamento de `termo`; banner menor, título em `h2` e remoção de sua chamada redundante para consultar. CEP/GPS permanecem na barra existente, sem duplicação.
- Medicamentos: grid automático, cards limitados a 260 px, gap de 16 px, padding de 14 px, imagens proporcionais, conteúdo flexível e ações alinhadas no rodapé. Nome, dosagem e apresentação explícitos; IDs retirados somente do texto público e preservados na seleção e nos dados.
- Ofertas: margem de `article` zerada, padding de 14 px, gap de 14 px, sombras discretas e preço centralizado verticalmente no desktop; no mobile, preço abaixo dos dados. Indisponibilidade e ordem anteriores preservadas.
- Acessibilidade: salto único após o menu; contraste de placeholder `#5f6f82` sobre `#f5f8fc` calculado em **4,83:1**; tom de texto secundário também escurecido; vermelho `#d62f3f` preservado (**4,84:1** sobre branco). Foco visível preservado, foco na comparação inclusive sem ofertas e retorno ao campo de pesquisa.
- CEP: diálogo não modal, foco inicial no campo, Tab livre, Escape e retorno ao disparador. Localização: modal com fundo inerte, Tab/Shift+Tab contidos e restauração do foco/fundo ao fechar, inclusive na página em que o popup fica dentro de `main`.
- Estado inicial orienta a digitar um termo, separado de pesquisa sem resultados. Estado de falha reservado em `#errorState`, oculto até futura integração real: nenhuma requisição ou falha HTTP foi inventada.
- Textos públicos corrigidos para não prometer filtros inexistentes nem resultados por CEP/GPS antes da integração.
- Catálogo, farmácias e ofertas em `consulta.js` comparados integralmente com o HEAD: conteúdo preservado. Nenhuma alteração em seed, backend, SPEC, API, cálculos ou histórico.

### Verificações efetivamente executadas

**Brave headless no Windows**, executável com ProductVersion `158.1.100.59`, perfil temporário isolado e servidor estático em loopback. Automação temporária via Chrome DevTools Protocol, Python e `websocket-client` já disponível no ambiente; nenhuma dependência instalada ou adicionada ao projeto. Não constitui implantação de uma suíte permanente da U07. Relatório: [149 verificações individuais](evidencias/u10/report.json).

| Verificação | Resultado real |
|---|---|
| Execução final no navegador | **149 aprovadas, 0 falhas; 0 erros JavaScript** |
| Larguras de 320, 390, 768, 1280 e 1920 px | Geometria da inicial, resultados, ofertas e diálogos verificada; sem rolagem horizontal nas quatro páginas |
| Pesquisa da inicial | Botão e Enter encaminharam `Dipi` e exibiram duas apresentações |
| Pesquisa na consulta | `Dipi`, `Dipirona`, termo inexistente e campo limpo passaram; busca `mg` conferiu cinco cards e alinhamento em cada linha nas cinco larguras |
| Apresentações e ofertas | 1001: 3 ofertas/1 indisponível; 1002: 2; 1003: 3 indisponíveis; 1004: nenhuma; 1006: 3, com dois preços de R$ 15,90 preservados; preços e ordem conferidos |
| Navegação e teclado | Seleção por botão e por Enter, retorno e troca de apresentação; foco visível; menu mobile, salto e Escape nas quatro páginas; Tab/Shift+Tab no modal e saída livre do CEP |
| CEP/GPS | CEP inválido manteve campo focado; `72429005` foi formatado/salvo; GPS negado pelo navegador foi tratado sem bloquear a consulta |
| Fallback e erro visual | Imagem inexistente de teste acionou SVG local; `#errorState` foi revelado apenas pelo roteiro de QA para inspecionar sua apresentação, sem alterar o fluxo demonstrativo |
| Referências públicas | Parser conferiu **67 referências locais** (`href`/`src` e fragmentos), sem destinos quebrados; IDs únicos nas quatro páginas |
| JavaScript e diff | `node --check frontend/script.js`, `node --check frontend/consulta.js` e `git diff --check`: sucesso; diff final inspecionado |

A pesquisa terminou em aproximadamente **355 px** de altura em 1280 × 720 e **359 px** em 1920 × 720; em 320 e 390 × 900, em **394 px**. As duas ofertas de 1 g mediram cerca de **112 px cada** no desktop, com 14 px entre elas; em 320 px, cerca de **155 px cada**. Medidas detalhadas constam no relatório.

Houve uma falha real na primeira execução: o cabeçalho dos resultados transbordava em 320 px. Corrigidos quebra de linha, tamanho do título e da contagem; a execução final passou. Uma rodada intermediária foi interrompida por uma simulação incompleta de Enter no roteiro; corrigiu-se a emissão da tecla e o percurso real por Tab antes de repetir. A primeira tentativa de conexão ao navegador no ambiente restrito falhou; a execução foi autorizada fora desse limite. O relatório final contém dois erros de rede: `favicon.ico` ausente e a imagem inexistente usada intencionalmente para testar fallback. Nenhum é erro JavaScript ou link público quebrado. O CDN do Pico carregou nas cinco larguras; fontes e imagens externas carregaram nas capturas inspecionadas.

Capturas finais inspecionadas, sem dados pessoais:

| Tela | Desktop (1280 px) | Mobile (320 px) |
|---|---|---|
| Inicial | [Pesquisa antes do banner](evidencias/u10/home-1280.png) | [Pesquisa compacta](evidencias/u10/home-320.png) |
| Medicamentos | [Duas apresentações](evidencias/u10/products-1280.png) | [Cards sem transbordamento](evidencias/u10/products-320.png) |
| Ofertas | [Preços centralizados](evidencias/u10/offers-1280.png) | [Ofertas empilhadas](evidencias/u10/offers-320.png) |

Diálogos em 320 px: [CEP não modal](evidencias/u10/cep-320.png) e [localização modal](evidencias/u10/location-320.png). Capturas dos cards foram roladas até os resultados para permitir sua inspeção completa.

### Reprodução manual e pendências

Na raiz do repositório:

```powershell
python -m http.server 8000 --bind 127.0.0.1 --directory frontend
```

Abra `http://127.0.0.1:8000/` no Brave. Em DevTools, selecione larguras **320, 390, 768, 1280 e 1920 px** (desktop com 720 px de altura; demais com 900 px). Confira pesquisa antes do banner, ausência de rolagem horizontal, cards, preços, menu e diálogos. Use Tab/Shift+Tab/Enter/Escape, incluindo o primeiro link de salto. Repita com zoom e leitor de tela: estes dois testes permanecem **pendentes**, assim como dispositivos físicos, outros navegadores e revisão humana final.

1. Pesquise `Dipi` pela inicial, primeiro pelo botão e depois por Enter; na consulta, tente `Dipirona`, um nome inexistente e limpe o campo. Confira estados distintos.
2. Selecione Dipirona 500 mg (1001): R$ 8,99, R$ 10,99 e R$ 7,50 indisponível. Volte e selecione 1 g (1002): somente R$ 14,00 e R$ 16,00.
3. Pesquise Paracetamol (1003): três indisponíveis; Ibuprofeno (1004): nenhuma oferta; Omeprazol (1006): R$ 15,90, R$ 15,90 e R$ 18,50.
4. Informe CEP `123` e depois `72429005`/`72429-005`; confira erro, formatação, fechamento, foco e aviso de integração pendente. Abra novamente, saia com Tab e feche com Escape.
5. Abra localização; percorra Tab/Shift+Tab, feche com Escape e negue GPS ao solicitar. A pesquisa deve continuar disponível.
6. Para fallback, no console da consulta com resultados, execute `document.querySelector('.product-card img').src = 'imagem-inexistente.png'`; o SVG local deve aparecer. Para inspecionar somente o estado de erro reservado, execute `document.getElementById('errorState').hidden = false`; recarregue ao terminar.
7. Confira o console (sem exceções JavaScript), navegue pelos links públicos e execute os comandos de sintaxe/diff indicados acima. Encerre o servidor com Ctrl+C.

Continuam pendentes a comparação com API/MySQL, a distância real e a revisão independente do PR. Os 15 testes com DOM simulado mencionados pelo responsável são evidência anterior; não foram tratados como execução desta versão. Não foi declarada conformidade WCAG integral nem conclusão da Issue sem aceite humano.

**Sugestão de commit:** `fix(frontend): compactar pesquisa e cards e corrigir acessibilidade (#20)`.

**Complemento sugerido ao PR #35:**

> Refs #20 — RF01–RF07, RF10–RF14, RF24–RF25, RF31/RF34; RNF01–RNF18; CT01/CT03/CT05/CT06/CT07/CT10/CT12/CT16/CT20/CT25, apenas nas partes de interface demonstrativa. Pesquisa antecipada ao banner, cards compactos e responsivos, foco/contraste/saltos corrigidos e CEP não modal. Preservados dados, IDs, disponibilidade, preços e ordenação. Validação local: 149 verificações no Brave headless nas cinco larguras, zero falhas e zero erros JavaScript; sintaxe JS, 67 referências locais e diff conferidos. Evidências em `docs/U10-AUDITORIA.md` e `docs/evidencias/u10/`. Pendentes revisão visual humana, zoom, leitor de tela e integração das outras unidades; sem novas dependências, backend ou alteração de contratos.

## Refinamento visual pontual — PR #35 / Issue #20

Rodada posterior às 149 verificações, na mesma branch e com todas as alterações locais anteriores preservadas. Modificados nesta rodada somente `frontend/style.css`, os estilos e o agrupamento do conteúdo em `frontend/consulta.html`, este documento e novas evidências. JavaScript e os outros três HTML públicos conferidos byte a byte contra o estado local de entrada: intactos.

- Paleta compartilhada: fundo uniforme `#E8EDF3` em `html`/`body`, cards e campos brancos, bordas `#CDD7E3` e sombras mais suaves. Texto secundário `#526477`, com **5,17:1** sobre o novo fundo. Marinho, vermelho, verde, marca, imagens e organização da inicial preservados.
- Consulta: títulos operacionais menores em DM Sans; Playfair Display permanece nos destaques das outras páginas. Ao comparar, a introdução é ocultada por CSS e substituída visualmente pelo cabeçalho compacto marinho do medicamento, com apresentação e retorno à pesquisa. Painel externo transparente, ofertas brancas, gap de 14 px e proporções anteriores mantidos.
- Um agrupamento HTML mantém o destino do link de salto acessível nos dois estados, inclusive com a introdução oculta. Texto branco no cabeçalho: **14,21:1**; placeholder no campo branco: **5,14:1**; foco branco do botão de retorno conferido sobre o marinho. A comparação usa o estado `hidden` já existente, sem alterar eventos, regras ou dados.

**Validação executada:** roteiro anterior reexecutado no Brave headless, acrescido de 16 verificações de paleta, hierarquia, contraste e salto durante a comparação: **165 aprovadas, zero falhas e zero erros JavaScript**. Larguras 320, 390, 768, 1280 e 1920 px; pesquisa da inicial na primeira área visível, cards compactos, preços alinhados, estados, diálogos, teclado e cenários de ofertas preservados. `node --check frontend/script.js`, `node --check frontend/consulta.js` e `git diff --check` passaram. Na inspeção visual, corrigida também a faixa branca que aparecia abaixo de páginas curtas quando somente `body` recebia o fundo.

Novas capturas e [relatório completo](evidencias/u10/refinamento/report.json) em `docs/evidencias/u10/refinamento/`, separados das evidências anteriores:

| Tela | 1280 px | 320 px |
|---|---|---|
| Inicial | [Pesquisa antes do banner](evidencias/u10/refinamento/home-1280.png) | [Inicial mobile](evidencias/u10/refinamento/home-320.png) |
| Pesquisa | [Apresentações](evidencias/u10/refinamento/products-1280.png) | [Cards mobile](evidencias/u10/refinamento/products-320.png) |
| Comparação | [Cabeçalho e ofertas](evidencias/u10/refinamento/offers-1280.png) | [Comparação mobile](evidencias/u10/refinamento/offers-320.png) |

Também foram capturadas as cinco larguras de “Como funciona” e “Sobre”, para conferir a aplicação compartilhada da paleta sem reestruturar essas páginas. Mantidas as limitações anteriores: revisão humana, leitores de tela, zoom e dispositivos físicos pendentes; execução automatizada restrita ao Brave headless. Permanecem os 404 do favicon ausente e da imagem intencionalmente inválida do teste de fallback. Nenhuma dependência instalada; sem commit, push ou merge.

## Homologação técnica e funcional final — 27/11/2026

Estado local baseado em `54f8a4a`, incluindo os ajustes posteriores de bordas/padding e sticky com afastamento de 14 px. [Relatório consolidado](evidencias/u10/homologacao/RELATORIO.md), [resultados individuais](evidencias/u10/homologacao/resultado-consolidado.json) e [manifesto do estado testado](evidencias/u10/homologacao/estado-testado.json).

Foram **reexecutadas 428 verificações: 422 aprovadas e 6 reprovadas**, sem reapresentar contagens históricas como novas execuções. As reprovações são dois textos desatualizados e retorno incorreto do foco ao fechar localização com menu mobile previamente aberto, reproduzido nas quatro páginas. Favicon ausente também registrado como não bloqueante; o 404 da imagem de fallback foi intencional. Zero erros JavaScript.

Os seis medicamentos e doze ofertas coincidem com a seed oficial da base atual do PR; pesquisa, isolamento por apresentação, disponibilidade, empate, CEP, GPS negado/indisponível e navegação sticky passaram. Oito comandos técnicos obrigatórios e 67 referências locais conferidos. Evidências inspecionadas por padrões, metadados e amostras visuais, sem achados de credenciais ou dados pessoais nas amostras. Zoom real em 200% não pôde ser comprovado no headless; leitor de tela, dispositivos físicos e outros navegadores pendentes.

**Parecer: APTO para publicação das alterações do frontend demonstrativo e revisão independente, com ressalvas não bloqueantes documentadas.** Não equivale a aprovação/merge ou aceite integral da Issue. Nenhuma falha foi corrigida; frontend, backend, banco, SPEC e API preservados. Somente este registro e as evidências de homologação foram acrescentados; sem commit, push ou merge.

## Correções pontuais e revalidação — 27/11/2026

Após autorização, removida a quantidade incorreta em “Sobre” e a referência a filtros no CTA de “Como funciona”. Escape no modal de localização agora encerra seu tratamento após devolver o foco ao acionador, sem fechar o menu mobile no mesmo evento. Favicon local nas quatro páginas reutiliza `medicamento-placeholder.svg`, já identificado com PHARMAFIND, sem modificar o recurso ou criar identidade visual. Nenhum ajuste de CSS/layout ou alteração de dados, backend, banco, seed, SPEC e API.

**Suíte consolidada reexecutada: 428 aprovadas, zero reprovadas.** As seis falhas anteriores foram revalidadas com sucesso, incluindo foco nas quatro páginas. Sintaxe JavaScript e `git diff --check` passaram; 71 referências locais válidas, favicon HTTP 200 e zero erros JavaScript. O único HTTP 404 novo foi o da imagem intencionalmente inválida do fallback. Resultados históricos preservados.

[Relatório atual](evidencias/u10/homologacao/correcoes/RELATORIO.md), [resultados completos](evidencias/u10/homologacao/correcoes/resultado-consolidado.json) e [seis retestes](evidencias/u10/homologacao/correcoes/reteste-seis.json). **Parecer: APTO para publicar as alterações do frontend demonstrativo e submeter à revisão independente.** Permanecem pendentes zoom real em 200%, leitor de tela, dispositivos físicos, outros navegadores e aceite humano. Sem commit, push ou merge.
