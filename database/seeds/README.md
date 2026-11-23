# Massa demonstrativa U01 / Issue #10

`demonstracao.sql` é a carga versionada para MySQL com o esquema U01. São **6 apresentações,
4 farmácias fictícias e 12 ofertas**, com IDs e valores fixos. O catálogo utiliza nomes
de medicamentos para demonstrar a pesquisa; não é orientação clínica. Nomes de farmácias,
endereços, preços, disponibilidade, horários e datas são artificiais e não representam
estabelecimentos nem ofertas comerciais reais. Os nomes de instituições nas fontes dos
CEPs servem somente como referências geográficas, sem vínculo com essas farmácias.

## Inicializar e reproduzir

No terminal do repositório, o comando abaixo cria **um banco novo `pharmafind_demo`**,
aplica `PharmaFindDB.sql` e a carga, solicitando a senha do `root` somente no terminal:

```powershell
.\database\Inicializar-Demonstracao.cmd 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
```

O cliente usa `127.0.0.1:3306`, modo em lote e parada no primeiro erro. Primeiro consulta
a existência do alvo sem alterar registros; depois abre a conexão de carga. Cada ação
solicita a senha duas vezes, sem armazená-la. O SQL temporário
não contém credenciais e é removido ao fim. **Se o banco já existir, a criação falha
antes de selecionar ou modificar esse banco.** Não há `DROP DATABASE` no inicializador.

Para executar novamente **somente a carga** nesse banco, depois de verificar que se trata
da sua demonstração local já inicializada:

```powershell
.\database\Inicializar-Demonstracao.cmd 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' --reaplicar
```

A carga idêntica não duplica dados nem atualiza preços/datas. Só registros ausentes
são inseridos. Se algum ID, conteúdo, par medicamento/farmácia ou cenário da seed conflitar,
a carga falha com `3819` na restrição temporária **`CK_U01_SEED_CONFLITO`**, antes das
inserções nas tabelas da aplicação. Um preço alterado pela equipe é preservado; a seed
não é um comando de reset. Registros de outros IDs e o histórico são preservados.
Não contorne conflitos com `IGNORE`, `REPLACE` ou exclusões: confira o registro e decida
com a equipe se deve manter a base ou usar outra cópia de desenvolvimento.

Também é possível executar `demonstracao.sql` em outro banco de desenvolvimento já
preparado, selecionando-o explicitamente num cliente MySQL. Faça isso **fora de outra
transação**, sem escritas concorrentes e parando no primeiro erro. Não use clientes
configurados para continuar após erros. Ao encontrar um erro numa sessão interativa,
interrompa e execute `ROLLBACK;` antes de investigar. A transação protege as inserções;
tabelas temporárias `u01_seed_*` existem apenas na sessão e não alteram o esquema permanente.

Para uma validação isolada do inicializador, o terceiro argumento aceita exclusivamente
um clone `pharmafind_u01_test_inicializado_<identificador>`, com modo `--criar` ou
`--reaplicar`. Não aceita um nome arbitrário de banco real. Antes de SQL, identifique
os nomes exatos, consulte sua existência com autorização e só crie um clone ausente.
Depois da criação, `tests/verificar-inicializacao.sql` fornece contagens e hashes;
reaplique a massa e compare os hashes. O clone pode permanecer para inspeção.
Esse modo é para testes autorizados e não altera o alvo padrão `pharmafind_demo`.

## Cenários e IDs estáveis

| Medicamento | ID | Ofertas | Caso de demonstração |
|---|---:|---:|---|
| Dipirona 500 mg, 20 comprimidos | 1001 | 3 | Duas disponíveis: R$ 8,99/R$ 10,99; R$ 7,50 indisponível (CT02). |
| Dipirona 1 g, 10 comprimidos | 1002 | 2 | Outra apresentação/ID; inclui oferta em farmácia sem coordenadas (CT03/CT13). |
| Paracetamol 750 mg, 20 comprimidos | 1003 | 3 | Todas indisponíveis (CT06). |
| Ibuprofeno 400 mg, 10 cápsulas | 1004 | 0 | Medicamento sem oferta cadastrada (CT05). |
| Loratadina 10 mg, 12 comprimidos | 1005 | 1 | Única oferta disponível por R$ 12,00 (CT04). |
| Omeprazol 20 mg, 28 cápsulas | 1006 | 3 | Duas ofertas empatadas em R$ 15,90 e outra de R$ 18,50 (CT07). |

