# ADR 002 — Governança do GitHub por branches e revisão

- **Status:** **Aceita / observada em operação**.
- **Data da verificação original:** 12/11/2026; **nova verificação:** 16/11/2026.
- **Repositório:** <https://github.com/PharmaFind/PharmaFind>.

## 1. Contexto

O professor exige trabalho rastreável por Issues, branches, Pull Requests e revisões humanas. O repositório foi transferido de uma conta pessoal para a organização **PharmaFind**. A `main` contém commits anteriores à adoção das regras, que não devem ser apagados para produzir conformidade fictícia.

## 2. Decisão

Usar `main` para o estado estável, `develop` para integração e branches `feature/<numero-da-issue>-<descricao>` para novas tarefas. Mudanças de `feature/*` entram em `develop` por PR; integração de `develop` em `main` também passa por PR.

A ruleset **“Protecao main e develop”**, verificada como **ativa**, cobre ambas as branches e exige **um review aprovando**, conversas de revisão resolvidas, bloqueio de exclusão e bloqueio de atualização não fast-forward. A regra foi observada no GitHub, **não inventada**.

**Evidências reais:** [PR #1](https://github.com/PharmaFind/PharmaFind/pull/1) integrou a estrutura inicial à `develop` em 12/11; PRs #5–#8 documentaram e consolidaram conteúdo na `develop`; [PR #9](https://github.com/PharmaFind/PharmaFind/pull/9) foi revisado e aprovado por `@tainayyxy` e integrado à `main` em **16/11/2026**. U01–U08 estão nas Issues #10–#17; revisão documental #18, histórico U09 #19 e auditoria de frontend U10 #20 foram criadas. Issues abertas não significam execução concluída.

## 3. Justificativa

Revisões humanas reduzem alterações acidentais, preservam o histórico e mostram quem propôs e quem aceitou cada mudança. Branches por tarefas ajudam a vincular SPEC, Issues e PRs.

## 4. Alternativas consideradas

- Commits diretos em `main`/`develop`: incompatíveis com a governança atual.
- Uma única branch para toda a equipe: aumenta conflitos e perde isolamento das alterações.
- PRs sem revisão real: não atendem à exigência do professor nem à ruleset ativa.

## 5. Consequências

Cada nova tarefa requer coordenação de revisor disponível; não é possível contar com merge imediato quando ninguém pode aprovar. Se ocorrerem conflitos, a equipe os resolve na branch de trabalho. Um histórico de PRs **não comprova sozinho** que os testes foram executados. O PR #1 era somente estrutura vazia; seu merge não concluiu a SPEC. Não há testes obrigatórios registrados na ruleset consultada.

## 6. Status da decisão

**Aceita / em uso.** A governança foi comprovada por configuração real e pelo PR #1. O usuário demonstrou a criação do **GitHub Project Kanban**, mas detalhes de acessos e movimentação dos cartões não foram verificados por API. Responsáveis serão atribuídos após confirmação real com a equipe. As aprovações e merges devem continuar humanos e rastreáveis.
