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
