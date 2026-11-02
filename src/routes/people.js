const express = require('express');
const db = require('../db');
const { requireLogin, setFlash } = require('../middleware');

const router = express.Router();

router.get('/people', async (req, res) => {
  const user = req.session.user;
  const q = (req.query.q || '').trim();
  const level = req.query.level || '';
  const instrument = req.query.instrument || '';

  const conditions = [];
  const params = [];
  if (q) {
    params.push(`%${q}%`);
    conditions.push(`unaccent(s.nome) ILIKE unaccent($${params.length})`);
  }
  if (level) {
    params.push(level);
    conditions.push(`s.nivel_experiencia = $${params.length}`);
  }
  if (instrument) {
    // músicos que publicaram algum backing track com stem desse instrumento
    params.push(instrument);
    conditions.push(`EXISTS (
      SELECT 1 FROM BackingTrack bt
      JOIN Track t ON t.backingtrack_id = bt.id
      WHERE bt.usuario_id = s.id AND t.instrumento = $${params.length})`);
  }
  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

  const people = await db.query(
    `SELECT s.*,
            (SELECT array_agg(DISTINCT t.instrumento)
             FROM BackingTrack bt
             JOIN Track t ON t.backingtrack_id = bt.id
             WHERE bt.usuario_id = s.id AND t.instrumento IS NOT NULL) AS instrumentos
     FROM v_user_summary s
     ${where}
     ORDER BY s.seguidores DESC, s.publicados DESC, s.nome`,
    params
  );

  // sugestões: quem é seguido por quem eu sigo e eu ainda não sigo
  let suggestions = [];
  let followingIds = [];
  if (user) {
    const sug = await db.query(
      `SELECT u.id, u.nome, u.nivel_experiencia, COUNT(*) AS em_comum,
              string_agg(intermediario.nome, ', ' ORDER BY intermediario.nome) AS via
       FROM Seguidores eu
       JOIN Seguidores deles   ON deles.seguidor_id = eu.seguido_id
       JOIN Usuario u          ON u.id = deles.seguido_id
       JOIN Usuario intermediario ON intermediario.id = eu.seguido_id
       WHERE eu.seguidor_id = $1
         AND deles.seguido_id <> $1
         AND NOT EXISTS (SELECT 1 FROM Seguidores x
                         WHERE x.seguidor_id = $1 AND x.seguido_id = deles.seguido_id)
       GROUP BY u.id
       ORDER BY em_comum DESC, u.nome
       LIMIT 4`,
      [user.id]
    );
    suggestions = sug.rows;

    const f = await db.query('SELECT seguido_id FROM Seguidores WHERE seguidor_id = $1', [user.id]);
    followingIds = f.rows.map((r) => r.seguido_id);
  }

  const instruments = await db.query(
    'SELECT DISTINCT instrumento FROM Track WHERE instrumento IS NOT NULL ORDER BY instrumento'
  );

  res.render('people', {
    title: 'Músicos',
    people: people.rows,
    suggestions,
    followingIds,
    instruments: instruments.rows.map((r) => r.instrumento),
    filters: { q, level, instrument },
  });
});

router.get('/users/:id', async (req, res, next) => {
  const id = Number(req.params.id);
  const user = req.session.user;

  const summary = await db.query('SELECT * FROM v_user_summary WHERE id = $1', [id]);
  const profile = summary.rows[0];
  if (!profile) return next();

  const published = await db.query(
    'SELECT * FROM v_catalog WHERE criador_id = $1 ORDER BY data_criacao DESC',
    [id]
  );

  const playlists = await db.query(
    `SELECT p.id, p.nome, COUNT(btp.backingtrack_id) AS faixas
     FROM Playlist p
     LEFT JOIN BackingTrackPlaylist btp ON btp.playlist_id = p.id
     WHERE p.usuario_id = $1
     GROUP BY p.id
     ORDER BY p.nome`,
    [id]
  );

  const followers = await db.query(
    `SELECT u.id, u.nome FROM Seguidores s JOIN Usuario u ON u.id = s.seguidor_id
     WHERE s.seguido_id = $1 ORDER BY u.nome`,
    [id]
  );
  const following = await db.query(
    `SELECT u.id, u.nome FROM Seguidores s JOIN Usuario u ON u.id = s.seguido_id
     WHERE s.seguidor_id = $1 ORDER BY u.nome`,
    [id]
  );

  // artistas que esse músico mais toca (pelas músicas dos backing tracks dele)
  const favoriteArtists = await db.query(
    `SELECT a.id, a.nome_artistico, COUNT(DISTINCT bt.id) AS qtd
     FROM BackingTrack bt
     JOIN ArtistaMusica am ON am.musica_id = bt.musica_id
     JOIN Artista a        ON a.id = am.artista_id
     WHERE bt.usuario_id = $1
     GROUP BY a.id
     ORDER BY qtd DESC, a.nome_artistico
     LIMIT 5`,
    [id]
  );

  const isFollowing = user ? followers.rows.some((f) => f.id === user.id) : false;

  res.render('user', {
    title: profile.nome,
    profile,
    published: published.rows,
    playlists: playlists.rows,
    followers: followers.rows,
    following: following.rows,
    favoriteArtists: favoriteArtists.rows,
    isFollowing,
    isMe: user && user.id === id,
  });
});

router.post('/users/:id/follow', requireLogin, async (req, res) => {
  const targetId = Number(req.params.id);
  const me = req.session.user.id;

  if (targetId === me) {
    setFlash(req, 'error', 'Você não pode seguir a si mesmo.');
  } else if (req.body.action === 'unfollow') {
    await db.query('DELETE FROM Seguidores WHERE seguido_id = $1 AND seguidor_id = $2', [targetId, me]);
  } else {
    await db.query(
      'INSERT INTO Seguidores (seguido_id, seguidor_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [targetId, me]
    );
  }

  const back = req.body.back || '';
  res.redirect(back.startsWith('/') && !back.startsWith('//') ? back : `/users/${targetId}`);
});

module.exports = router;
