const medicamentos = [
  { id: 1001, nome: "Dipirona", dosagem: "500 mg", apresentacao: "20 comprimidos" },
  { id: 1002, nome: "Dipirona", dosagem: "1 g", apresentacao: "10 comprimidos" },
  { id: 1003, nome: "Paracetamol", dosagem: "750 mg", apresentacao: "20 comprimidos" },
  { id: 1004, nome: "Ibuprofeno", dosagem: "400 mg", apresentacao: "10 cápsulas" },
  { id: 1005, nome: "Loratadina", dosagem: "10 mg", apresentacao: "12 comprimidos" },
  { id: 1006, nome: "Omeprazol", dosagem: "20 mg", apresentacao: "28 cápsulas" }
];

const farmacias = {
  2001: { nome: "Farmácia Demo Ponte Alta", endereco: "Endereço fictício 01 - Ponte Alta, Gama/DF" },
  2002: { nome: "Farmácia Demo Gama Leste", endereco: "Endereço fictício 02 - Setor Leste, Gama/DF" },
  2003: { nome: "Farmácia Demo Recanto", endereco: "Endereço fictício 03 - Recanto das Emas/DF" },
  2004: { nome: "Farmácia Demo Gama Sul", endereco: "Endereço fictício 04 - Setor Sul, Gama/DF" }
};

const ofertas = [
  { id: 3001, medicamentoId: 1001, farmaciaId: 2001, preco: 8.99, disponivel: true },
  { id: 3002, medicamentoId: 1001, farmaciaId: 2002, preco: 10.99, disponivel: true },
  { id: 3003, medicamentoId: 1001, farmaciaId: 2003, preco: 7.50, disponivel: false },
  { id: 3004, medicamentoId: 1002, farmaciaId: 2001, preco: 14.00, disponivel: true },
  { id: 3005, medicamentoId: 1002, farmaciaId: 2004, preco: 16.00, disponivel: true },
  { id: 3006, medicamentoId: 1003, farmaciaId: 2001, preco: 6.50, disponivel: false },
  { id: 3007, medicamentoId: 1003, farmaciaId: 2002, preco: 7.25, disponivel: false },
  { id: 3008, medicamentoId: 1003, farmaciaId: 2003, preco: 5.99, disponivel: false },
  { id: 3009, medicamentoId: 1005, farmaciaId: 2002, preco: 12.00, disponivel: true },
  { id: 3010, medicamentoId: 1006, farmaciaId: 2001, preco: 15.90, disponivel: true },
  { id: 3011, medicamentoId: 1006, farmaciaId: 2002, preco: 15.90, disponivel: true },
  { id: 3012, medicamentoId: 1006, farmaciaId: 2004, preco: 18.50, disponivel: true }
];

const searchForm = document.getElementById("searchForm");
const searchInput = document.getElementById("searchInput");
const productsGrid = document.getElementById("productsGrid");
const resultsCount = document.getElementById("resultsCount");
const emptyState = document.getElementById("emptyState");
const comparisonPanel = document.getElementById("comparisonPanel");

let medicamentoSelecionadoId = null;

function formatarPreco(valor) {
  return valor.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
}

function criarElemento(tag, classe, texto) {
  const elemento = document.createElement(tag);
  if (classe) elemento.className = classe;
  if (texto !== undefined) elemento.textContent = texto;
  return elemento;
}

function limparSelecao() {
  medicamentoSelecionadoId = null;
  comparisonPanel.hidden = true;
  comparisonPanel.replaceChildren();
}

