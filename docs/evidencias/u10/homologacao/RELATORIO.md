# Homologação final U10 — PR #35

Data: **27/11/2026**, America/Sao_Paulo. Issue #20; branch `feature/20-auditoria-frontend`; destino `develop`. Execução de QA sem correções, alterações de comportamento, commit, push ou merge.

## Estado e ambiente

- HEAD local/remoto do PR: `54f8a4ab467686bd1921daa31486bd03599bb4bb`.
- Base do PR consultada no GitHub: `2045c94aa7970050c0dcd6775810293ee45c68fd`.
- Snapshot do diff local testado, antes de acrescentar esta documentação: SHA-256 `0d666d9d0e81be0f11a7696333d474f9f54d1987411dce59fa22dfc9b7434970`.
- [Manifesto](estado-testado.json): hashes dos arquivos locais, inclusive evidências anteriores; permite distinguir o HEAD das alterações não commitadas realmente executadas. Os arquivos preexistentes permaneceram idênticos durante os testes. Somente a documentação/evidências da homologação foram acrescentadas depois.
- Windows; Python 3.13; Brave headless, executável ProductVersion `158.1.100.59`; CDP identifica Chromium `158.0.8127.92`, V8 `15.8.62.31`. Perfis temporários isolados, servidor somente em `127.0.0.1`, sem conexão ao banco e sem coordenadas do usuário.
- Roteiro anterior reaproveitado: [cópia do script executado](roteiro_brave.py), com cenários adicionais solicitados; `websocket-client` já estava instalado no ambiente. Nenhuma biblioteca foi instalada ou adicionada ao frontend.

## Resultado consolidado

**428 verificações executadas: 422 aprovadas e 6 reprovadas.** As seis reprovações representam três defeitos: dois textos e uma falha de retorno do foco reproduzida nas quatro páginas. Nenhum teste antigo foi somado sem nova execução.

| Grupo | Executadas | Aprovadas | Reprovadas | Evidência |
|---|---:|---:|---:|---|
| Fluxos, responsividade e acessibilidade do roteiro ampliado | 216 | 214 | 2 | [Browser](browser/report.json) |
| Sticky e menu mobile durante rolagem | 169 | 169 | 0 | [Sticky](sticky/report.json) |
| Contraste e combinações de foco adicionais | 17 | 13 | 4 | [Acessibilidade](acessibilidade/report.json) |
| Inspeções técnicas, arquivos e referências | 13 | 13 | 0 | [Checks técnicos](tecnico-checks.json) |
| Compatibilidade com seed oficial | 4 | 4 | 0 | [Seed](seed-checks.json) |
| Comandos obrigatórios | 8 | 8 | 0 | [Comandos e saídas](comandos-tecnicos.json) |
| Integridade dos arquivos preexistentes durante os testes | 1 | 1 | 0 | [Consolidado](resultado-consolidado.json) |

Cada asserção registra o esperado e o obtido nos JSONs. Os totais contam asserções, não medicamentos ou defeitos distintos. Os testes independentes continuaram após as falhas. Duas tentativas auxiliares de preparação precisaram corrigir o parser do roteiro (acentuação no terminal e seletor incluindo conteúdo oculto); execuções parciais não entram nos totais e o frontend não foi alterado.

## Validação técnica

`git status`, `git branch --show-current`, `git diff --stat`, `git diff --check`, `git diff --name-only`, `git ls-files --others --exclude-standard`, `node --check frontend/script.js` e `node --check frontend/consulta.js`: **exit code 0**. O status identifica oito arquivos previamente modificados e evidências não versionadas; não é uma árvore limpa nem uma publicação já realizada.

Alterações rastreadas limitadas aos sete arquivos públicos HTML/CSS/JS autorizados e `docs/U10-AUDITORIA.md`. Nenhuma alteração em backend, banco, SPEC ou API. Os arquivos não rastreados são capturas, relatórios e roteiro de QA em `docs/evidencias/u10/`; não foram encontrados perfis de navegador, caches, credenciais ou `.env` para versionar.

Conferidas **67 referências locais** de HTML (incluindo imagens/scripts/estilos e fragmentos), sem destinos quebrados; links públicos também responderam HTTP 200 durante o teste. IDs únicos nas quatro páginas. HTML/JS públicos não remetem a login/cadastro removidos. Permanecem seletores CSS de autenticação sem uso: resíduo de estilo, sem rota ou funcionalidade ativa; não removidos nesta homologação.

A seed local foi conferida contra o arquivo oficial na base atual do PR: blob Git `a8e546f574fedaa38cdca6844ff76e352c075fbd`. Os seis medicamentos, dosagens/apresentações, quatro farmácias/endereço e doze ofertas/IDs/preços/disponibilidade coincidem com os dados extraídos do navegador. A apresentação é derivada da descrição da seed atual, que ainda não possui coluna própria nesse arquivo. Não se tratou documentação de contratos como API implementada.

