# Revalidação das correções pontuais — PR #35 / U10

**27/11/2026 — feature/20-auditoria-frontend.** Histórico anterior preservado: [428 verificações, 422 aprovadas e 6 reprovadas](../RELATORIO.md). Esta pasta contém uma execução nova, após as correções autorizadas.

## Correções realizadas

- `frontend/sobre.html`: removida a quantidade incorreta de dez medicamentos; texto agora descreve a massa demonstrativa sem fixar uma quantidade que possa ficar desatualizada. A seed continua com seis medicamentos, sem alteração.
- `frontend/como-funciona.html`: CTA orienta pesquisar, selecionar a apresentação e comparar preços/disponibilidade; retirada a referência a filtros inexistentes. Avisos de integração futura por distância preservados.
- `frontend/script.js`: Escape no modal de localização previne o comportamento padrão, fecha o diálogo e encerra esse tratamento. O mesmo evento não continua até o fechamento do menu mobile, evitando sobrescrever o foco de `locOpen`. Menu previamente aberto permanece aberto; seu fechamento independente por Escape continua funcionando.
- Quatro HTML públicos: favicon SVG local por `<link rel="icon">`, reutilizando integralmente `medicamento-placeholder.svg`, que já contém a identificação PHARMAFIND e as cores do projeto. Nenhuma imagem, marca ou identidade nova foi criada; o SVG não foi modificado.

Não houve alteração de CSS/layout, dados, backend, banco, seed, SPEC, contratos ou outras funcionalidades.

## Execução e estado testado

Mesmo ambiente da homologação anterior: Windows, Python 3.13 e Brave headless/Chromium `158.0.8127.92`, com perfis temporários separados, servidor em loopback e sem GPS real. [Manifesto do estado testado](estado-testado.json), HEAD `54f8a4ab467686bd1921daa31486bd03599bb4bb`; SHA-256 do diff antes da documentação: `d8fd4812e08d859745d49e92bb2480c92c0aa42648f097e44f54674efcb8a480`.

Roteiro existente reaproveitado, sem novas dependências: [cópia executada](roteiro_brave.py). A opção `--correcoes` separa as saídas do histórico. Uma tentativa de iniciar o perfil do Brave encontrou bloqueio temporário de `DevToolsActivePort`, antes de executar testes; repetida com sucesso, sem mudança na aplicação. A tentativa incompleta não foi somada.

| Grupo reexecutado | Aprovadas | Reprovadas |
|---|---:|---:|
| Funcional, responsividade e cenários completos | 216 | 0 |
| Sticky e navegação mobile durante rolagem | 169 | 0 |
| Acessibilidade e contraste adicionais | 17 | 0 |
| Inspeções técnicas/referências | 13 | 0 |
| Compatibilidade com seed oficial | 4 | 0 |
| Oito comandos técnicos da homologação | 8 | 0 |
| Integridade durante os testes | 1 | 0 |
| **Total** | **428** | **0** |

**As seis verificações anteriormente reprovadas passaram**, sem serem substituídas por asserções mais fracas: [comparação antes/depois](reteste-seis.json). Os quatro retornos de foco foram executados novamente em `index`, `consulta`, `como-funciona` e `sobre`.

[Consolidado com esperado/obtido](resultado-consolidado.json), [suíte funcional](browser/report.json), [sticky](sticky/report.json), [acessibilidade](acessibilidade/report.json), [checks técnicos](tecnico-checks.json), [seed](seed-checks.json) e [comandos/saídas](comandos-tecnicos.json).

Pesquisa por botão/Enter, termos parciais/maiúsculos/vazios/inexistentes, seis medicamentos, preços/indisponibilidade/empates, limpeza da seleção, CEP, GPS negado/indisponível, Tab/Shift+Tab/Escape, saltos e fallback continuaram aprovados. Larguras 320, 390, 768, 1280 e 1920 px reexecutadas. Conferidas **71 referências locais**, incluindo as quatro referências novas ao favicon. Favicon respondeu HTTP 200 em todas as páginas; nenhum 404 de `favicon.ico` registrado nas novas execuções.

**Zero erros JavaScript.** A única resposta de erro de rede na execução funcional foi o HTTP 404 de `missing-u10-test.png`, solicitado intencionalmente para confirmar o fallback. Não houve eventos `Network.loadingFailed`. `node --check frontend/script.js`, `node --check frontend/consulta.js` e `git diff --check` passaram.

## Evidências das correções

- [Sobre: texto sem quantidade incorreta](browser/finding-catalog-count.png).
- [Como funciona: CTA sem filtros inexistentes](browser/finding-filters.png).
- Foco no acionador após Escape, com menu preservado: [inicial](acessibilidade/index-focus-after-escape.png), [consulta](acessibilidade/consulta-focus-after-escape.png), [como funciona](acessibilidade/como-funciona-focus-after-escape.png), [sobre](acessibilidade/sobre-focus-after-escape.png).
- Capturas das cinco larguras, diálogos, seis medicamentos e sticky nas subpastas `browser/`, `acessibilidade/` e `sticky/`; resultados da tentativa de zoom em [zoom-tentativa.json](browser/zoom-tentativa.json).

## Limitações e parecer

Zoom real em 200% permanece não comprovado pelo headless; leitor de tela, outros navegadores e dispositivos físicos continuam pendentes. As verificações não homologam API/MySQL, distância real, motor econômico ou histórico. A inspeção de evidências não substitui revisão humana.

**APTO para publicação das alterações do frontend demonstrativo e revisão independente.** H01–H04 da homologação anterior foram tratados; não restam reprovações nas 428 verificações reexecutadas. Revisão humana e aceite final permanecem pendentes. Sem commit, push ou merge.

Reprodução nesta máquina, a partir da raiz, preservando saídas anteriores antes de sobrescrever esta pasta:

```powershell
python -u docs/evidencias/u10/homologacao/correcoes/roteiro_brave.py --homologacao --correcoes
python -u docs/evidencias/u10/homologacao/correcoes/roteiro_brave.py --homologacao --correcoes --navigation-only --sticky-only
python -u docs/evidencias/u10/homologacao/correcoes/roteiro_brave.py --homologacao --correcoes --a11y-extra
```
