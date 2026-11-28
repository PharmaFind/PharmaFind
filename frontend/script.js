const locationPopup = document.getElementById('locPopup');
const cepBox = document.getElementById('cepBox');

const locOpen = document.getElementById('locOpen');
const locClose = document.getElementById('locClose');
const decline = document.getElementById('decline');
const allow = document.getElementById('allow');

const cepOpen = document.getElementById('cepOpen');
const cepClose = document.getElementById('cepClose');
const cepInput = document.getElementById('cepInput');
const saveCep = document.getElementById('saveCep');

let fundoInerte = [];

function criarAvisoAcessivel(mensagem) {
  let aviso = document.getElementById('toastStatus');

  if (!aviso) {
    aviso = document.createElement('div');
    aviso.id = 'toastStatus';
    aviso.className = 'toast-status';
    aviso.setAttribute('role', 'status');
    aviso.setAttribute('aria-live', 'polite');
    document.body.appendChild(aviso);
  }

  aviso.textContent = mensagem;
  aviso.hidden = false;

  window.clearTimeout(criarAvisoAcessivel.timer);
  criarAvisoAcessivel.timer = window.setTimeout(() => {
    aviso.hidden = true;
  }, 5000);
}

if (locationPopup) {
  locationPopup.setAttribute('role', 'dialog');
  locationPopup.setAttribute('aria-modal', 'true');
  locationPopup.setAttribute('aria-label', 'Permissão de localização');
}

if (cepBox) {
  cepBox.setAttribute('role', 'dialog');
  cepBox.setAttribute('aria-modal', 'false');
  cepBox.setAttribute('aria-label', 'Informar CEP');
}

function fecharPopupLocalizacao() {
  if (!locationPopup) return;
  locationPopup.hidden = true;
  fundoInerte.forEach(([elemento, inerte]) => { elemento.inert = inerte; });
  fundoInerte = [];
  locOpen?.focus();
}

if (locOpen && locationPopup) {
  locOpen.addEventListener('click', () => {
    if (!locationPopup.hidden) return;
    if (cepBox) cepBox.hidden = true;
    locationPopup.hidden = false;
    // Também funciona na página em que o diálogo está dentro de main.
    let ramo = locationPopup;
    while (ramo.parentElement) {
      for (const elemento of ramo.parentElement.children) {
        if (elemento !== ramo) {
          fundoInerte.push([elemento, elemento.inert]);
          elemento.inert = true;
        }
      }
      ramo = ramo.parentElement;
      if (ramo === document.body) break;
    }
    locClose?.focus();
  });
}

if (locClose) locClose.addEventListener('click', fecharPopupLocalizacao);
if (decline) decline.addEventListener('click', fecharPopupLocalizacao);


if (allow) {
  allow.addEventListener('click', () => {
    fecharPopupLocalizacao();

    if (!navigator.geolocation) {
      criarAvisoAcessivel('Localização indisponível. A comparação por distância ainda não está integrada; a consulta continua por preço.');
      return;
    }

    navigator.geolocation.getCurrentPosition(
      () => criarAvisoAcessivel('Localização autorizada pelo navegador. A comparação por distância ainda não está integrada.'),
      () => criarAvisoAcessivel('GPS negado ou indisponível. Você pode consultar normalmente ou informar o CEP.')
    );
  });
}


if (cepOpen && cepBox) {
  cepOpen.addEventListener('click', () => {
    cepBox.hidden = false;
    cepInput?.focus();
  });
}

if (cepClose && cepBox) {
  cepClose.addEventListener('click', () => {
    cepBox.hidden = true;
    cepOpen?.focus();
  });
}

if (saveCep && cepInput && cepBox) {
  saveCep.addEventListener('click', () => {
    const entrada = cepInput.value.trim();
    const cep = entrada.replace(/\D/g, '');

    if (!/^\d{5}-?\d{3}$/.test(entrada) || cep.length !== 8) {
      criarAvisoAcessivel('CEP inválido. Use oito dígitos, com ou sem hífen: 00000-000.');
      cepInput.focus();
      return;
    }

    const cepFormatado = `${cep.substring(0, 5)}-${cep.substring(5)}`;
    localStorage.setItem('pharmafindCep', cepFormatado);
    cepInput.value = cepFormatado;
    cepBox.hidden = true;
    criarAvisoAcessivel(`CEP ${cepFormatado} registrado. A comparação por distância ainda não está integrada.`);
    cepOpen?.focus();
  });
}

if (cepInput) {
  const cepSalvo = localStorage.getItem('pharmafindCep');
  if (cepSalvo) cepInput.value = cepSalvo;
}


const mobileMenuButton = document.getElementById('mobileMenuButton');
const mobileMenu = document.getElementById('mobileMenu');

if (mobileMenuButton && mobileMenu) {
  mobileMenuButton.setAttribute('type', 'button');
  mobileMenuButton.setAttribute('aria-controls', 'mobileMenu');
  mobileMenuButton.setAttribute('aria-expanded', 'false');
  mobileMenuButton.setAttribute('aria-label', 'Abrir menu');

  mobileMenuButton.addEventListener('click', () => {
    const isOpen = mobileMenu.hidden;
    mobileMenu.hidden = !isOpen;
    mobileMenuButton.setAttribute('aria-expanded', String(isOpen));
    mobileMenuButton.setAttribute('aria-label', isOpen ? 'Fechar menu' : 'Abrir menu');
  });
}


const heroMedicineSearch = document.getElementById('heroMedicineSearch');
const heroSearchButton = document.getElementById('heroSearchButton');


function pesquisarMedicamentoNaConsulta() {
  if (!heroMedicineSearch) return;
  const termo = heroMedicineSearch.value.trim();
  window.location.href = termo
    ? `consulta.html?termo=${encodeURIComponent(termo)}`
    : 'consulta.html';
}

if (heroSearchButton) heroSearchButton.addEventListener('click', pesquisarMedicamentoNaConsulta);
if (heroMedicineSearch) {
  heroMedicineSearch.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') pesquisarMedicamentoNaConsulta();
  });
}

document.addEventListener('keydown', (event) => {
  if (event.key === 'Tab') {
    const dialogo = locationPopup && !locationPopup.hidden
      ? locationPopup
      : null;

    if (dialogo) {
      const focaveis = Array.from(dialogo.querySelectorAll(
        'button:not([disabled]), input:not([disabled]), [href], [tabindex]:not([tabindex="-1"])'
      )).filter((elemento) => !elemento.hidden);

      if (focaveis.length) {
        const primeiro = focaveis[0];
        const ultimo = focaveis[focaveis.length - 1];

        if (event.shiftKey && document.activeElement === primeiro) {
          event.preventDefault();
          ultimo.focus();
        } else if (!event.shiftKey && document.activeElement === ultimo) {
          event.preventDefault();
          primeiro.focus();
        }
      }
    }
  }

  if (event.key === 'Escape') {
    if (locationPopup && !locationPopup.hidden) {
      event.preventDefault();
      fecharPopupLocalizacao();
      return;
    }

    if (cepBox && !cepBox.hidden) {
      cepBox.hidden = true;
      cepOpen?.focus();
    }

    if (mobileMenu && mobileMenuButton && !mobileMenu.hidden) {
      mobileMenu.hidden = true;
      mobileMenuButton.setAttribute('aria-expanded', 'false');
      mobileMenuButton.setAttribute('aria-label', 'Abrir menu');
      mobileMenuButton.focus();
    }
  }
});

if (locationPopup) {
  locationPopup.addEventListener('click', (event) => {
    if (event.target === locationPopup) fecharPopupLocalizacao();
  });
}
