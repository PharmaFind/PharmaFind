# Guia de contribuição — PharmaFind

Este guia padroniza contribuições dos integrantes do PharmaFind. Seu objetivo é facilitar o trabalho de estudantes e manter **histórico real de decisões, alterações, testes e revisões**, conforme a abordagem SDD da disciplina.

## 1. Antes de começar

1. Consulte o [CONTEXTO.md](CONTEXTO.md) para entender o escopo do MVP e decisões confirmadas.
2. Consulte a [SPEC](docs/SPEC.md), especialmente requisitos, critérios de aceite e restrições da unidade a desenvolver; a [API](docs/API.md) contém **contratos propostos**.
3. Verifique se já existe uma [Issue](https://github.com/PharmaFind/PharmaFind/issues) relacionada. Caso não exista, crie uma Issue pequena com objetivo, responsável **efetivamente disponível** e critérios de aceite verificáveis.
4. Caso o pedido altere o comportamento acordado, proponha a mudança na SPEC e submeta-a à revisão **antes** de implementar; não reinterprete decisões de produto sozinho.

## 2. Branches

| Branch | Função | Como recebe mudanças |
|---|---|---|
| `main` | Versão de referência estável | PR revisado vindo de `develop` |
| `develop` | Integração do trabalho da equipe | PR revisado vindo de `feature/*` |
| `feature/<issue>-<descricao>` | Trabalho isolado de uma Issue | Commits do responsável e PR para `develop` |

Uma branch histórica chamada `feature/estrutura-documentacao` foi criada antes da convenção com número. Ela não precisa ser renomeada para fabricar rastreabilidade retroativa.

**Exemplos de nomes para futuras branches:** `feature/12-busca-medicamentos` (U03, Issue #12), `feature/13-motor-precos` (U04, Issue #13), `feature/15-interface-react` (U06, Issue #15) e `feature/17-ambiente-agentes` (U08, Issue #17). São **exemplos de nomenclatura, não declaração de branches existentes**. O número deve corresponder à **Issue real da tarefa**, nunca ao número da unidade ou de um PR. O prefixo `fix/`, se usado, depende de acordo da equipe.

**Não faça push direto em `main` ou `develop`.** A ruleset ativa exige PR e uma aprovação em ambas.

### Validação automática do destino do Pull Request

O workflow `.github/workflows/validar-fluxo-pr.yml` verifica a convenção do ADR 002 em PRs direcionados a `main` e `develop`:

- `feature/<numero-real-da-issue>-<descricao>` **→ `develop`** para desenvolvimento;
- `develop` **→ `main`** para promoção de uma versão estável.

Uma tentativa de `feature/*` diretamente para `main`, ou de outra origem para `develop`, recebe **checagem vermelha**. O workflow não faz merge, não aprova código e não substitui revisão humana. O nome da branch precisa conter o número da Issue; exceções justificadas exigem decisão e alteração revisada desta política, sem bypass informal.

**Ativação do bloqueio efetivo:** a existência do workflow, sozinha, **não impede merge**. Após sua integração e execução bem-sucedida nas branches protegidas, o administrador precisa acrescentar o check `Validar origem e destino` como **required status check** na ruleset `Protecao main e develop`, conferindo que o check realmente aparece para PRs direcionados a ambas as branches. Não exigir um check antes de ele existir e ter sido executado, para evitar travar os PRs. A integração excepcional do PR #29 (`main` → `develop` para corrigir o PR #27) deve acontecer **antes da ativação** desse check.

O GitHub continua exigindo pelo menos uma aprovação de outro integrante e resolução de conversas. O mantenedor deve revisar também a opção de **descartar aprovações obsoletas quando novos commits são enviados**; hoje essa proteção adicional não está habilitada.

## 3. Passo a passo pelo Git

Use os comandos a seguir **depois de criar a Issue** (substitua o número e o nome):

```bash
git clone https://github.com/PharmaFind/PharmaFind.git
cd PharmaFind
git switch develop
git pull origin develop
git switch -c feature/12-busca-medicamentos
# Edite apenas os arquivos necessários para sua Issue.
git status
git add frontend/consulta.js  # exemplo: ajuste para os arquivos da sua Issue
git commit -m "feat: implementar busca de medicamentos"
git push -u origin feature/12-busca-medicamentos
```

Se o repositório já estiver clonado, comece em `git switch develop` e `git pull origin develop`. Caso `git add frontend/consulta.js  # exemplo: ajuste para os arquivos da sua Issue` gere dúvida, use `git status` para selecionar somente os arquivos alterados pela tarefa; não envie senhas nem configurações locais particulares.

Depois abra **Pull requests → New pull request** no GitHub e selecione **base: `develop`** e **compare: sua `feature/*`**.

## 4. Commits claros

Sugestão de convenção simples, sem exigência de ferramenta extra:

- `feat: adicionar consulta de ofertas`
- `fix: impedir média com ofertas indisponíveis`
- `docs: documentar contrato de comparação`
- `test: cobrir caso sem ofertas disponíveis`
- `refactor: separar cálculo de preço da resposta HTTP`
- `chore: ajustar estrutura do projeto`

Prefira commits pequenos e descritivos. Nunca registre resultados de testes que não foram executados.

## 5. Desenvolvimento orientado pela SPEC (V.E.R.)

Antes de codificar, confira três coisas:

- **V — Verificação:** qual teste, conferência ou evidência objetiva demonstra que a tarefa está correta?
- **E — Escopo:** quais arquivos/componentes estão autorizados na Issue? O que **não** será feito?
- **R — Restrições:** quais regras de negócio e decisões não podem ser quebradas? Exemplo: uma oferta indisponível continua aparecendo, mas não entra na média (RN02/RN07 da SPEC).

Se a implementação exigir uma regra nova, assinale-a como **proposta** na discussão e, após aprovação, atualize a SPEC/ADR pertinente. Não publique uma `SPEC v1.1` sem mudança verdadeira, motivo e PR.

## 6. Issues e PRs

Para novas funcionalidades, utilize `.github/ISSUE_TEMPLATE/feature.md`. Para defeitos, `.github/ISSUE_TEMPLATE/bug.md`.

Ao abrir o PR, preencha `.github/PULL_REQUEST_TEMPLATE.md`:

1. Explique **o que mudou** e **por quê**, indicando a Issue e os requisitos afetados.
2. Informe como validar o comportamento. Se ainda não há testes automatizados, registre **exatamente qual verificação manual foi realizada**; não use “testado” genericamente.
3. Peça revisão de **outra pessoa disponível**. O autor do PR não deve aprovar o próprio trabalho como substituto de revisão independente.
4. Corrija pontos levantados e resolva as conversas de revisão antes do merge.
5. Só faça merge quando a revisão, os critérios de aceite e as verificações aplicáveis estiverem atendidos.

Use `Closes #12` **apenas** quando o PR realmente resolver integralmente a Issue. Em PRs parciais use `Refs #12`, para não fechar trabalho incompleto.

## 7. O que o revisor deve avaliar

- A implementação respeita a SPEC e **não incluiu funcionalidades fora do MVP**?
- Regras importantes seguem válidas: não misturar medicamentos/dosagens; excluir ofertas indisponíveis das estatísticas; tratar sem resultado; localização opcional.
- Houve validação de entrada, consultas SQL parametrizadas quando aplicáveis e tratamento de erros?
- Há evidência suficiente dos testes executados e de casos de borda? Se a infraestrutura ainda não existir, o PR informa claramente essa limitação?
- O código alterado ficou compreensível e não removeu recursos de outros integrantes por acidente?
- O README, a API, a SPEC ou um ADR precisam ser atualizados para refletir a mudança?

A aprovação é uma ação humana registrada no GitHub. **Não simule revisões ou atividade para preencher a avaliação.**

## 8. Conflitos e trabalho simultâneo

Antes de iniciar, confira se alguém já está mexendo nos mesmos arquivos. Combine divisões de responsabilidade na Issue. Para atualizar uma branch de trabalho, verifique primeiro se há alterações locais não salvas; depois atualize a referência de `develop` e integre-a com cuidado:

```bash
git fetch origin
git switch feature/12-busca-medicamentos
git merge origin/develop
```

Se surgirem conflitos, converse com o responsável pelo outro trecho, preserve o código necessário de ambos e faça um commit de resolução. Não use `git push --force` para “resolver” problemas na branch alheia e nunca reescreva o histórico de `main`/`develop`.

## 9. Definição de pronto (DoD)

Uma tarefa somente pode ser considerada **concluída** quando:

- [ ] Seu comportamento está alinhado com os requisitos e os critérios de aceite acordados.
- [ ] A implementação respeitou o escopo e as restrições da Issue.
- [ ] Os casos relevantes foram verificados e **os testes realmente executados** estão descritos.
- [ ] Falhas ou limitações conhecidas estão registradas, sem ocultar pendências.
- [ ] Documentos afetados estão atualizados, ou há uma Issue explícita para o ajuste.
- [ ] O PR recebeu revisão independente exigida e conversas pendentes foram resolvidas.
- [ ] O código foi integrado à branch correta e a Issue/Project foi atualizado conforme o trabalho **real**.

**Exigências adicionais da apostila:** o professor também descreve ambiente reproduzível, agente de IA e test harness com casos de borda. Como esses artefatos **ainda não constam** da versão inspecionada, precisam de Issues próprias e evidências de execução; não são substituídos por este guia.

## 10. Desenvolvimento com agentes de IA

As implementações podem ser produzidas com apoio de **agentes de IA orientados pelos desenvolvedores**, mas cada integrante continua responsável por executar, compreender, integrar e revisar o trabalho. Leia [AGENTS.md](AGENTS.md) antes de utilizar um agente. Agentes não substituem aprovações humanas.

**Stack-alvo informada pela coordenação em 16/11, sob revisão da equipe:** frontend React + **JavaScript (sem TypeScript)** + Vite, aproveitando CSS existente; backend Java 21 + Spring Boot + Spring JDBC + Maven; MySQL. Chart.js será usado no histórico fictício de preços U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19). A auditoria visual/UX de todas as páginas será acompanhada em U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20), com observações exatas do professor a registrar.

- **Não instalar tecnologias desnecessárias** nem presumir estrutura React/Java que ainda não existe. Exigências acadêmicas de JSP/Servlets e outras ferramentas devem ser verificadas antes de consolidar implementação.
- **Coordenar interfaces e contratos** entre frontend/backend/banco conforme SPEC v1.1 e API; informar imediatamente alterações que afetem outros integrantes.
- **Registrar feedback do professor** de forma verificável na Issue #20; não fabricar problemas ou evidências de correção.
- **Testar de verdade e registrar os resultados:** JUnit/Spring Boot Test e Vitest são planejados, ainda não configurados. Testes não executados devem constar como pendentes.
- **Separar o estado:** escolha da stack, implementação, execução de testes e aceite do PR são fatos diferentes. A publicação de documentos não significa que o sistema integrado funciona.
- **Revisão cruzada:** mesmo que uma IA escreva o código, o autor humano do PR não pode ser seu único revisor; manter proteção `main`/`develop` e critérios de aceite.

**Entrega final informada pela equipe: 30/11/2026.** A antiga previsão de 19/11 foi substituída, mas marcos anteriores do GitHub permanecem no histórico.
