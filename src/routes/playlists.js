const express = require('express');
const db = require('../db');
const { requireLogin, setFlash } = require('../middleware');

const router = express.Router();

router.get('/playlists', requireLogin, async (req, res) => {
  const userId = req.session.user.id;

  const mine = await db.query(
    `SELECT p.id, p.nome, p.data_criacao,
            COUNT(btp.backingtrack_id)    AS faixas,
            COALESCE(SUM(bt.duracao), 0)  AS duracao_total,
            (SELECT COUNT(*) FROM PlaylistsSalvas ps WHERE ps.playlist_id = p.id) AS salvamentos
     FROM Playlist p
     LEFT JOIN BackingTrackPlaylist btp ON btp.playlist_id = p.id
     LEFT JOIN BackingTrack bt          ON bt.id = btp.backingtrack_id
     WHERE p.usuario_id = $1
     GROUP BY p.id
     ORDER BY p.data_criacao DESC`,
    [userId]
  );

  const saved = await db.query(
    `SELECT p.id, p.nome, u.id AS dono_id, u.nome AS dono, ps.data_salva,
            COUNT(btp.backingtrack_id) AS faixas
     FROM PlaylistsSalvas ps
     JOIN Playlist p ON p.id = ps.playlist_id
     JOIN Usuario u  ON u.id = p.usuario_id
     LEFT JOIN BackingTrackPlaylist btp ON btp.playlist_id = p.id
     WHERE ps.usuario_id = $1
     GROUP BY p.id, u.id, ps.data_salva
     ORDER BY ps.data_salva DESC`,
    [userId]
  );

  res.render('playlists', { title: 'Playlists', mine: mine.rows, saved: saved.rows });
});

router.post('/playlists', requireLogin, async (req, res) => {
  const name = (req.body.nome || '').trim();
  if (!name) {
    setFlash(req, 'error', 'Dê um nome para a playlist.');
    return res.redirect('/playlists');
  }
  try {
    const { rows } = await db.query(
      'INSERT INTO Playlist (nome, usuario_id) VALUES ($1, $2) RETURNING id',
      [name, req.session.user.id]
    );
    res.redirect(`/playlists/${rows[0].id}`);
  } catch (err) {
    if (err.code !== '23505') throw err;
    setFlash(req, 'error', 'Você já tem uma playlist com esse nome.');
    res.redirect('/playlists');
  }
});

router.get('/playlists/:id', async (req, res, next) => {
  const id = Number(req.params.id);
  const user = req.session.user;

  const head = await db.query(
    `SELECT p.id, p.nome, p.data_criacao, u.id AS dono_id, u.nome AS dono,
            (SELECT COUNT(*) FROM PlaylistsSalvas ps WHERE ps.playlist_id = p.id) AS salvamentos
     FROM Playlist p
     JOIN Usuario u ON u.id = p.usuario_id
     WHERE p.id = $1`,
    [id]
  );
  const playlist = head.rows[0];
  if (!playlist) return next();

  const items = await db.query(
    `SELECT btp.posicao, c.*
     FROM BackingTrackPlaylist btp
     JOIN v_catalog c ON c.id = btp.backingtrack_id
     WHERE btp.playlist_id = $1
     ORDER BY btp.posicao`,
    [id]
  );

  // instrumentos que aparecem na playlist, pra dar uma cara de "resumo"
  const instruments = await db.query(
    `SELECT t.instrumento, COUNT(*) AS qtd
     FROM BackingTrackPlaylist btp
     JOIN Track t ON t.backingtrack_id = btp.backingtrack_id
     WHERE btp.playlist_id = $1 AND t.instrumento IS NOT NULL
     GROUP BY t.instrumento
     ORDER BY qtd DESC, t.instrumento`,
    [id]
  );

  let isSaved = false;
  if (user) {
    const s = await db.query(
      'SELECT 1 FROM PlaylistsSalvas WHERE usuario_id = $1 AND playlist_id = $2',
      [user.id, id]
    );
    isSaved = s.rowCount > 0;
  }

  const totalSeconds = items.rows.reduce((sum, row) => sum + Number(row.duracao || 0), 0);

  res.render('playlist', {
    title: playlist.nome,
    playlist,
    items: items.rows,
    instruments: instruments.rows,
    totalSeconds,
    isOwner: user && user.id === playlist.dono_id,
    isSaved,
  });
});

