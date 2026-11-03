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

// "  Violão " -> "violao", pra comparar sem ligar pra acento e maiúscula
function normalizeText(text) {
  return String(text || '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

// a validade do campo é atualizada sempre, mas a borda vermelha e a mensagem
// só aparecem depois que a pessoa sai do campo (ou tenta enviar)
function setError(input, message) {
  input.setCustomValidity(message);
  const visible = input.dataset.touched === '1' && Boolean(message);
  input.classList.toggle('invalid', visible);
  if (input.errorHint) {
    input.errorHint.textContent = message;
    input.errorHint.hidden = !visible;
  }
}

function watchField(input, validate) {
  input.errorHint = document.createElement('span');
  input.errorHint.className = 'field-error small';
  input.errorHint.hidden = true;
  input.after(input.errorHint);

  const touch = () => {
    input.dataset.touched = '1';
    validate();
  };
  input.addEventListener('input', validate);
  input.addEventListener('blur', touch);
  input.addEventListener('invalid', touch);
  validate();
}

// ---------- select com busca ----------
// o <select> original fica escondido e continua sendo o que vai no submit
let comboCount = 0;

function makeSearchable(select) {
  const emptyOption = [...select.options].find((o) => o.value === '');
  const required = select.required;
  const options = [...select.options]
    // num select obrigatório o "Selecione..." não é uma escolha de verdade
    .filter((o) => o.value !== '' || !required)
    .map((o) => {
      const label = o.textContent.replace(/\s+/g, ' ').trim();
      return { value: o.value, label, key: normalizeText(label) };
    });

  const listId = `combo-list-${++comboCount}`;
  const box = document.createElement('div');
  box.className = 'combo';
  box.innerHTML = `
    <input type="text" class="combo-input" autocomplete="off" role="combobox"
           aria-autocomplete="list" aria-expanded="false" aria-controls="${listId}">
    <ul class="combo-list" id="${listId}" role="listbox" hidden></ul>`;
  const input = box.querySelector('input');
  const list = box.querySelector('ul');
  input.placeholder = select.dataset.searchPlaceholder || (emptyOption ? emptyOption.textContent.trim() : 'Buscar...');

  // o input vem antes do select pra que o <label> aponte pra ele
  select.before(box);
  select.hidden = true;
  select.required = false;
  select.tabIndex = -1;

  let matches = [];
  let active = -1;

  const selectedOption = () => options.find((o) => o.value === select.value && o.value !== '');

  const validate = () => setError(input, required && !select.value ? 'Escolha uma opção da lista.' : '');

  const close = () => {
    list.hidden = true;
    input.setAttribute('aria-expanded', 'false');
    input.removeAttribute('aria-activedescendant');
  };

  const render = () => {
    list.innerHTML = '';
    if (matches.length === 0) {
      list.innerHTML = '<li class="combo-empty">Nada encontrado</li>';
      return;
    }
    matches.forEach((option, i) => {
      const li = document.createElement('li');
      li.id = `${listId}-${i}`;
      li.setAttribute('role', 'option');
      li.setAttribute('aria-selected', String(option.value === select.value));
      li.textContent = option.label;
      if (i === active) li.classList.add('active');
      // mousedown em vez de click: o click chega depois do blur do input
      li.addEventListener('mousedown', (event) => {
        event.preventDefault();
        choose(option);
      });
      list.appendChild(li);
    });
    if (active >= 0) {
      input.setAttribute('aria-activedescendant', `${listId}-${active}`);
      list.children[active].scrollIntoView({ block: 'nearest' });
    }
  };

  const open = (query) => {
    // cada palavra digitada tem que aparecer em algum lugar: "ana cachoeira" acha "Ana Vento - Cachoeira"
    const words = normalizeText(query).split(' ').filter(Boolean);
    matches = options.filter((o) => words.every((w) => o.key.includes(w)));
    active = Math.max(0, matches.findIndex((o) => o.value === select.value));
    if (matches.length === 0) active = -1;
    list.hidden = false;
    input.setAttribute('aria-expanded', 'true');
    render();
  };

  function choose(option) {
    const value = option ? option.value : '';
    const changed = select.value !== value;
    select.value = value;
    input.value = option && option.value !== '' ? option.label : '';
    validate();
    close();
    if (changed) select.dispatchEvent(new Event('change', { bubbles: true }));
  }

  input.addEventListener('focus', () => {
    input.select();
    open('');
  });
  input.addEventListener('click', () => {
    if (list.hidden) open('');
  });
  input.addEventListener('input', () => open(input.value));

  input.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault();
      if (list.hidden) return open(input.value);
      const step = event.key === 'ArrowDown' ? 1 : -1;
      active = Math.min(matches.length - 1, Math.max(0, active + step));
      render();
    } else if (event.key === 'Enter' && !list.hidden) {
      // sem isso o Enter envia o formulário no meio da escolha
      event.preventDefault();
      if (active >= 0) choose(matches[active]);
    } else if (event.key === 'Escape' && !list.hidden) {
      event.preventDefault();
      close();
      input.value = selectedOption() ? selectedOption().label : '';
    }
  });

  input.addEventListener('blur', () => {
    input.dataset.touched = '1';
    // texto apagado = limpar a escolha; texto que não virou escolha volta pro que estava
    if (input.value.trim() === '') {
      choose(null);
    } else {
      input.value = selectedOption() ? selectedOption().label : '';
      close();
      validate();
    }
  });
  input.addEventListener('invalid', () => {
    input.dataset.touched = '1';
    validate();
  });

  input.value = selectedOption() ? selectedOption().label : '';
  validate();
}

