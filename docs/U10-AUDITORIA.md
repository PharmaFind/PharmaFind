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
