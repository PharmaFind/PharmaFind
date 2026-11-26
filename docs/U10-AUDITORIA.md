# U10 — Auditoria do frontend

## Feedback preservado

O feedback literal descrito pela equipe foi geral: o professor considerou o site pouco objetivo, pediu revisão geral e sugeriu referências como a Decolar para experiência de navegação e pesquisa. Nenhum elemento específico foi atribuído ao professor.

As melhorias abaixo são hipóteses e verificações da equipe, não críticas adicionais do professor.

## Evidências antes

- Navegação pública continha links de login/cadastro nas páginas principais.
- A página inicial não possuía busca direta no conteúdo principal do hero.
- Os cartões de consulta usavam `innerHTML` com dados interpolados e um botão demonstrativo por `alert`.
- A localização registrada latitude/longitude no console.
- O menu mobile não tinha estado `aria-expanded` consistente em todas as páginas.

## Correções implementadas

- Busca de medicamento adicionada ao hero e encaminhada para a página de consulta por query string.
- Consulta preserva o termo pesquisado e filtra os medicamentos demonstrativos.
- Seleção de apresentação substitui o botão anterior por ação clara de seleção.
- Conteúdo dinâmico dos cartões passou a ser criado com `textContent`/`replaceChildren`, sem interpolação HTML insegura.
- Login/cadastro removidos da navegação pública nas páginas existentes; páginas legadas não foram excluídas.
- Coordenadas precisas não são mais exibidas no console.
- Menu mobile recebeu `aria-controls`, `aria-expanded`, rótulo dinâmico e fechamento por Escape.
- O estado vazio possui `role="status"`; a área de resultados possui `aria-live="polite"`.
- Adicionado espaço de carregamento para integração futura, sem simular uma resposta da API.

## Verificações executadas

- Servidor estático Node iniciado localmente na porta 4173.
- Página inicial carregada com busca visível na estrutura acessível.
- Página de consulta carregada com 10 cartões demonstrativos.
- Pesquisa por `Dipirona` pela query `?termo=Dipirona` resultou em 1 item e 1 cartão.
- Teste manual automatizado em viewports de 320, 390, 768 e 1280 px: nenhuma rolagem horizontal encontrada.
- Menu mobile em 390 px: abriu corretamente e recebeu `aria-expanded="true"`.
- Popups de localização e CEP receberam semântica de diálogo, rótulo e foco inicial.
- Feedback de localização e CEP substituiu `alert()` por estado `role="status"`.
- Links de salto para o conteúdo principal adicionados às quatro páginas públicas principais.
- Diagnósticos do VS Code no HTML/JavaScript: nenhum erro informado.
- `git diff --check`: nenhum problema informado.
- Busca por `alert()`, `innerHTML`, `console.log`, `login.html` e `conta.html` no diretório `frontend`: nenhum resultado na navegação/teste atual.

## Limitações

- Não há backend/API implementado nesta branch; os dados continuam demonstrativos.
- Não foi possível declarar conformidade WCAG completa.
- Não foi executada inspeção automatizada de contraste ou testes em navegadores adicionais.
- Imagens externas podem ser bloqueadas pelo navegador/rede, sem implicar falha do HTML local.

## Próxima revisão humana necessária

Validar em desktop e mobile, revisar contraste e hierarquia visual, confirmar textos com o professor/equipe e executar uma revisão independente em PR, sem merge nesta branch.