function atualizarProdutos() {
  const termo = searchInput.value.toLocaleLowerCase("pt-BR").trim();
  const resultados = medicamentos.filter((medicamento) => {
    const texto = `${medicamento.id} ${medicamento.nome} ${medicamento.dosagem} ${medicamento.apresentacao}`;
    return !termo || texto.toLocaleLowerCase("pt-BR").includes(termo);
  });

  productsGrid.replaceChildren();

  resultados.forEach((medicamento) => {
    const card = document.createElement("article");
    card.className = "product-card";

    const conteudo = document.createElement("div");
    conteudo.className = "product-content";
    conteudo.append(
      criarElemento("span", "product-type", `ID ${medicamento.id}`),
      criarElemento("h3", "", `${medicamento.nome} ${medicamento.dosagem}`),
      criarElemento("p", "product-description", medicamento.apresentacao)
    );

    const botao = document.createElement("button");
    botao.type = "button";
    botao.className = "offer-button";
    botao.textContent = "Selecionar apresentação";
    botao.addEventListener("click", () => selecionarMedicamento(medicamento.id));
    conteudo.appendChild(botao);

    card.appendChild(conteudo);
    productsGrid.appendChild(card);
  });

  resultsCount.textContent = `${resultados.length} ${resultados.length === 1 ? "medicamento" : "medicamentos"}`;
  emptyState.hidden = resultados.length !== 0;
  emptyState.textContent = "Nenhum medicamento encontrado.";
}

function pesquisarNovamente(event) {
  event.preventDefault();
  limparSelecao();
  atualizarProdutos();
}

function selecionarMedicamento(id) {
  medicamentoSelecionadoId = id;
  const medicamento = medicamentos.find((item) => item.id === id);
  const ofertasDoMedicamento = ofertas.filter((oferta) => oferta.medicamentoId === id);
  comparisonPanel.hidden = false;
  comparisonPanel.replaceChildren();

  const cabecalho = document.createElement("div");
  cabecalho.className = "comparison-header";

  const identificacao = document.createElement("div");
  identificacao.append(
    criarElemento("h2", "", `${medicamento.nome} ${medicamento.dosagem}`),
    criarElemento("p", "", `ID ${medicamento.id} — ${medicamento.apresentacao}`)
  );

  const voltar = document.createElement("button");
  voltar.type = "button";
  voltar.className = "secondary-button";
  voltar.textContent = "Voltar à pesquisa";
  voltar.addEventListener("click", () => {
    limparSelecao();
    searchInput.focus();
  });
  cabecalho.append(identificacao, voltar);
  comparisonPanel.appendChild(cabecalho);

  if (ofertasDoMedicamento.length === 0) {
    comparisonPanel.appendChild(criarElemento("p", "empty-message", "Nenhuma oferta cadastrada."));
    return;
  }

  const disponiveis = ofertasDoMedicamento
    .filter((oferta) => oferta.disponivel)
    .sort((a, b) => a.preco - b.preco);
  const indisponiveis = ofertasDoMedicamento.filter((oferta) => !oferta.disponivel);

  if (disponiveis.length === 0) {
    comparisonPanel.appendChild(criarElemento("p", "empty-message", "Nenhuma oferta disponível."));
  }

  const lista = document.createElement("div");
  lista.className = "offers-list";

  [...disponiveis, ...indisponiveis].forEach((oferta) => {
    const farmacia = farmacias[oferta.farmaciaId];
    const card = document.createElement("article");
    card.className = `offer-card${oferta.disponivel ? "" : " unavailable"}`;

    const dados = document.createElement("div");
    dados.append(
      criarElemento("h3", "", farmacia.nome),
      criarElemento("p", "product-description", farmacia.endereco),
      criarElemento("p", "availability", oferta.disponivel ? "Disponível" : "Indisponível")
    );

    const preco = criarElemento("strong", "product-price", formatarPreco(oferta.preco));
    card.append(dados, preco);
    lista.appendChild(card);
  });

  comparisonPanel.appendChild(lista);
  comparisonPanel.scrollIntoView({ behavior: "smooth", block: "start" });
}

searchForm.addEventListener("submit", pesquisarNovamente);
searchInput.addEventListener("input", () => {
  limparSelecao();
  atualizarProdutos();
});

const termoInicial = new URLSearchParams(window.location.search).get("termo");
if (termoInicial && searchInput) searchInput.value = termoInicial;
atualizarProdutos();
