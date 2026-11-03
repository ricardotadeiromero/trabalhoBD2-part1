// menu no celular
const toggle = document.querySelector('.menu-toggle');
if (toggle) {
  toggle.addEventListener('click', () => {
    document.getElementById('nav').classList.toggle('open');
  });
}

// formulários com data-confirm pedem confirmação antes de enviar
document.querySelectorAll('form[data-confirm]').forEach((form) => {
  form.addEventListener('submit', (event) => {
    if (!confirm(form.dataset.confirm)) event.preventDefault();
  });
});

// máscara de CPF: 000.000.000-00
function maskCpf(value) {
  const d = value.replace(/\D/g, '').slice(0, 11);
  if (d.length > 9) return `${d.slice(0, 3)}.${d.slice(3, 6)}.${d.slice(6, 9)}-${d.slice(9)}`;
  if (d.length > 6) return `${d.slice(0, 3)}.${d.slice(3, 6)}.${d.slice(6)}`;
  if (d.length > 3) return `${d.slice(0, 3)}.${d.slice(3)}`;
  return d;
}

document.querySelectorAll('input[data-mask="cpf"]').forEach((input) => {
  input.addEventListener('input', () => {
    input.value = maskCpf(input.value);
  });
});

// confirmação de senha: só deixa enviar quando as duas batem
document.querySelectorAll('input[data-match]').forEach((confirmInput) => {
  const original = document.getElementById(confirmInput.dataset.match);
  const hint = confirmInput.form.querySelector('[data-match-hint]');

  const check = () => {
    const mismatch = confirmInput.value !== '' && confirmInput.value !== original.value;
    confirmInput.setCustomValidity(mismatch ? 'As senhas não conferem.' : '');
    confirmInput.classList.toggle('invalid', mismatch);
    if (hint) hint.hidden = !mismatch;
  };

  confirmInput.addEventListener('input', check);
  original.addEventListener('input', check);
});

// linhas de stem na tela de publicar
const stemsBox = document.getElementById('stems');
const addStemButton = document.getElementById('add-stem');

if (stemsBox && addStemButton) {
  addStemButton.addEventListener('click', () => {
    const first = stemsBox.querySelector('.stem-row');
    const row = first.cloneNode(true);
    row.querySelectorAll('input').forEach((input) => (input.value = ''));
    stemsBox.appendChild(row);
    row.querySelector('input').focus();
  });

  stemsBox.addEventListener('click', (event) => {
    if (!event.target.matches('[data-remove-stem]')) return;
    const rows = stemsBox.querySelectorAll('.stem-row');
    // sempre deixa pelo menos uma linha
    if (rows.length > 1) {
      event.target.closest('.stem-row').remove();
    } else {
      rows[0].querySelectorAll('input').forEach((input) => (input.value = ''));
    }
  });
}