Inspeção de evidências: JSONs parseáveis; PNGs sem chunks textuais/EXIF; busca de padrões de chaves privadas, tokens e senhas sem achados. Capturas atuais e anteriores foram inspecionadas por amostragem dos tipos de tela; exibem somente páginas do protótipo e dados fictícios. Sem chrome de perfil, GPS real ou dados de conta. [Inventário e hashes](evidencias-inspecao.json). A inspeção por padrões/amostragem não é certificação universal de ausência de dados pessoais.

## Cenários funcionais executados

Pesquisa da inicial via botão e Enter encaminhou `Dipi`. Na consulta, `Dipi`, `Dipirona` e `DIPIRONA` retornaram duas apresentações; termo inexistente apresentou mensagem própria; vazio e somente espaços exibiram orientação inicial. Seleção por botão e teclado, retorno com foco no campo, troca de apresentação e limpeza da seleção/DOM passaram.

| ID | Esperado | Obtido |
|---|---|---|
| 1001 | R$ 8,99 e R$ 10,99 disponíveis; R$ 7,50 indisponível | Conforme; 3 ofertas, sem mistura |
| 1002 | R$ 14,00 e R$ 16,00 disponíveis | Conforme; 2 ofertas |
| 1003 | Três ofertas indisponíveis | Conforme; mensagem de ausência de oferta disponível, sem eliminar os registros |
| 1004 | Nenhuma oferta cadastrada | Conforme; mensagem distinta e foco na comparação |
| 1005 | Uma oferta disponível de R$ 12,00 | Conforme; 1 oferta |
| 1006 | R$ 15,90, R$ 15,90 e R$ 18,50 disponíveis | Conforme; empate preservado, 3 ofertas |

[Dados extraídos](browser/dados-observados.json) e [conteúdo observado das seis comparações](browser/comparacoes-observadas.json). Disponíveis em ordem crescente, indisponíveis identificadas após as elegíveis e sem destaque de menor preço. Nenhum cálculo de média/economia/ranking foi acrescentado ao frontend.

CEP inválido manteve diálogo e foco no campo. CEPs `72429-005` e `72429005` foram formatados/salvos e retornaram foco com aviso de integração pendente. GPS negado foi simulado por permissão do navegador; GPS indisponível por ausência temporária da propriedade no contexto de teste. Pesquisa continuou funcionando; não houve obtenção, persistência ou uso de coordenadas reais.

CEP com semântica não modal e Tab livre; localização modal com fundo inerte, contenção Tab/Shift+Tab, fechamento e restauração normais passaram. A combinação menu aberto + Escape do modal tem a falha descrita abaixo. Links de salto, foco na seleção inclusive sem ofertas e fallback para SVG local passaram.

## Responsividade, contraste e zoom

Executadas larguras **320, 390, 768, 1280 e 1920 px**. Inicial com pesquisa antes do banner e botão na primeira área visível (desktop 720 px de altura, demais 900 px); cards compactos, botões alinhados por linha, ofertas com gap de 14 px e preços centralizados no desktop. Sem transbordamento horizontal detectado nas quatro páginas.

Sticky testada no início e após rolagens de 100/300 px, em janelas de 600 px de altura: topo de 14 px, largura/altura/posição horizontal estáveis e sem mudança da posição de layout do conteúdo. Menu mobile aberto durante rolagem manteve todos os links visíveis/clicáveis; Escape fechou e restaurou foco. Capturas atuais preservam cores, marca, fontes e imagens; regressão visual é inspeção de geometria e amostras, não comparação automatizada pixel a pixel.

Textos e controles principais amostrados por cores computadas passaram em 4,5:1: navegação, ações principais, preços, disponibilidade e endereços. Branco no marinho: 14,21:1; texto secundário no fundo: 5,17:1; placeholder sobre branco: 5,14:1; foco do retorno sobre marinho acima de 3:1. Não constitui certificação integral WCAG.

**Zoom real de 200% não executado com comprovação.** Foram tentados Ctrl+0 e quatro Ctrl++ via CDP, sem reduzir viewport ou aplicar escala artificial. DPR permaneceu 1, largura interna 390 e escala visual 1; o navegador headless não aplicou o zoom por esse mecanismo. [Registro da tentativa](browser/zoom-tentativa.json). Validação manual no navegador com zoom em 200%, leitor de tela, dispositivos físicos e outros navegadores permanece pendente.

## Falhas e classificação

