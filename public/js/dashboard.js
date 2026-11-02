(function () {
  const data = window.dashboardData;
  if (!data || typeof Chart === 'undefined') return;

  const accent = '#f5a524';
  const gridColor = 'rgba(255,255,255,0.06)';
  const textColor = '#9aa3b2';
  Chart.defaults.color = textColor;
  Chart.defaults.font.family = 'Inter, system-ui, sans-serif';
  Chart.defaults.maintainAspectRatio = false;

  const monthCanvas = document.getElementById('chart-month');
  if (monthCanvas && data.months.length) {
    new Chart(monthCanvas, {
      type: 'bar',
      data: {
        labels: data.months.map((m) => {
          const [year, month] = m.mes.split('-');
          return `${month}/${year.slice(2)}`;
        }),
        datasets: [{
          label: 'Receita (R$)',
          data: data.months.map((m) => Number(m.receita)),
          backgroundColor: accent,
          borderRadius: 4,
        }],
      },
      options: {
        plugins: { legend: { display: false } },
        scales: {
          x: { grid: { display: false } },
          y: { grid: { color: gridColor }, beginAtZero: true },
        },
      },
    });
  }

  const methodCanvas = document.getElementById('chart-method');
  if (methodCanvas && data.methods.length) {
    new Chart(methodCanvas, {
      type: 'doughnut',
      data: {
        labels: data.methods.map((m) => m.label),
        datasets: [{
          data: data.methods.map((m) => m.vendas),
          backgroundColor: ['#f5a524', '#4fb3a9', '#8b7cf6', '#e86a5a'],
          borderWidth: 0,
        }],
      },
      options: {
        cutout: '62%',
        plugins: { legend: { position: 'bottom' } },
      },
    });
  }
})();