Farmácias: `2001` Demo Ponte Alta, `2002` Demo Gama Leste, `2003` Demo Recanto e `2004`
Demo Gama Sul. A última não possui CEP, coordenadas ou horários, para validar informação
ausente. As outras têm coordenadas sintéticas fixas e horários demonstrativos. Ofertas:
IDs `3001`–`3012`, **8 disponíveis e 4 indisponíveis**. Em UTC, todas começam com
`2026-11-12 12:00:00`, uma **data de fixture**, não de coleta real. O automatismo do esquema
atualiza esse instante quando a equipe modifica preço/disponibilidade posteriormente.

Não se insere nada em `USUARIO` ou `HISTORICO_PRECO`. A política de registros históricos
e os dados de evolução pertencem à U09. Esta carga não calcula o resumo da API.

## CEPs e pontos de teste

`ceps-teste.json` é a **fonte única do mapeamento local**, versionada para a U05/U02.
Não cria tabela ou endpoint. O backend futuro deve carregar esse arquivo e consultar a
lista exata, após validar o formato do CEP. A integração Java ainda não está implementada.
Nenhuma consulta externa é necessária para usar a base; GPS continua opcional e depende
de consentimento. Não se grava a localização de visitantes nessa massa.

Cada item possui `cep` (string de oito dígitos), `latitude`, `longitude`, região,
`naturezaCoordenadas`, descrição da origem, URL da fonte do CEP e data da consulta.
`fonteCoordenadas: null` identifica um ponto **definido manualmente para a fixture**,
sem alegar levantamento externo. Os valores estão em graus decimais, convenção WGS84,
com sinal negativo para sul/oeste. A precisão textual não certifica precisão geográfica.

| CEP | Referência que confirma o CEP | Ponto representativo (latitude, longitude) | Origem do ponto |
|---|---|---|---|
| `72429005` | [IFB Campus Gama](https://www.ifb.edu.br/gama/contato) | `-15.9932, -48.0534` | Fixture definida manualmente para o Gama/Ponte Alta. A página confirma o CEP, não essas coordenadas. |
| `72444240` | [CPL/UnB, Campus Gama](https://cpl.unb.br/contato/) | `-15.9893, -48.0425` | Arredondamento a quatro casas do ponto publicado: `-15.989259728169667, -48.042460216971314`. |
| `72620100` | [IFB Campus Recanto das Emas, lista das unidades](https://www.ifb.edu.br/reitori/30807-localizacao-e-contatos-das-unidades-do-ifb) | `-15.9150, -48.0850` | Fixture definida manualmente para Recanto das Emas/Monjolo. A fonte confirma o CEP, não essas coordenadas. |

Fontes consultadas em **17/11/2026**. Esses pontos são referências limitadas de demonstração,
**não centroides oficiais de CEP nem localização exata de todos os endereços**.
Coordenadas das farmácias são outras fixtures sintéticas, não posições dessas instituições.
Distâncias futuras serão aproximadas em linha reta entre os pontos cadastrados, sem
rota ou tempo de deslocamento. Um CEP fora do JSON, como `99999999`, permanece não mapeado;
preços continuam consultáveis conforme o contrato proposto. Não oferecer geocodificação universal.

## Verificação

Execute [o runner de testes](../README.md#testes-reproduzíveis-no-terminal-windows) para
validar carga inicial e repetida, conflitos, preservação de dados e o JSON **em bancos
descartáveis novos e migrados**. Isso não inicializa `pharmafind_demo`.

A suíte ampliada de esquema/migração/seed/CEPs passou no MySQL 8.0.45, em execução
pelo usuário. O inicializador passou na criação e reaplicação de um clone descartável:
sete booleanos em `1` antes/depois e três hashes preservados. Evidências e limitações
em [RESULTADOS.md](../tests/RESULTADOS.md). Dados disponíveis para CT09/CT13 não
comprovam distância calculada: esses fluxos dependem da U05 e da integração HTTP.