| ID | Classificação | Evidência e reprodução | Impacto |
|---|---|---|---|
| H01 | **Não bloqueante** | `sobre.html:496`: informa “dez medicamentos”; catálogo/seed têm seis. [Captura](browser/finding-catalog-count.png) | Inconsistência textual; não altera pesquisa ou dados |
| H02 | **Não bloqueante** | `como-funciona.html:865`: CTA manda “utilize os filtros”; não há controles de filtros. [Captura](browser/finding-filters.png) | Orientação incorreta; pesquisa e seleção continuam operáveis |
| H03 | **Não bloqueante** | Em 390 px, abrir menu mobile → abrir localização → Escape. Modal fecha, menu também fecha e foco termina em `mobileMenuButton`, em vez de `locOpen`; reproduzido nas quatro páginas. [Captura](acessibilidade/consulta-focus-after-escape.png), [asserções](acessibilidade/report.json) | Falha contextual de foco; foco continua em controle visível e a página permanece navegável. Retorno normal sem menu aberto passou |
| H04 | **Não bloqueante** | `favicon.ico` solicitado implicitamente pelo navegador retorna HTTP 404 | Recurso cosmético ausente; não é link público quebrado nem erro JS |
| — | **Fora do escopo** | API/MySQL, distância real, motor econômico e histórico não integrados nesta demonstração | Pertencem às demais unidades; não são funcionalidades homologadas por esta rodada |

**Bloqueantes encontrados: nenhum.** As falhas foram registradas e não corrigidas. Também se observou que a descrição remota do PR continua no template: o responsável deve preenchê-la com escopo, evidências e ressalvas antes da revisão humana.

Console: **zero erros JavaScript** nas três execuções concluídas. No browser principal houve dois HTTP 404: favicon ausente (**falha real não bloqueante**) e `missing-u10-test.png` (**falha intencional esperada**, usada para confirmar o fallback). Não houve eventos `Network.loadingFailed` no roteiro principal. Os demais relatórios preservam seus próprios eventos de rede; não foram ocultados avisos do navegador.

## Evidências visuais atuais

| Tela | Desktop | Mobile |
|---|---|---|
| Inicial | [1280 px](browser/home-1280.png) | [320 px](browser/home-320.png) |
| Pesquisa | [1280 px](browser/products-1280.png) | [320 px](browser/products-320.png) |
| Comparação | [1280 px](browser/offers-1280.png) | [320 px](browser/offers-320.png) |
| Sticky durante rolagem | [1280 px](sticky/consulta-1280.png) | [320 px](sticky/consulta-320.png) |

Há capturas das demais larguras, das páginas institucionais, dos diálogos e das seis comparações. Relatórios anteriores em `../` e `../refinamento/` foram preservados como histórico e não substituíram estas novas execuções.

Para reproduzir nesta máquina, na raiz do repositório e com Brave/Python/websocket-client já disponíveis:

```powershell
python -u docs/evidencias/u10/homologacao/roteiro_brave.py --homologacao
python -u docs/evidencias/u10/homologacao/roteiro_brave.py --homologacao --navigation-only --sticky-only
python -u docs/evidencias/u10/homologacao/roteiro_brave.py --homologacao --a11y-extra
```

O roteiro usa o caminho local do Brave e grava nas mesmas pastas de evidências; preserve as evidências anteriores antes de uma nova execução. O código de saída do roteiro não substitui a leitura das asserções reprovadas nos JSONs.

## Parecer

**APTO para publicar as alterações do frontend demonstrativo e submeter o PR #35 à revisão independente, com as ressalvas H01–H04 documentadas.** O fluxo principal passou; os achados não impedem a utilização nem expõem dados sensíveis nos testes executados. Este parecer não aprova merge, não encerra a Issue e não homologa a aplicação integrada ou conformidade WCAG completa. Aceite final e decisão sobre as pendências pertencem ao revisor humano.

## Revalidação posterior — correções autorizadas em 27/11/2026

Os resultados e achados acima permanecem como histórico da primeira homologação. Após correção dos dois textos, prioridade de Escape no modal e reutilização do SVG local como favicon, foram **reexecutadas 428 verificações: 428 aprovadas e zero reprovadas**. As seis reprovações anteriores passaram nas novas execuções. Consulte o [relatório posterior](correcoes/RELATORIO.md), o [consolidado atual](correcoes/resultado-consolidado.json) e o [reteste das seis falhas](correcoes/reteste-seis.json). Zero erros JavaScript; 404 somente da imagem de fallback intencional. Parecer atual: **APTO para publicação das alterações do frontend demonstrativo e revisão independente**, mantidas as limitações de ambiente e o aceite humano. Nenhum registro anterior foi substituído; sem commit, push ou merge.
