# ADR 005 — Localização opcional e distância em linha reta

- **Status:** **Aceita para comportamento de produto**; detalhes técnicos pendentes.
- **Data de registro:** 12/11/2026.

## 1. Contexto

O PharmaFind deve permitir comparar preços mesmo sem localização. O contexto do grupo define duas origens possíveis: CEPs selecionados para testes na região do Gama e coordenadas do GPS do navegador autorizadas pelo visitante. Não há coordenadas de CEP cadastradas/confirmadas no material; ViaCEP não fornece latitude/longitude. A distância pretendida não é um percurso por vias.

## 2. Decisão

**[CONFIRMADO]** A localização é **opcional**. Quando houver coordenadas do visitante e da farmácia, mostrar distância **aproximada em quilômetros, em linha reta**. O GPS só será solicitado por ação do usuário e mediante permissão do navegador. CEPs serão aceitos **somente conforme tabela de testes mapeada previamente**. Se não houver localização ou se ela falhar, manter a comparação de preços; jamais inventar distância ou rota.

**[PROPOSTA]** Calcular distância pelo algoritmo de Haversine, arredondar em duas casas e, quando o usuário pedir distância mas ela for indisponível, aplicar ordenação por preço com aviso. Contrato previsto em [`../API.md`](../API.md).

## 3. Justificativa

A abordagem evita dependência de serviços pagos/instáveis, respeita consentimento e é compatível com o prazo. Coordenadas de farmácias fictícias e CEPs de teste permitem validar contas geometricamente sem alegar geolocalização universal.

## 4. Alternativas consideradas

- ViaCEP sozinho para distância: inadequado, pois não retorna coordenadas.
- Geocodificação arbitrária de qualquer CEP: complexidade e dependência externa desnecessárias ao MVP.
- Rotas/tempo de deslocamento por mapas: fora do escopo e não equivalentes à distância em linha reta.
- Tornar CEP obrigatório: contraria a decisão do grupo.

## 5. Consequências

A equipe precisa decidir a lista de CEPs reais de teste, sua origem e coordenadas, sem inferir dados de um endereço fictício. Deve tratar GPS negado, CEP não mapeado e coordenadas ausentes, testar a fórmula e exibir que a distância não corresponde a trajeto ou tempo de viagem. Não armazenar permanentemente o GPS do visitante.

## 6. Status da decisão

**Aceita:** localização opcional, consentimento, mapeamento limitado e linha reta. **Pendente:** CEPs/valores de teste e aprovação da fórmula, arredondamento e desempate propostos. Não afirmar que a localização já funciona na `develop`.
