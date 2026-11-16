# PharmaFind

> **O melhor preço, de um jeito mais simples.**

**Projeto acadêmico de Programação Web | Análise e Desenvolvimento de Sistemas | UNICEPLAC**  
Professor: **Romes Heriberto Araújo**  
Repositório oficial: <https://github.com/PharmaFind/PharmaFind>

## 1. O que é o PharmaFind

O **PharmaFind** é uma aplicação web para pesquisar medicamentos e comparar ofertas cadastradas de farmácias. Seu objetivo é reduzir o trabalho de consultar estabelecimentos separadamente, permitindo comparar **preços** e, quando o usuário optar por informar uma localização, **distâncias aproximadas em linha reta**.

O público-alvo inicial são consumidores adultos, com uma demonstração situada no **Gama (DF) e arredores**. O PharmaFind **não indica tratamentos, não recomenda medicamentos e não vende, reserva ou recebe pagamentos**. A compra ocorre fora da aplicação.

**Aviso acadêmico:** a versão planejada utiliza **farmácias, endereços e preços fictícios**. Nenhuma oferta exibida deve ser interpretada como uma disponibilidade comercial real.

## 2. MVP previsto para 19/11/2026

O fluxo-alvo é **pesquisar → selecionar um medicamento específico → visualizar suas ofertas → comparar preços → consultar distância opcional**.

- Pesquisar por nome completo ou parcial e selecionar o medicamento, sem misturar dosagens ou apresentações diferentes.
- Mostrar ofertas do medicamento em farmácias fictícias, com preço, disponibilidade, endereço e horário quando cadastrado.
- Exibir menor preço disponível, média aritmética, economia potencial entre a maior e a menor oferta válida e classificação das ofertas disponíveis do menor para o maior preço.
- **Manter ofertas indisponíveis visíveis e identificadas**, mas fora dos cálculos e do destaque de melhor preço.
- Permitir comparação sem localização; opcionalmente, usar **CEPs de teste previamente mapeados** ou GPS do navegador com autorização. A distância em quilômetros será aproximada, **em linha reta**, nunca um trajeto viário.
- Tratar buscas vazias, medicamento sem ofertas, ausência de ofertas disponíveis, CEP fora da base de teste, geolocalização negada e falhas técnicas.

**Fora do MVP:** login/cadastro, pagamento, painel de farmácias, dados reais automáticos, histórico/gráficos de preços, alertas, favoritos e pontuação combinada de preço e distância. O modelo comercial com farmácias parceiras é uma **possibilidade futura**, não uma funcionalidade entregue.

## 3. Situação atual do projeto

**Verificado na branch `develop` em 12/11/2026:**

| Componente | Situação |
|---|---|
| Front-end HTML/CSS/JavaScript | **Existe:** páginas navegáveis e consulta demonstrativa com lista fixa em JavaScript. Ainda não corresponde ao fluxo final de múltiplas ofertas por medicamento. |
| Banco de dados | **Existe o script de estrutura** `database/PharmaFindDB.sql`. Não há massa inicial de demonstração nem integração em execução. |
| Backend Java / API HTTP | **Planejado; não implementado** no repositório inspecionado. |
| Consulta de ofertas por medicamento, estatísticas e localização calculada | **Planejadas; não implementadas** de ponta a ponta. |
| Testes automatizados, agente e Docker | **Não encontrados** no repositório inspecionado. Verificar exigências do professor e acompanhar via Issues. |
| Documentação | A estrutura de arquivos foi criada vazia no PR #1, aprovado e integrado à `develop`; o conteúdo deste pacote é **proposto para revisão e futura publicação**. |

Não existe uma versão integrada Java + MySQL que possa ser executada hoje com um único comando. As instruções seguintes descrevem **apenas os componentes realmente disponíveis**.

## 4. Tecnologias

| Tecnologia | Estado no projeto |
|---|---|
| HTML, CSS e JavaScript | **Em uso** no front-end existente. |
| Pico CSS (via CDN), Google Fonts e imagens externas | **Referenciados** nas páginas atuais; dependem de acesso à internet para carregar esses recursos. |
| MySQL | **Definido** como banco do MVP; existe script SQL de esquema, ainda sem integração de backend. |
| Java | **Definido** como linguagem para backend; implementação pendente. |
| Framework Java (por exemplo, Spring Boot), Maven, JUnit | **Propostas em avaliação**, sem decisão final ou configuração publicada. |

A seção de stack no Documento de Visão é preliminar. As escolhas técnicas serão formalizadas em [ADRs](docs/ADR/).

## 5. Como executar o que já existe

### 5.1 Front-end de demonstração

1. Clone o repositório:

   ```bash
   git clone https://github.com/PharmaFind/PharmaFind.git
   cd PharmaFind
   git switch develop
   ```
2. Abra o arquivo `frontend/index.html` em um navegador moderno, **ou** utilize um servidor local estático (por exemplo, a extensão *Live Server* do VS Code) apontando para a pasta `frontend/`.
3. Navegue até `frontend/consulta.html` e pesquise os itens demonstrativos. A busca e os filtros usam dados fixos em `frontend/consulta.js`.

