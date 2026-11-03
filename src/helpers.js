const currency = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' });

function formatPrice(value) {
  return currency.format(Number(value || 0));
}

// duracao no banco esta sempre em segundos
function formatDuration(seconds) {
  const total = Number(seconds || 0);
  const h = Math.floor(total / 3600);
  const m = Math.floor((total % 3600) / 60);
  const s = String(total % 60).padStart(2, '0');
  return h > 0 ? `${h}h${String(m).padStart(2, '0')}` : `${m}:${s}`;
}

function formatDate(value) {
  if (!value) return '';
  const [y, m, d] = String(value).slice(0, 10).split('-');
  return `${d}/${m}/${y}`;
}

const levelLabels = {
  iniciante: 'Iniciante',
  intermediario: 'Intermediário',
  avancado: 'Avançado',
};

const paymentLabels = {
  pix: 'Pix',
  cartao_credito: 'Cartão de crédito',
  cartao_debito: 'Cartão de débito',
  boleto: 'Boleto',
};

function initials(name) {
  return String(name || '?')
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0].toUpperCase())
    .join('');
}

// 12345678901 -> 123.456.789-01 (deixa como veio se nao tiver 11 digitos)
function formatCpf(value) {
  const digits = String(value || '').replace(/\D/g, '');
  if (digits.length !== 11) return digits;
  return digits.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
}

// mm:ss -> segundos (usado no formulario de publicar)
function parseDuration(text) {
  if (!text) return null;
  const match = String(text).trim().match(/^(\d{1,3}):([0-5]\d)$/);
  if (!match) return null;
  return Number(match[1]) * 60 + Number(match[2]);
}

module.exports = {
  formatPrice,
  formatDuration,
  formatDate,
  levelLabels,
  paymentLabels,
  initials,
  formatCpf,
  parseDuration,
};
