# ADR 005 — Localização opcional e distância em linha reta

- **Status:** **Aceita para comportamento de produto**; mapa de teste U01 autorizado e versionado nesta branch, integração/fórmula ainda pendentes.
- **Data de registro:** 12/11/2026; **mapeamento U01:** 17/11/2026.

## 1. Contexto

O PharmaFind deve permitir comparar preços mesmo sem localização. O contexto define CEPs de teste da região do Gama ou GPS consentido. Antes desta etapa U01, os CEPs/pontos não haviam sido selecionados. ViaCEP não fornece latitude/longitude. A distância pretendida não é um percurso por vias.

## 2. Decisão

**[CONFIRMADO]** A localização é **opcional**. Quando houver coordenadas do visitante e da farmácia, mostrar distância **aproximada em quilômetros, em linha reta**. O GPS só será solicitado por ação do usuário e mediante permissão do navegador. CEPs serão aceitos **somente conforme tabela de testes mapeada previamente**. Se não houver localização ou se ela falhar, manter a comparação de preços; jamais inventar distância ou rota.

**[PROPOSTA]** Calcular distância pelo algoritmo de Haversine, arredondar em duas casas e, quando o usuário pedir distância mas ela for indisponível, aplicar ordenação por preço com aviso. Contrato previsto em [`../API.md`](../API.md).

**[MAPEAMENTO U01 AUTORIZADO EM 17/11/2026]** Utilizar `database/seeds/ceps-teste.json`
como fonte única da pequena lista local, sem nova tabela ou endpoint. A U05/U02 deverá
carregar o JSON no backend; isso ainda não foi implementado. Entradas: `72429005`
(IFB Gama), `72444240` (referência pública UnB Gama) e `72620100` (IFB Recanto das Emas),
confirmadas em páginas institucionais indicadas no arquivo.

Cada entrada associa o CEP a **um ponto representativo de teste**, não ao centro postal
ou a todo endereço: os pontos do Gama/Ponte Alta e Recanto são fixtures definidas
manualmente; o do Setor Leste arredonda o ponto publicado pelo CPL/UnB. Campos de origem,
URLs e data de consulta distinguem as fontes. As farmácias da seed têm outros pontos
sintéticos e endereços explicitamente fictícios; a farmácia 2004 não tem coordenadas.
Não há vínculo das instituições reais com farmácias ou ofertas. Ver [fontes e limitações](../../database/seeds/README.md#ceps-e-pontos-de-teste).

## 3. Justificativa

A abordagem evita dependência de serviços pagos/instáveis, respeita consentimento e é compatível com o prazo. Coordenadas de farmácias fictícias e CEPs de teste permitem validar contas geometricamente sem alegar geolocalização universal.

## 4. Alternativas consideradas

- ViaCEP sozinho para distância: inadequado, pois não retorna coordenadas.
- Geocodificação arbitrária de qualquer CEP: complexidade e dependência externa desnecessárias ao MVP.
- Rotas/tempo de deslocamento por mapas: fora do escopo e não equivalentes à distância em linha reta.
- Tornar CEP obrigatório: contraria a decisão do grupo.

## 5. Consequências

A lista e a origem dos pontos estão documentadas; a integração deverá consultar somente as entradas previstas. Deve tratar GPS negado, CEP não mapeado e coordenadas ausentes, testar a fórmula e exibir que a distância não corresponde a trajeto ou tempo de viagem. Não armazenar permanentemente o GPS do visitante. A U01 prepara dados; não comprova CT09/CT13 fim a fim.

## 6. Status da decisão

**Aceita:** localização opcional, consentimento, mapeamento limitado e linha reta. **Autorizado na U01:** JSON e pontos demonstrativos documentados; validações SQL de CEPs/coordenadas passaram na suíte ampliada ([evidência](../../database/tests/RESULTADOS.md)). **Pendente:** integração U05/U02, execução dos fluxos e revisão da fórmula/arredondamento/desempate. Não afirmar que a localização já funciona na aplicação.

**Complemento U01/#33 (23/11/2026):** o banco passou a rejeitar CEP que não seja NULL ou oito
dígitos e coordenadas fora dos limites ou parcialmente preenchidas. Ausência de ambas continua
válida. Isso não calcula distância nem implementa geolocalização. O MVP não possui autenticação
nem cadastro; não se persistem coordenadas de visitantes em uma tabela USUARIO.
