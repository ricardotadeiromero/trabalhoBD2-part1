const express = require('express');
const db = require('../db');

const router = express.Router();

router.get('/artists', async (req, res) => {
  // COUNT DISTINCT porque os três LEFT JOIN multiplicam as linhas
  const { rows } = await db.query(
    `SELECT a.id, a.nome_artistico, a.biografia, a.data_criacao,
            COUNT(DISTINCT aa.album_id)  AS albuns,
            COUNT(DISTINCT am.musica_id) AS musicas,
            COUNT(DISTINCT bt.id)        AS backing_tracks
     FROM Artista a
     LEFT JOIN ArtistaAlbum aa  ON aa.artista_id = a.id
     LEFT JOIN ArtistaMusica am ON am.artista_id = a.id
     LEFT JOIN BackingTrack bt  ON bt.musica_id = am.musica_id
     GROUP BY a.id
     ORDER BY backing_tracks DESC, a.nome_artistico`
  );
  res.render('artists', { title: 'Artistas', artists: rows });
});

router.get('/artists/:id', async (req, res, next) => {
  const id = Number(req.params.id);

  const head = await db.query('SELECT * FROM Artista WHERE id = $1', [id]);
  const artist = head.rows[0];
  if (!artist) return next();

  const albums = await db.query(
    `SELECT al.id, al.titulo, al.data_lancamento, al.duracao, aa.papel_artista,
            COUNT(m.id) AS faixas,
            (SELECT string_agg(o.nome_artistico, ', ')
             FROM ArtistaAlbum x JOIN Artista o ON o.id = x.artista_id
             WHERE x.album_id = al.id AND x.artista_id <> $1) AS outros_artistas
     FROM ArtistaAlbum aa
     JOIN Album al ON al.id = aa.album_id
     LEFT JOIN Musica m ON m.album_id = al.id
     WHERE aa.artista_id = $1
     GROUP BY al.id, aa.papel_artista
     ORDER BY al.data_lancamento DESC`,
    [id]
  );

  const songs = await db.query(
    `SELECT m.id, m.titulo, m.duracao, m.numero_faixa, al.titulo AS album,
            am.papel_artista,
            COUNT(bt.id)  AS qtd_bt,
            MIN(bt.valor) AS menor_preco
     FROM ArtistaMusica am
     JOIN Musica m  ON m.id = am.musica_id
     JOIN Album al  ON al.id = m.album_id
     LEFT JOIN BackingTrack bt ON bt.musica_id = m.id
     WHERE am.artista_id = $1
     GROUP BY m.id, al.id, am.papel_artista
     ORDER BY al.data_lancamento, m.numero_faixa`,
    [id]
  );

  // instrumentos mais usados nos backing tracks das músicas desse artista
  const instruments = await db.query(
    `SELECT t.instrumento, COUNT(*) AS qtd
     FROM ArtistaMusica am
     JOIN BackingTrack bt ON bt.musica_id = am.musica_id
     JOIN Track t         ON t.backingtrack_id = bt.id
     WHERE am.artista_id = $1 AND t.instrumento IS NOT NULL
     GROUP BY t.instrumento
     ORDER BY qtd DESC
     LIMIT 6`,
    [id]
  );

  res.render('artist', {
    title: artist.nome_artistico,
    artist,
    albums: albums.rows,
    songs: songs.rows,
    instruments: instruments.rows,
  });
});

module.exports = router;
