# Guia de preparação dos desenvolvedores e agentes — PharmaFind

> **Status:** guia inicial da U08 ([Issue #17](https://github.com/PharmaFind/PharmaFind/issues/17)), elaborado em 16/11/2026. **Não significa que as ferramentas foram instaladas ou testadas nos computadores dos integrantes.**
>
> **Entrega final:** 30/11/2026. O guia foi preparado para permitir que a equipe comece sem exigir assinatura paga de IA. O detalhamento final dos comandos de React, Java e MySQL dependerá do código efetivamente entregue.

## Como usar este manual

**Para integrantes novos:** comece pela seção **8.1 (diagnóstico PowerShell)**; instale **somente** as ferramentas ausentes pela seção **8.2**; resolva problemas comuns nas seções **8.3–8.5**; depois siga a seção **3 (clonar e testar o agente)** e a seção **4 (fluxo por Issue)**. Por fim, execute as verificações da seção **8.6**.

**Para o Scrum Master:** acompanhe o checklist da seção **6** e registre as evidências reais na [Issue U08 #17](https://github.com/PharmaFind/PharmaFind/issues/17).

> Os comandos Windows/PowerShell abaixo foram **revisados e parcialmente testados em um computador**. Não se deve assumir que foram executados ou funcionam em todas as máquinas. A execução completa do React + Spring Boot + MySQL ainda depende das unidades de implementação.

## 1. Objetivo: preparar uma vez, desenvolver depois

Cada integrante precisa conseguir (a) clonar o repositório, (b) abrir o projeto no VS Code, (c) utilizar um assistente de programação com sua própria conta, (d) consultar as instruções do projeto, (e) trabalhar em sua própria branch e (f) executar/verificar sua tarefa.

O **Scrum Master** centraliza o guia, a documentação, a divisão do trabalho e a ajuda com configuração. **Cada desenvolvedor** continua responsável por validar o comportamento de sua alteração e solicitar revisão humana no PR. Nenhum integrante deve compartilhar senha, token ou sessão pessoal com outro.

## 2. Ferramentas mínimas

| Ferramenta | Necessidade | Como conferir |
|---|---|---|
| **Git** | Obrigatória para clone, branches e PRs | `git --version` |
| **VS Code** | Editor recomendado; outro editor pode ser usado se tiver suporte equivalente | Abrir o programa e o projeto |
| **Codex (OpenAI)** | Agente recomendado para começar, inclusive com contas ChatGPT Free sujeitas a limites | Abrir extensão Codex e autenticar com a conta própria |
| **JDK 21** | Necessário para implementar/executar o backend Java planejado | `java -version` |
| **Node.js LTS + npm** | Necessário para o frontend React/Vite planejado | `node --version` e `npm --version` |
| **MySQL** | Necessário para executar banco e consultas de integração | `mysql --version` no terminal, se cliente estiver no PATH; senão conferir pela instalação/workbench |
| **Maven ou Maven Wrapper** | Build do backend; **preferir Wrapper quando U02 o adicionar** | `mvn --version` apenas se Maven estiver instalado globalmente |

**Importante:** as ferramentas básicas podem ser instaladas agora. **Versões concretas de Node/Vite/Spring Boot, comandos de start, porta, banco e variáveis** serão fixadas após a implementação de U01/U02/U06 e testes reais. Não copiar comandos de um aplicativo que ainda não existe.

Links oficiais:

- Git: <https://git-scm.com/downloads>
- VS Code: <https://code.visualstudio.com/>
- JDK 21 (Eclipse Temurin): <https://adoptium.net/>
- Node.js: <https://nodejs.org/>
- MySQL: <https://dev.mysql.com/downloads/>
- Extensão Codex para IDE: <https://developers.openai.com/codex/ide/>
- Sobre os planos Codex: <https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan>

## 3. Passo a passo inicial (Windows + VS Code)

1. Instale **Git** e **VS Code** por fontes oficiais. Reinicie o terminal depois da instalação, se os comandos não forem reconhecidos.
2. Abra o VS Code, use **Extensions** (`Ctrl+Shift+X`), procure a extensão oficial **Codex** da OpenAI, instale-a e entre com sua **própria** conta ChatGPT. Verifique a disponibilidade e o limite no próprio produto. Se não estiver disponível na conta, registre a dificuldade; não peça credenciais ou assinatura de outro integrante.
3. Abra um terminal integrado no VS Code (`Terminal > New Terminal`) e execute os comandos abaixo:

```bash
git --version
git clone https://github.com/PharmaFind/PharmaFind.git
cd PharmaFind
git switch develop
git pull origin develop
git status
```

Se já tiver clonado, **não clone de novo**: abra a pasta existente, confira `git status` e atualize `develop` se não houver alterações locais pendentes.

4. Aguarde a integração do [PR #21](https://github.com/PharmaFind/PharmaFind/pull/21), que contém `AGENTS.md`, SPEC v1.1 e ADR 006. Enquanto estiver aberto, as instruções novas **não estarão em `develop`**. Consulte a branch do PR apenas para leitura, sem misturar mudanças não aprovadas às tarefas.
5. Após a integração do PR #21, em `develop` faça `git pull origin develop` e confirme que `AGENTS.md`, `docs/SPEC.md`, `docs/API.md` e `CONTRIBUTING.md` estão presentes.

### Teste de preparação do agente (somente leitura)

Abra a pasta PharmaFind no VS Code e envie ao Codex:

> Leia AGENTS.md, CONTEXTO.md, CONTRIBUTING.md, docs/SPEC.md e docs/API.md. Explique resumidamente o objetivo do PharmaFind, a stack-alvo, o fluxo de Git e as três regras de negócio mais críticas. Informe quais tecnologias **ainda não estão implementadas**. **Não altere arquivos, não execute comandos destrutivos e não faça commits.**

O teste passa quando o agente identifica corretamente o projeto, o uso de React **sem TypeScript** e Spring Boot como stack **planejada**, as restrições de ofertas indisponíveis e as regras de colaboração **sem modificar arquivos**. Verifique `git status` após o teste. Não declarar sucesso antes de executar no computador de cada integrante.

## 4. Fluxo comum para cada Issue

1. O integrante confirma qual Issue assumiu com o Scrum Master.
2. Atualiza `develop` com `git pull origin develop`, em working tree limpa.
3. Cria branch pelo número **real** da Issue, por exemplo:
   ```bash
   git switch -c feature/11-backend-inicial
   ```
4. Instrui o agente a ler os arquivos relevantes, **analisar primeiro** e só implementar dentro do escopo da Issue. Confere alterações com `git diff`.
5. Executa os comandos/testes disponíveis **de verdade**. Se algo não foi executado, relata explicitamente por quê.
6. Commita a branch de trabalho, envia ao GitHub e abre PR para `develop` com Issue, testes reais e limitações.
7. Solicita review de **outra pessoa**. Não enviar alterações diretamente a `main` ou `develop`; não marcar Issue como concluída sem PR/revisão e critérios de aceite.

### Prompt-padrão para iniciar uma Issue

> Você é um agente de programação trabalhando no repositório PharmaFind. Leia AGENTS.md, CONTRIBUTING.md, CONTEXTO.md, docs/SPEC.md, docs/API.md e ADRs relevantes. Minha Issue é **#N, unidade UNN**. Analise os arquivos atuais, identifique dependências e me entregue um plano curto com arquivos previstos, critérios de aceite e como testar. **Não altere arquivos antes de mostrar o plano.** Depois da minha aprovação, implemente **somente** o escopo da Issue na branch `feature/N-descricao`. Não crie funcionalidades fora da SPEC nem invente endpoints, testes, dados históricos, resultados ou decisões. Ao finalizar, mostre diff, comandos realmente executados, resultados, pendências e orientações para abrir PR para `develop`.

Substituir **#N, UNN e feature/N-descricao** pela Issue real. Um agente não dispensa a revisão humana. O desenvolvedor precisa entender as mudanças propostas.

## 5. Segurança e prevenção de retrabalho

- Senhas do MySQL, tokens do GitHub e arquivos `.env` reais **nunca** devem ir para o repositório; quando necessário, incluir somente `.env.example` sem segredos e garantir `.gitignore` coerente.
- Nenhum agente deve alterar as regras da SPEC/API silenciosamente, abrir merge sem review, modificar branch principal ou executar operações destrutivas sem verificação.
- O frontend da U06 e a auditoria U10 devem coordenar arquivos compartilhados; código backend e banco precisam concordar nos mesmos contratos.
- Separar claramente **documentação existente**, **código implementado**, **teste efetivamente realizado** e **recurso planejado**.

## 6. Como validar o preparo de cada integrante

Atribuições e horários só serão registrados após conversa com a equipe.

| Verificação | Integrante A | Integrante B | Integrante C |
|---|---|---|---|
| Git + VS Code funcionam | Pendente | Pendente | Pendente |
| Clonou e abriu o PharmaFind | Pendente | Pendente | Pendente |
| Agente configurado com conta própria | Pendente | Pendente | Pendente |
| Agente leu instruções (sem modificar arquivos) | Pendente | Pendente | Pendente |
| Pode criar branch e abrir PR | Pendente | Pendente | Pendente |

**Não preencher como “concluído” sem confirmação real de cada integrante.** O Scrum Master recolhe evidência curta: comandos de versões, `git status` e resposta do agente; omitir dados pessoais/sensíveis.

## 7. O que ainda falta para concluir a U08

A etapa inicial acima prepara o processo, **mas não fecha a Issue #17**. Serão necessários:

- U01 (#10): configurar schema, dados fictícios, conexão e instruções de banco realmente testadas.
- U02 (#11): criar e executar o projeto Spring Boot com Maven/Wrapper; documentar porta, configuração e comando de execução realmente testado.
- U06 (#15): criar e executar React/Vite, configurar acesso à API e documentar comandos realmente testados.
- U07 (#16): registrar comandos de teste e resultados reais.
- Segundo integrante: repetir procedimento completo a partir de clone limpo.
- Verificar se o professor **exige** Docker, harness ou outra evidência; não instalar infraestrutura extra por presunção.

**Referências do projeto:** [U08 #17](https://github.com/PharmaFind/PharmaFind/issues/17), [PR documental #21](https://github.com/PharmaFind/PharmaFind/pull/21) e [guia de contribuição](../CONTRIBUTING.md).

## 8. Guia prático para Windows / PowerShell (teste real de 16/11/2026)

O primeiro diagnóstico em **um computador do projeto** identificou: **Git funcionando**, **Java 24 instalado (projeto padronizado em JDK 21)**, **Node 22.13.1 presente**, **`npm.ps1` bloqueado pela política do PowerShell** e **comando `mysql` não encontrado (servidor/cliente possivelmente ausente ou fora do PATH)**. **Os testes do piloto estão registrados nas seções 8.4 e 8.5; os demais computadores e a integração do projeto continuam pendentes.**

### 8.1 Diagnóstico que cada integrante deve executar

Abra o **PowerShell** no terminal do VS Code e execute:

```powershell
winget --version
git --version
code --version
java -version
javac -version
where.exe java
node --version
npm.cmd --version
Get-Command mysql -ErrorAction SilentlyContinue
Get-Service -Name "MySQL*" -ErrorAction SilentlyContinue
```

Se `code --version` falhar, isso pode indicar apenas que o comando `code` ainda não entrou no PATH; o editor pode estar instalado. Se `mysql` não for reconhecido, verifique também instalações existentes pelo aplicativo **MySQL Configurator**, painel de programas e diretório `C:\Program Files\MySQL` antes de instalar outra cópia.

### 8.2 Instalação das ferramentas faltantes pelo WinGet

**Não execute todas as linhas se já tiver as ferramentas funcionando.** Instale somente o necessário, com IDs conhecidos:

```powershell
# Instale apenas caso o Git não esteja presente:
winget install --id Git.Git --exact

# Instale apenas caso o VS Code não esteja presente:
winget install --id Microsoft.VisualStudioCode --exact

# JDK 21 para padronizar a API Java 21:
winget install --id EclipseAdoptium.Temurin.21.JDK --exact

# Node.js LTS (apenas se ainda não houver Node compatível):
winget install --id OpenJS.NodeJS.LTS --exact

# MySQL Server (somente se servidor não estiver instalado):
winget install --id Oracle.MySQL --exact --interactive
```

**Atenção:** o pacote `OpenJS.NodeJS.LTS` acompanha a versão LTS mais recente no repositório WinGet, que **pode ser diferente de Node 22**. No primeiro diagnóstico, **Node 22.13.1 já é compatível com o Vite 8** e não precisa ser reinstalado só para ficar com a versão mais nova. A equipe fixará a versão efetivamente testada quando o frontend existir. Confira o pacote com `winget show --id <ID> --exact` antes de instalar; os instaladores podem solicitar permissão de administrador. Após instalar, **feche e reabra o terminal do VS Code**.

**MySQL:** antes de instalar, confira se já existe uma instância configurada e funcionando. Se usar o pacote MSI oficial MySQL 8.4, será necessário **executar o MySQL Configurator** para preparar a instância local, configurar o serviço e definir uma senha segura. Baixar o MSI não garante um servidor executando. Também é possível obter o instalador manualmente em <https://dev.mysql.com/downloads/mysql/>. Não envie a senha do MySQL no chat, no GitHub ou em capturas.

### 8.3 Erro `npm.ps1` bloqueado no PowerShell

Se `node --version` funciona, mas `npm --version` acusa que o script `npm.ps1` não pode ser executado, **o npm provavelmente está instalado**. Tente **sem alterar a política do Windows**:

```powershell
npm.cmd --version
npx.cmd --version
```

Durante o projeto, também se pode usar `npm.cmd install` e `npm.cmd run dev` **depois que existir o projeto frontend com `package.json`**. Não execute esses comandos na raiz do repositório antes de o projeto ser criado.

Alternativamente, use **Command Prompt (cmd.exe)** no VS Code. Somente se o usuário entender a implicação de segurança e o computador for pessoal/não gerenciado, poderá **avaliar** a política atual com `Get-ExecutionPolicy -List`. **Não é necessário mudar a política para fazer o npm funcionar.** Nunca orientar `Bypass` ou `Unrestricted` como correção padrão; políticas corporativas não devem ser contornadas.

### 8.4 Java 24 instalado, mas projeto Java 21

O grupo escolheu **JDK 21 LTS** para o backend. É possível manter outras versões de Java instaladas; **o que importa é a versão ativa de `java` e `javac`**. Ter JDK 21 instalado **não garante** que ele esteja primeiro no `PATH`.

Feche/reabra o VS Code após instalar o JDK e rode:

```powershell
java -version
javac -version
where.exe java
Get-ChildItem -Path "$env:ProgramFiles\Eclipse Adoptium", "$env:LOCALAPPDATA\Programs\Eclipse Adoptium" -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like "jdk-21*" }
```

Se os dois comandos já mostram **21**, essa etapa está pronta **na sessão atual**. Se outro Java for selecionado, use temporariamente a instalação local encontrada, sem desinstalar o Java existente:

```powershell
$jdk21 = Get-ChildItem -Path "$env:ProgramFiles\Eclipse Adoptium", "$env:LOCALAPPDATA\Programs\Eclipse Adoptium" -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like "jdk-21*" -and (Test-Path (Join-Path $_.FullName "bin\java.exe")) } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if ($null -eq $jdk21) {
  Write-Host "JDK 21 nao encontrado. Confira a instalacao." -ForegroundColor Yellow
} else {
  $env:JAVA_HOME = $jdk21.FullName
  $env:Path = "$env:JAVA_HOME\bin;$env:Path"
  Write-Host "Usando: $env:JAVA_HOME"
  java -version
  javac -version
}
```

**Essa solução só altera o terminal atual.** Para uso persistente, configurar `JAVA_HOME` e o `PATH` de usuário no Windows e repetir a verificação após reabrir VS Code. Não alterar o PATH de outros softwares sem necessidade. O backend deverá usar Java 21 e Maven Wrapper `mvnw.cmd` quando a U02 fornecer esses arquivos.

**Evidência do piloto (16/11):** `java -version` retornou **Temurin 21.0.13 LTS** e `javac -version` retornou **21.0.13** em um terminal do responsável. A persistência após reiniciar VS Code **não foi comprovada**.

### 8.5 MySQL existente, serviço parado ou cliente fora do PATH

**Antes de instalar qualquer MySQL, verifique se já existe um servidor configurado.** Uma pasta ou MSI instalado não prova que o serviço está ativo, e versões 8.0 e 8.4 podem coexistir sem que ambas tenham instâncias configuradas.

```powershell
Get-Service -Name "MySQL*" -ErrorAction SilentlyContinue
Get-ChildItem "C:\Program Files\MySQL" -Directory -ErrorAction SilentlyContinue
```

Se já houver o serviço `MySQL80` em `Stopped`, confirme que é uma instalação **sua**, com dados que deseja preservar, antes de mexer nela. Se precisar iniciar, abra PowerShell **como administrador** e execute:

```powershell
Start-Service -Name MySQL80
Get-Service -Name MySQL80
```

Se o serviço não iniciar, registre o erro; **não reinstale nem apague a pasta de dados como primeira medida**.

Para testar o MySQL 8.0 instalado no caminho padrão:

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" --version
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -h 127.0.0.1 -P 3306 -u root -p -e "SELECT @@version AS versao, @@port AS porta, @@datadir AS pasta_dados;"
```

Se a máquina usar **somente MySQL 8.4**, substitua `MySQL Server 8.0` pelo diretório **real** `MySQL Server 8.4` do cliente. O `-p` pede a senha local interativamente; **não colocar a senha no comando, no chat, no README ou em capturas**. O cliente `mysql.exe` não precisa estar no PATH quando executado pelo caminho completo.

**Caso não exista uma instalação configurada:** instale e configure **uma única instância** local de MySQL, definindo porta e senha no MySQL Configurator. Evite criar duas instâncias na mesma porta `3306`. Em caso de instalação antiga com dados, faça backup e combine com o responsável antes de qualquer migração, atualização ou desinstalação.

**Evidência do piloto (16/11):** MySQL80 em **Running**, conexão TCP `127.0.0.1:3306` autenticada e `SELECT` retornando **MySQL 8.0.45** e a pasta de dados configurada. Isso confirma o servidor local de teste, **não a criação das tabelas PharmaFind**. A equipe deve definir e testar uma versão comum do banco antes de declarar o ambiente integrado aprovado.

### 8.6 Conferência final de versões

Depois das instalações e de **reabrir o terminal**:

```powershell
git --version
java -version
javac -version
node --version
npm.cmd --version
where.exe java
Get-Service -Name "MySQL*" -ErrorAction SilentlyContinue
```

Para instalação completa do MySQL, testar também o comando de conexão da seção 8.5. Um comando de versão **não comprova** que React, Spring, banco e testes integrados estão funcionando. Registrar para cada integrante quais comandos funcionaram e quais falharam; **não marcar como aprovado sem execução local**.

**Documentação consultada:** <https://vite.dev/guide/>, <https://learn.microsoft.com/pt-br/windows/package-manager/winget/install>, <https://learn.microsoft.com/pt-br/powershell/module/microsoft.powershell.core/about/about_execution_policies>, <https://dev.mysql.com/doc/refman/8.4/en/windows-installation.html>.
