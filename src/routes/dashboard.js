const express = require('express');
const db = require('../db');
const { requireLogin } = require('../middleware');

const router = express.Router();

// painel do criador: tudo sobre as vendas dos backing tracks que eu publiquei
router.get('/dashboard', requireLogin, async (req, res) => {
  const userId = req.session.user.id;

  const totals = await db.query(
    `SELECT COUNT(*) FILTER (WHERE c.status_pagamento = 'aprovado') AS aprovadas,
            COUNT(*) FILTER (WHERE c.status_pagamento = 'pendente') AS pendentes,
            COUNT(*) FILTER (WHERE c.status_pagamento = 'recusado') AS recusadas,
            COALESCE(SUM(c.valor) FILTER (WHERE c.status_pagamento = 'aprovado'), 0) AS receita,
            COALESCE(AVG(c.valor) FILTER (WHERE c.status_pagamento = 'aprovado'), 0) AS ticket_medio,
            COUNT(DISTINCT c.comprador_id) FILTER (WHERE c.status_pagamento = 'aprovado') AS clientes
     FROM CompraBackingTrack c
     JOIN BackingTrack bt ON bt.id = c.backingtrack_id
     WHERE bt.usuario_id = $1`,
    [userId]
  );

  const byTrack = await db.query(
    `SELECT c.id, c.nome, c.musica, c.valor, c.vendas, c.receita,
            (SELECT COUNT(*) FROM BackingTrackPlaylist btp WHERE btp.backingtrack_id = c.id) AS em_playlists
     FROM v_catalog c
     WHERE c.criador_id = $1
     ORDER BY c.receita DESC, c.nome`,
    [userId]
  );

  const byMonth = await db.query(
    `SELECT to_char(date_trunc('month', c.data_compra), 'YYYY-MM') AS mes,
            COUNT(*)     AS vendas,
            SUM(c.valor) AS receita
     FROM CompraBackingTrack c
     JOIN BackingTrack bt ON bt.id = c.backingtrack_id
     WHERE bt.usuario_id = $1 AND c.status_pagamento = 'aprovado'
     GROUP BY 1
     ORDER BY 1`,
    [userId]
  );

  const byMethod = await db.query(
    `SELECT c.metodo_pagamento, COUNT(*) AS vendas, SUM(c.valor) AS receita
     FROM CompraBackingTrack c
     JOIN BackingTrack bt ON bt.id = c.backingtrack_id
     WHERE bt.usuario_id = $1 AND c.status_pagamento = 'aprovado'
     GROUP BY c.metodo_pagamento
     ORDER BY vendas DESC`,
    [userId]
  );

  // de que nível são os músicos que compram de mim
  const byBuyerLevel = await db.query(
    `SELECT u.nivel_experiencia, COUNT(*) AS compras
     FROM CompraBackingTrack c
     JOIN BackingTrack bt ON bt.id = c.backingtrack_id
     JOIN Usuario u       ON u.id = c.comprador_id
     WHERE bt.usuario_id = $1 AND c.status_pagamento = 'aprovado'
     GROUP BY u.nivel_experiencia
     ORDER BY compras DESC`,
    [userId]
  );

  const recent = await db.query(
    `SELECT u.id AS comprador_id, u.nome AS comprador, bt.id AS bt_id, bt.nome AS bt_nome,
            c.valor, c.metodo_pagamento, c.data_compra, c.status_pagamento
     FROM CompraBackingTrack c
     JOIN BackingTrack bt ON bt.id = c.backingtrack_id
     JOIN Usuario u       ON u.id = c.comprador_id
     WHERE bt.usuario_id = $1
     ORDER BY c.data_compra DESC
     LIMIT 10`,
    [userId]
  );

  res.render('dashboard', {
    title: 'Painel do criador',
    totals: totals.rows[0],
    byTrack: byTrack.rows,
    byMonth: byMonth.rows,
    byMethod: byMethod.rows,
    byBuyerLevel: byBuyerLevel.rows,
    recent: recent.rows,
  });
});

module.exports = router;