**Limitações atuais:** o botão “Ver oferta” exibe um `alert` demonstrativo; ainda não há requisições a API Java nem consulta ao banco. Elementos de login/cadastro e localização visíveis no front-end existente **não demonstram o MVP final**. Recursos de GPS no navegador normalmente exigem origem segura (`https://` ou `localhost`), além de consentimento.

### 5.2 Estrutura do banco de dados, isoladamente

Pré-requisito: MySQL instalado e acesso a uma instância local. O script `database/PharmaFindDB.sql` define tabelas, **mas não cria o banco nem insere registros**.

No **MySQL Workbench**, crie um schema de desenvolvimento (por exemplo, `pharmafind`), selecione-o como padrão e execute o conteúdo de `database/PharmaFindDB.sql` **uma única vez**. Alternativamente, no terminal com cliente MySQL:

```bash
mysql -u root -p -e "CREATE DATABASE pharmafind CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p pharmafind < database/PharmaFindDB.sql
```

Os comandos assumem que o schema ainda não existe e que o usuário possui permissão. Para reutilizar um schema já criado, não repita o `CREATE DATABASE` ou o script de `CREATE TABLE` sem avaliar as consequências. **Isso não sobe uma aplicação:** apenas cria a estrutura de tabelas presente no repositório.

## 6. Estrutura do repositório

O conteúdo abaixo distingue **código existente** de **arquivos documentais preparados para inclusão na `develop`**:

```text
PharmaFind/
├── .github/                        # templates de Issue e PR (documentação proposta)
│   ├── ISSUE_TEMPLATE/
│   │   ├── feature.md
│   │   └── bug.md
│   └── PULL_REQUEST_TEMPLATE.md
├── .vscode/
│   └── settings.json
├── database/
│   └── PharmaFindDB.sql            # esquema atual, ainda sem dados de exemplo
├── frontend/                       # HTML, CSS e JS existentes
│   ├── index.html
│   ├── consulta.html
│   ├── consulta.js
│   ├── como-funciona.html
│   ├── sobre.html
│   ├── login.html                   # legado, fora do fluxo-alvo do MVP
│   ├── conta.html                   # legado, fora do fluxo-alvo do MVP
│   ├── script.js
│   ├── auth.js
│   ├── login.js
│   ├── conta.js
│   └── style.css
├── docs/
│   ├── ADR/
│   │   ├── 001-arquitetura.md
│   │   ├── 002-governanca-git.md
│   │   ├── 003-persistencia-demonstrativa.md
│   │   ├── 004-backend-java.md
│   │   └── 005-localizacao.md
│   ├── API.md                       # contratos HTTP propostos
│   └── SPEC.md                      # especificação SDD v1.0 para revisão
├── CONTRIBUTING.md
├── CONTEXTO.md
└── README.md
```

**Nota:** os três ADRs numerados de 003 a 005 são **novos arquivos propostos neste pacote**. `main` ainda não possui esses documentos; a publicação depende de PRs revisados.

## 7. Equipe e responsabilidades

| Integrante | Responsabilidade indicada |
|---|---|
| Lucas Marques Almeida (`@lucasmarques07`) | Scrum Master; governança GitHub e apoio ao banco |
| Tainá do Amaral Melo (`@tainayyxy`) | Desenvolvimento |
| Everton Gabriel da Cunha (GitHub a confirmar) | Desenvolvimento |
| Lucas dos Santos Bezerra (`@Lucasdsantosb`) | Desenvolvimento |
| Júlia Gabrielle da Silva Lima | Análise de requisitos |
| Roberto Carlos Martins | Product Owner; prioridades e aceite |

Funções acadêmicas não equivalem automaticamente a atribuições em Issues. A equipe define responsáveis de acordo com a disponibilidade real.

## 8. Colaboração e documentação

O repositório adota **Spec-Driven Development (SDD)**: antes de implementar uma funcionalidade, a equipe verifica as regras, o escopo e os critérios de aceite na SPEC. As alterações seguem o fluxo **Issue → `feature/*` → Pull Request para `develop` → revisão humana → integração**. Entregas estáveis podem ser promovidas de `develop` a `main` por PR revisado.

A ruleset ativa de `main` e `develop` exige pelo menos **uma aprovação** e resolução de conversas de revisão, além de bloquear exclusão e atualizações não fast-forward. Testes automatizados são uma meta exigida no material acadêmico, **não uma capacidade já existente**.

Documentos de referência:

- [Contexto consolidado e decisões](CONTEXTO.md)
- [Especificação técnica SDD](docs/SPEC.md)
- [Contratos HTTP/JSON propostos](docs/API.md)
- [Decisões arquiteturais e de governança](docs/ADR/)
- [Guia de contribuição](CONTRIBUTING.md)
- [Issues](https://github.com/PharmaFind/PharmaFind/issues) e [Pull Requests](https://github.com/PharmaFind/PharmaFind/pulls)

**Última verificação documental:** 12/11/2026. O README distingue propositalmente plano, código existente e pendências; será atualizado conforme os PRs forem efetivamente integrados.