// garante que a playlist é de quem está logado antes de mexer nela
async function loadOwnPlaylist(req, res, id = Number(req.params.id)) {
  const { rows } = await db.query('SELECT id, usuario_id FROM Playlist WHERE id = $1', [id]);
  if (!rows[0] || rows[0].usuario_id !== req.session.user.id) {
    setFlash(req, 'error', 'Você só pode alterar suas próprias playlists.');
    res.redirect('/playlists');
    return null;
  }
  return rows[0];
}

// vem do formulário da página do backing track
router.post('/playlists/add', requireLogin, async (req, res) => {
  const playlist = await loadOwnPlaylist(req, res, Number(req.body.playlist_id));
  if (!playlist) return;
  const btId = Number(req.body.backingtrack_id);

  const result = await db.query(
    `INSERT INTO BackingTrackPlaylist (playlist_id, backingtrack_id, posicao)
     SELECT $1, $2, COALESCE(MAX(posicao), 0) + 1
     FROM BackingTrackPlaylist
     WHERE playlist_id = $1
     ON CONFLICT (playlist_id, backingtrack_id) DO NOTHING`,
    [playlist.id, btId]
  );
  setFlash(req, result.rowCount ? 'success' : 'info',
    result.rowCount ? 'Adicionado à playlist.' : 'Esse backing track já está na playlist.');
  const back = req.body.back || '';
  res.redirect(back.startsWith('/') && !back.startsWith('//') ? back : `/playlists/${playlist.id}`);
});

router.post('/playlists/:id/items/:btId/remove', requireLogin, async (req, res) => {
  const playlist = await loadOwnPlaylist(req, res);
  if (!playlist) return;
  const btId = Number(req.params.btId);

  await db.withTransaction(async (client) => {
    const removed = await client.query(
      `DELETE FROM BackingTrackPlaylist
       WHERE playlist_id = $1 AND backingtrack_id = $2
       RETURNING posicao`,
      [playlist.id, btId]
    );
    if (!removed.rowCount) return;
    // fecha o buraco que ficou na numeração
    await client.query(
      `UPDATE BackingTrackPlaylist
       SET posicao = posicao - 1
       WHERE playlist_id = $1 AND posicao > $2`,
      [playlist.id, removed.rows[0].posicao]
    );
  });
  res.redirect(`/playlists/${playlist.id}`);
});

router.post('/playlists/:id/items/:btId/move', requireLogin, async (req, res) => {
  const playlist = await loadOwnPlaylist(req, res);
  if (!playlist) return;
  const btId = Number(req.params.btId);
  const step = req.body.direction === 'up' ? -1 : 1;

  const current = await db.query(
    'SELECT posicao FROM BackingTrackPlaylist WHERE playlist_id = $1 AND backingtrack_id = $2',
    [playlist.id, btId]
  );
  if (current.rowCount) {
    const from = current.rows[0].posicao;
    const to = from + step;
    // troca as duas posições num UPDATE só (a UNIQUE é DEFERRABLE, ver 05_adjustments.sql)
    await db.query(
      `UPDATE BackingTrackPlaylist
       SET posicao = CASE posicao WHEN $2::int THEN $3::int ELSE $2::int END
       WHERE playlist_id = $1 AND posicao IN ($2, $3)
         AND EXISTS (SELECT 1 FROM BackingTrackPlaylist WHERE playlist_id = $1 AND posicao = $3)`,
      [playlist.id, from, to]
    );
  }
  res.redirect(`/playlists/${playlist.id}`);
});

router.post('/playlists/:id/delete', requireLogin, async (req, res) => {
  const playlist = await loadOwnPlaylist(req, res);
  if (!playlist) return;

  await db.withTransaction(async (client) => {
    await client.query('DELETE FROM BackingTrackPlaylist WHERE playlist_id = $1', [playlist.id]);
    await client.query('DELETE FROM PlaylistsSalvas WHERE playlist_id = $1', [playlist.id]);
    await client.query('DELETE FROM Playlist WHERE id = $1', [playlist.id]);
  });
  setFlash(req, 'success', 'Playlist excluída.');
  res.redirect('/playlists');
});

router.post('/playlists/:id/save', requireLogin, async (req, res) => {
  const id = Number(req.params.id);
  const userId = req.session.user.id;

  if (req.body.action === 'unsave') {
    await db.query('DELETE FROM PlaylistsSalvas WHERE usuario_id = $1 AND playlist_id = $2', [userId, id]);
  } else {
    await db.query(
      `INSERT INTO PlaylistsSalvas (usuario_id, playlist_id)
       SELECT $1, p.id FROM Playlist p
       WHERE p.id = $2 AND p.usuario_id <> $1
       ON CONFLICT DO NOTHING`,
      [userId, id]
    );
  }
  res.redirect(`/playlists/${id}`);
});

module.exports = router;
