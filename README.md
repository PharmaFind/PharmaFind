# PharmaFind

> **O melhor preço, de um jeito mais simples.**

Projeto acadêmico de Programação Web — Análise e Desenvolvimento de Sistemas, UNICEPLAC.  
Professor: **Romes Heriberto Araújo**.  
Repositório: <https://github.com/PharmaFind/PharmaFind>.

## Como começar a desenvolver (U08)

**Primeira vez no projeto?** Leia o [Manual de instalação, Git e agentes](docs/GUIA-ONBOARDING-AGENTES.md). Ele explica: **clone/pull da `develop` do repositório oficial**, ferramentas Windows/PowerShell (Git, Java 21, MySQL e VS Code; Node/npm opcionais, não exigidos pelo frontend aprovado), instalação do **Codex** e o **prompt-padrão** que lê os arquivos MD e pergunta a Issue antes de programar.

Não comece pela `main`; atualize a `develop` e crie uma branch `feature/<numero-da-issue>-descricao` apenas depois de escolher a tarefa. O agente deve **mostrar o plano e aguardar aprovação** antes de editar arquivos.

## 1. Visão do produto

O **PharmaFind** é uma aplicação web de pesquisa de medicamentos e comparação de ofertas de farmácias **fictícias**. Nesta etapa, os dados representam o **Gama (DF) e arredores**. O visitante pesquisa, seleciona um medicamento/apresentação específica, consulta suas ofertas e compara preços. Se optar por informar localização, pode visualizar a distância **aproximada em linha reta**.

O sistema **não recomenda tratamentos, não vende, não reserva, não processa pagamentos e não disponibiliza ofertas comerciais reais**. Os preços, históricos e farmácias desta demonstração são artificiais e não podem ser usados como referência para compras.

## 2. Entrega e escopo

**Entrega final informada pela equipe: 30/11/2026 (segunda-feira).** A antiga previsão de 19/11 foi substituída. A etapa intermediária de governança e documentação ocorreu em 12/11/2026.

### Fluxo central (prioridade de implementação)

- Pesquisar nome completo/parcial e **selecionar o ID exato** do medicamento antes de mostrar ofertas, sem misturar dosagens/apresentações.
- Listar preço, farmácia, disponibilidade, endereço e horário quando cadastrados.
- Identificar ofertas **indisponíveis**, mas excluí-las de menor preço, média, economia e ranking das disponíveis.
- Calcular menor preço, média aritmética, economia potencial entre a maior e a menor oferta válida e ranking por menor preço.
- Permitir comparar sem localização; CEP de teste mapeado ou GPS consentido permite distância aproximada **em linha reta**, sem rotas ou previsão de deslocamento.
- Tratar medicamento sem oferta, todas indisponíveis, busca vazia, CEP não mapeado, GPS negado e falhas de integração.

### Funcionalidades adicionais incluídas no planejamento