document.querySelectorAll('select[data-searchable]').forEach(makeSearchable);

// ---------- preço: os números entram pelos centavos, igual app de banco (1990 -> 19,90) ----------
function maskPrice(value) {
  const digits = value.replace(/\D/g, '').replace(/^0+/, '').slice(0, 5);
  if (!digits) return '';
  const cents = digits.padStart(3, '0');
  return `${cents.slice(0, -2)},${cents.slice(-2)}`;
}

document.querySelectorAll('input[data-mask="price"]').forEach((input) => {
  input.addEventListener('input', () => {
    input.value = maskPrice(input.value);
  });
  watchField(input, () => {
    if (input.value === '') return setError(input, 'Informe o preço.');
    setError(input, /^\d{1,3},\d{2}$/.test(input.value) ? '' : 'Use o formato 19,90 (até R$ 999,99).');
  });
});

// ---------- duração: digita só os números e o ":" entra sozinho (345 -> 3:45) ----------
function maskDuration(value) {
  const digits = value.replace(/\D/g, '').replace(/^0+(?=\d{3})/, '').slice(0, 4);
  return digits.length > 2 ? `${digits.slice(0, -2)}:${digits.slice(-2)}` : digits;
}

document.querySelectorAll('input[data-mask="duration"]').forEach((input) => {
  input.addEventListener('input', () => {
    input.value = maskDuration(input.value);
  });
  // só "45" vira 0:45
  input.addEventListener('blur', () => {
    if (input.value && !input.value.includes(':')) input.value = `0:${input.value.padStart(2, '0')}`;
  });
  watchField(input, () => {
    const match = input.value.match(/^(\d{1,2}):(\d{2})$/);
    if (input.value === '') return setError(input, 'Informe a duração.');
    if (!match) return setError(input, 'Use o formato mm:ss, por exemplo 3:45.');
    if (Number(match[2]) > 59) return setError(input, 'Os segundos vão até 59.');
    if (Number(match[1]) * 60 + Number(match[2]) === 0) return setError(input, 'A duração precisa ser maior que zero.');
    setError(input, '');
  });
});

// ---------- linhas de stem na tela de publicar ----------
const stemsBox = document.getElementById('stems');
const addStemButton = document.getElementById('add-stem');

if (stemsBox && addStemButton) {
  // nome sem acento -> nome bonito, a partir do datalist ("violao" -> "violão")
  const knownInstruments = new Map();
  document.querySelectorAll('#instrument-list option').forEach((option) => {
    knownInstruments.set(normalizeText(option.value), option.value);
  });
  const stemsHint = document.querySelector('[data-stems-hint]');

  const validateStems = () => {
    const rows = [...stemsBox.querySelectorAll('.stem-row')];
    const seen = new Set();
    let message = '';

    rows.forEach((row) => {
      const [nameInput, instrumentInput] = row.querySelectorAll('input');
      const name = nameInput.value.trim().toLowerCase();
      const instrument = normalizeText(instrumentInput.value);
      let nameError = '';
      let instrumentError = '';

      if (!name && instrument) nameError = 'Dê um nome para este stem.';
      else if (name && seen.has(name)) nameError = 'Já tem um stem com esse nome.';
      if (name && !instrument) instrumentError = 'Escolha o instrumento deste stem.';
      else if (instrument && !knownInstruments.has(instrument)) {
        instrumentError = `"${instrumentInput.value.trim()}" não está na lista de instrumentos.`;
      }
      if (name) seen.add(name);

      setError(nameInput, nameError);
      setError(instrumentInput, instrumentError);
      // a dica embaixo mostra só o primeiro problema que já está visível
      [[nameInput, nameError], [instrumentInput, instrumentError]].forEach(([input, error]) => {
        if (!message && error && input.dataset.touched === '1') message = error;
      });
    });

    if (seen.size === 0) {
      const firstName = rows[0].querySelector('input');
      setError(firstName, 'Adicione pelo menos um stem.');
      if (!message && firstName.dataset.touched === '1') message = 'Adicione pelo menos um stem.';
    }

    stemsHint.textContent = message;
    stemsHint.hidden = !message;
  };

  stemsBox.addEventListener('input', validateStems);
  stemsBox.addEventListener('focusout', (event) => {
    if (!event.target.matches('input')) return;
    event.target.dataset.touched = '1';
    if (event.target.matches('[data-instrument]')) {
      const known = knownInstruments.get(normalizeText(event.target.value));
      if (known) event.target.value = known;
    }
    validateStems();
  });
  // "invalid" não sobe pelo DOM, por isso o capture
  stemsBox.addEventListener('invalid', (event) => {
    event.target.dataset.touched = '1';
    validateStems();
  }, true);

  addStemButton.addEventListener('click', () => {
    const first = stemsBox.querySelector('.stem-row');
    const row = first.cloneNode(true);
    row.querySelectorAll('input').forEach((input) => {
      input.value = '';
      input.classList.remove('invalid');
      delete input.dataset.touched;
    });
    stemsBox.appendChild(row);
    validateStems();
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
    validateStems();
  });

  validateStems();
}
