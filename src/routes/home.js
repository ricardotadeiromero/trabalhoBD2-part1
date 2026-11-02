const express = require('express');
const db = require('../db');

const router = express.Router();

router.get('/', async (req, res) => {
  const user = req.session.user;

  const bestSellers = await db.query(
    `SELECT * FROM v_catalog
     ORDER BY vendas DESC, data_criacao DESC
     LIMIT 6`
  );

  const topPlaylists = await db.query(
    `SELECT p.id, p.nome, u.id AS dono_id, u.nome AS dono,
            COUNT(DISTINCT ps.usuario_id)       AS salvamentos,
            COUNT(DISTINCT btp.backingtrack_id) AS faixas
     FROM Playlist p
     JOIN Usuario u ON u.id = p.usuario_id
     LEFT JOIN PlaylistsSalvas ps       ON ps.playlist_id = p.id
     LEFT JOIN BackingTrackPlaylist btp ON btp.playlist_id = p.id
     GROUP BY p.id, u.id
     HAVING COUNT(DISTINCT btp.backingtrack_id) > 0
     ORDER BY salvamentos DESC, faixas DESC
     LIMIT 6`
  );

  let feed = [];
  if (user) {
    const result = await db.query(
      `SELECT c.*
       FROM v_catalog c
       JOIN Seguidores s ON s.seguido_id = c.criador_id
       WHERE s.seguidor_id = $1
       ORDER BY c.data_criacao DESC
       LIMIT 6`,
      [user.id]
    );
    feed = result.rows;
  }

  const stats = await db.query(
    `SELECT (SELECT COUNT(*) FROM BackingTrack) AS backing_tracks,
            (SELECT COUNT(*) FROM Track)        AS stems,
            (SELECT COUNT(*) FROM Usuario)      AS musicos,
            (SELECT COUNT(*) FROM Artista)      AS artistas`
  );

  res.render('home', {
    title: 'Início',
    bestSellers: bestSellers.rows,
    topPlaylists: topPlaylists.rows,
    feed,
    stats: stats.rows[0],
  });
});

module.exports = router;