- **Histórico de preços com gráfico (U09):** registros fictícios persistidos por medicamento e farmácia; evolução temporal, variação nominal e percentual quando calculáveis. Implementar **depois de assegurar o fluxo principal**, sem previsões ou scraping. [Issue #19](https://github.com/PharmaFind/PharmaFind/issues/19).
- **Revisão integral do frontend (U10):** auditar páginas, responsividade, navegação, acessibilidade e **as observações reais do professor**, ainda a registrar na Issue antes de afirmar correções. [Issue #20](https://github.com/PharmaFind/PharmaFind/issues/20).

**Gestão de escopo em 23/11:** não há congelamento formal do escopo. U09 (histórico/gráfico) e U10 continuam no planejamento; priorizar integração de busca e comparação. Ampliações devem ser registradas em Issue e validadas com PO/equipe quanto a prazo, dependências e evidências. **Responsáveis U02–U07 estão pendentes de validação.**

**Fora da entrega:** autenticação/cadastro no fluxo público, painel administrativo de farmácias, pagamentos, pedidos, integração automática de preços reais, recomendações clínicas, favoritos, alertas, previsão de preços, score combinado preço/distância, geocodificação de qualquer CEP e rotas por ruas.

## 3. Estado do código — última inspeção em 23/11/2026

| Componente | Estado **verificado por inspeção de arquivos** |
|---|---|
| Frontend | Páginas HTML/CSS/JavaScript e busca demonstrativa com dados fixos em `frontend/consulta.js`. **Ainda não consome API Java** (o frontend estático HTML/CSS/JS foi mantido como escolha). |
| Banco MySQL | Esquema, migração e carga demonstrativa com 6 medicamentos, 4 farmácias e 12 ofertas; três CEPs mapeados em JSON. Suíte ampliada, proteção da limpeza, inicialização e reaplicação passaram no MySQL 8.0.45, com sete booleanos em `1` e três hashes preservados ([evidência](database/tests/RESULTADOS.md)). Integração Java e revisão humana pendentes. Veja [instruções do banco](database/README.md). |
| Backend Java / Spring Boot | **Não implementado** na árvore consultada. |
| API, comparação persistida, distância calculada e gráfico | **Planejados, não implementados** na integração atual. |
| Testes, agentes e ambiente | Builds e testes integrados Java/frontend ainda não existem. `AGENTS.md` documenta orientações para agentes, **não comprova um agente instalado**. |
| Governança GitHub | `main` e `develop` protegidas por regras de PR/revisão. PRs #5–#8 foram integrados à `develop`; PR [#9](https://github.com/PharmaFind/PharmaFind/pull/9) foi **aprovado pela Tainá e integrado à `main` em 16/11/2026**. |
| Trabalho rastreado | Unidades U01–U08 em Issues #10–#17, histórico U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19), auditoria frontend U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20) e revisão documental [#18](https://github.com/PharmaFind/PharmaFind/issues/18). Responsáveis de implementação ainda não confirmados. |

Os estados de implementação decorrem da inspeção dos arquivos; o resultado da suíte SQL tem evidência própria vinculada acima. Isso não comprova execução da aplicação integrada.

## 4. Arquitetura escolhida para orientar o desenvolvimento

**Decisão atual da coordenação (23/11/2026):** stack simplificada aprovada para implementação, com revisão humana do PR ainda pendente. A escolha não significa componentes já implementados. A proposta React/Vite de 16/11 foi não adotada para este MVP.

| Camada | Escolha para implementação |
|---|---|
| Frontend | **HTML + CSS + JavaScript**, reaproveitando e corrigindo as páginas existentes; **sem React/Vite** nesta entrega. |
| Backend | **Java 21 + Spring Boot (Spring Web)**, API REST/JSON. |
| Persistência | **Spring JDBC / JdbcTemplate** + **MySQL**. |
| Build | Maven (Java). Frontend estático, sem obrigatoriedade de npm/Vite. |
| Gráficos | **Chart.js** como opção para U09 em JavaScript puro, ainda sujeito à implementação/testes. |
| Testes | JUnit/Spring Boot Test para backend; testes JavaScript e de interface a definir na U07. |
| Organização | GitHub Issues, Kanban, branches `feature/*`, PR para `develop`, revisão humana. |

As versões exatas do Spring Boot e as configurações de execução serão documentadas quando definidas e verificadas. O frontend deverá consumir a API descrita em [docs/API.md](docs/API.md). As decisões estão explicadas nos [ADRs](docs/ADR/), em especial [ADR 001](docs/ADR/001-arquitetura.md), [ADR 004](docs/ADR/004-backend-java.md) e [ADR 006](docs/ADR/006-frontend-react.md), que registra a não adoção de React no MVP.

## 5. Como executar **o que realmente existe**

### Frontend legado demonstrativo

```bash
git clone https://github.com/PharmaFind/PharmaFind.git
cd PharmaFind
git switch develop
```

Abra `frontend/index.html` no navegador ou use um servidor estático local, por exemplo o **Live Server** do VS Code, apontando para `frontend/`. A página `frontend/consulta.html` usa uma lista fixa em `frontend/consulta.js`, ainda sem acesso HTTP ao backend. Os botões de oferta são demonstrativos. Alguns elementos de autenticação/CEP pertencem à interface legada e serão revisados em U06/U10.

**Ainda não existem comandos reais para iniciar Spring Boot ou testes integrados.** Eles serão acrescentados quando os respectivos projetos forem implementados e seus comandos executados por outro integrante.

### Esquema MySQL isolado

O script `database/PharmaFindDB.sql` define tabelas, **mas não cria o banco nem insere registros**. Requer MySQL **8.0.16+**, InnoDB e conexões em modo estrito/UTC. Com MySQL local e permissão adequada:

```bash
mysql -u root -p -e "CREATE DATABASE pharmafind CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p pharmafind < database/PharmaFindDB.sql
```

Execute a criação somente em banco novo. Para banco existente, siga a migração em duas etapas, o preenchimento explícito da disponibilidade e a preservação das datas desconhecidas em [database/README.md](database/README.md), que também documenta os testes isolados. Para criar `pharmafind_demo` com o esquema e a massa fictícia, use `database/Inicializar-Demonstracao.cmd`; consulte [cenários, fontes e reexecução](database/seeds/README.md). Os CEPs/pontos de teste estão em JSON para a futura U05, ainda sem integração Java. Nenhum comando sobe aplicação integrada; histórico permanece com a U09.

## 6. Organização do repositório

```text
PharmaFind/
├── .github/                # Templates de Issue e PR
├── .vscode/                # Configuração de desenvolvimento existente
├── frontend/               # Páginas HTML/CSS/JS a adaptar ao fluxo com API
├── database/
│   ├── PharmaFindDB.sql    # Esquema de instalação sem seed
│   ├── migrations/        # Evolução do esquema legado, sem presumir disponibilidade/data
│   ├── seeds/             # Massa SQL fictícia e mapa JSON de CEPs documentados
│   ├── tests/             # Testes SQL isolados e runner PowerShell
│   ├── Inicializar-Demonstracao.cmd # Banco novo pharmafind_demo ou reaplicação da carga
│   └── README.md          # Instalação, migração e testes do banco
├── docs/
│   ├── GUIA-ONBOARDING-AGENTES.md  # Preparação da equipe e prompt Codex
│   ├── API.md              # Contratos HTTP/JSON propostos
│   ├── SPEC.md             # SPEC v1.1, refinamento documental
│   └── ADR/                # Decisões 001 a 006 (ver status de cada ADR)
├── AGENTS.md               # Orientações para agentes, não instalador de IA
├── CONTRIBUTING.md
├── CONTEXTO.md
└── README.md
```

**Ainda não existe diretório de implementação Java e as páginas HTML/CSS/JS ainda precisam consumir a API** nesta verificação. O layout de pastas será atualizado pelas Issues U02/U06, em vez de descrever uma estrutura fictícia agora.

## 7. Equipe

| Integrante | Papel informado |
|---|---|
| Lucas Marques (`@lucasmarques07`) | Scrum Master, governança e apoio ao banco |
| Tainá (`@tainayyxy`) | Desenvolvimento |
| Everton (`@MrEve3`) | Desenvolvimento; GitHub confirmado em 16/11 |
| Lucas dos Santos Bezerra (`@Lucasdsantosb`) | Desenvolvimento |
| Júlia Gabrielle | Análise de requisitos |
| Roberto Carlos | Product Owner |

Papéis não equivalem a atribuição automática das Issues. Cada responsável será designado **após confirmar com o time**.

## 8. Trabalho, rastreabilidade e documentos

- [Documento de Visão — versões históricas e evolução](docs/visao/README.md): versões de setembro e outubro de 2026, com rastreabilidade até a SPEC e os ADRs.

- [Issues de implementação #10–#17](https://github.com/PharmaFind/PharmaFind/issues), U09 [#19](https://github.com/PharmaFind/PharmaFind/issues/19), U10 [#20](https://github.com/PharmaFind/PharmaFind/issues/20) e atualização da SPEC v1.1 [#18](https://github.com/PharmaFind/PharmaFind/issues/18).
- [CONTEXTO.md](CONTEXTO.md): situação e decisões; [SPEC.md](docs/SPEC.md): requisitos e testes; [API.md](docs/API.md): contratos propostos.
- [ADRs](docs/ADR/): escolhas e suas justificativas; [AGENTS.md](AGENTS.md): instruções para agentes; [CONTRIBUTING.md](CONTRIBUTING.md): contribuição e revisão.
- [Guia de instalação e preparação dos agentes (U08)](docs/GUIA-ONBOARDING-AGENTES.md): manual Windows/PowerShell, versões, solução de problemas, teste do Codex e fluxo para os integrantes. **Guia publicado na `develop` pelo [PR #23](https://github.com/PharmaFind/PharmaFind/pull/23) e aprimorado na U08.**
- Fluxo de entrega: **Issue → feature/* → PR para develop → revisão humana → merge**; entregas estáveis vão à `main` por PR revisado.

A documentação será atualizada conforme mudanças efetivamente implementadas. **Nenhuma aprovação de PR demonstra, por si só, que a aplicação ou testes integrados funcionam.**

**Atualização documental:** decisão de stack da coordenação em 23/11/2026, sob revisão no PR correspondente à [Issue #30](https://github.com/PharmaFind/PharmaFind/issues/30). Sincronização da U01 entre `main` e `develop` concluída pelo PR #29, integrado em 23/11/2026.
