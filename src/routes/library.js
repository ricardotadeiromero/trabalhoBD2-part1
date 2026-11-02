const express = require('express');
const db = require('../db');
const { requireLogin, setFlash } = require('../middleware');

const router = express.Router();

router.get('/library', requireLogin, async (req, res) => {
  const userId = req.session.user.id;

  const purchases = await db.query(
    `SELECT c.id, c.nome, c.musica, c.artistas, c.criador, c.criador_id,
            c.instrumentos, c.qtd_stems,
            cb.valor AS valor_pago, cb.metodo_pagamento, cb.data_compra, cb.status_pagamento
     FROM CompraBackingTrack cb
     JOIN v_catalog c ON c.id = cb.backingtrack_id
     WHERE cb.comprador_id = $1
     ORDER BY cb.data_compra DESC, c.nome`,
    [userId]
  );

  const published = await db.query(
    `SELECT id, nome, musica, artistas, valor, vendas, receita, data_criacao, qtd_stems
     FROM v_catalog
     WHERE criador_id = $1
     ORDER BY data_criacao DESC`,
    [userId]
  );

  const totals = await db.query(
    `SELECT COALESCE(SUM(valor) FILTER (WHERE status_pagamento = 'aprovado'), 0) AS gasto,
            COUNT(*) FILTER (WHERE status_pagamento = 'aprovado') AS aprovadas,
            COUNT(*) FILTER (WHERE status_pagamento = 'pendente') AS pendentes
     FROM CompraBackingTrack
     WHERE comprador_id = $1`,
    [userId]
  );

  res.render('library', {
    title: 'Minha biblioteca',
    purchases: purchases.rows,
    published: published.rows,
    totals: totals.rows[0],
  });
});

// simula a compensação do boleto
router.post('/library/:btId/confirm', requireLogin, async (req, res) => {
  const result = await db.query(
    `UPDATE CompraBackingTrack
     SET status_pagamento = 'aprovado', data_compra = CURRENT_DATE
     WHERE comprador_id = $1 AND backingtrack_id = $2 AND status_pagamento = 'pendente'`,
    [req.session.user.id, Number(req.params.btId)]
  );
  if (result.rowCount) setFlash(req, 'success', 'Pagamento confirmado.');
  res.redirect('/library');
});

module.exports = router;
