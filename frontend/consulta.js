const medicamentos = [
  { id: 1001, nome: "Dipirona", dosagem: "500 mg", apresentacao: "20 comprimidos", imagem: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=85" },
  { id: 1002, nome: "Dipirona", dosagem: "1 g", apresentacao: "10 comprimidos", imagem: "https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&w=800&q=85" },
  { id: 1003, nome: "Paracetamol", dosagem: "750 mg", apresentacao: "20 comprimidos", imagem: "https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&w=800&q=85" },
  { id: 1004, nome: "Ibuprofeno", dosagem: "400 mg", apresentacao: "10 cápsulas", imagem: "https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?auto=format&fit=crop&w=800&q=85" },
  { id: 1005, nome: "Loratadina", dosagem: "10 mg", apresentacao: "12 comprimidos", imagem: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?auto=format&fit=crop&w=800&q=85" },
  { id: 1006, nome: "Omeprazol", dosagem: "20 mg", apresentacao: "28 cápsulas", imagem: "https://images.unsplash.com/photo-1576602976047-174e57a47881?auto=format&fit=crop&w=800&q=85" }
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
const searchStep = document.getElementById("searchStep");
const productsGrid = document.getElementById("productsGrid");
const resultsCount = document.getElementById("resultsCount");
const emptyState = document.getElementById("emptyState");
const initialState = document.getElementById("initialState");
const resultsTitle = document.getElementById("resultsTitle");
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
  searchStep.hidden = false;
}

function atualizarProdutos() {
  const termo = searchInput.value.toLocaleLowerCase("pt-BR").trim();
  productsGrid.replaceChildren();
  initialState.hidden = Boolean(termo);
  emptyState.hidden = true;
  resultsTitle.textContent = termo ? "Apresentações encontradas" : "Pesquisa de medicamentos";
  resultsCount.textContent = "";
  if (!termo) return;

  const resultados = medicamentos.filter((medicamento) => {
    const texto = `${medicamento.id} ${medicamento.nome} ${medicamento.dosagem} ${medicamento.apresentacao}`;
    return !termo || texto.toLocaleLowerCase("pt-BR").includes(termo);
  });

  resultados.forEach((medicamento) => {
    const card = document.createElement("article");
    card.className = "product-card";

    const imagem = document.createElement("img");
    imagem.src = medicamento.imagem;
    imagem.alt = `Imagem ilustrativa de ${medicamento.nome} ${medicamento.dosagem}`;
    imagem.loading = "lazy";
    imagem.addEventListener("error", () => {
      imagem.src = "medicamento-placeholder.svg";
    }, { once: true });

    const conteudo = document.createElement("div");
    conteudo.className = "product-content";
    conteudo.append(
      criarElemento("h3", "", medicamento.nome),
      criarElemento("p", "product-description", medicamento.dosagem),
      criarElemento("p", "product-description", medicamento.apresentacao)
    );

    const botao = document.createElement("button");
    botao.type = "button";
    botao.className = "offer-button";
    botao.textContent = "Ver ofertas";
    botao.setAttribute("aria-label", `Ver ofertas de ${medicamento.nome} ${medicamento.dosagem}, ${medicamento.apresentacao}`);
    botao.addEventListener("click", () => selecionarMedicamento(medicamento.id));
    conteudo.appendChild(botao);

    card.append(imagem, conteudo);
    productsGrid.appendChild(card);
  });

  resultsCount.textContent = `${resultados.length} ${resultados.length === 1 ? "apresentação" : "apresentações"}`;
  emptyState.hidden = resultados.length !== 0;
  emptyState.textContent = "Nenhum medicamento encontrado. Confira o nome ou tente outro termo.";
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
  searchStep.hidden = true;
  comparisonPanel.hidden = false;
  comparisonPanel.replaceChildren();

  const cabecalho = document.createElement("div");
  cabecalho.className = "comparison-header";

  const identificacao = document.createElement("div");
  const titulo = criarElemento("h2", "", `Ofertas — ${medicamento.nome} ${medicamento.dosagem}`);
  titulo.id = "comparisonTitle";
  identificacao.append(
    titulo,
    criarElemento("p", "", medicamento.apresentacao)
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
  comparisonPanel.focus();

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
}

searchForm.addEventListener("submit", pesquisarNovamente);
searchInput.addEventListener("input", () => {
  limparSelecao();
  atualizarProdutos();
});

const termoInicial = new URLSearchParams(window.location.search).get("termo");
if (termoInicial && searchInput) searchInput.value = termoInicial;
atualizarProdutos();
