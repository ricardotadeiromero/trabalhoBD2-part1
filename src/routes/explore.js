const express = require('express');
const db = require('../db');

const router = express.Router();

const sortOptions = {
  popular: 'c.vendas DESC, c.data_criacao DESC',
  recent: 'c.data_criacao DESC',
  price_asc: 'c.valor ASC, c.nome',
  price_desc: 'c.valor DESC, c.nome',
  name: 'c.nome ASC',
};

router.get('/explore', async (req, res) => {
  const user = req.session.user;
  const filters = {
    q: (req.query.q || '').trim(),
    instrument: req.query.instrument || '',
    artist: req.query.artist || '',
    song: req.query.song || '',
    maxPrice: req.query.maxPrice || '',
    level: req.query.level || '',
    sort: sortOptions[req.query.sort] ? req.query.sort : 'popular',
    hideOwned: req.query.hideOwned === '1',
  };

  // monta o WHERE conforme os filtros que vieram preenchidos
  const conditions = [];
  const params = [];
  const addParam = (value) => {
    params.push(value);
    return `$${params.length}`;
  };

  if (filters.q) {
    const p = addParam(`%${filters.q}%`);
    conditions.push(`unaccent(concat_ws(' ', c.nome, c.musica, c.album, c.artistas)) ILIKE unaccent(${p})`);
  }
  if (filters.instrument) {
    conditions.push(`${addParam(filters.instrument)} = ANY (c.instrumentos)`);
  }
  if (filters.artist) {
    conditions.push(`${addParam(Number(filters.artist))}::int = ANY (c.artista_ids)`);
  }
  if (filters.song) {
    conditions.push(`c.musica_id = ${addParam(Number(filters.song))}`);
  }
  if (filters.maxPrice) {
    conditions.push(`c.valor <= ${addParam(Number(filters.maxPrice))}`);
  }
  if (filters.level) {
    conditions.push(`c.criador_nivel = ${addParam(filters.level)}`);
  }
  if (filters.hideOwned && user) {
    const p = addParam(user.id);
    conditions.push(`c.criador_id <> ${p}`);
    conditions.push(`NOT EXISTS (
      SELECT 1 FROM CompraBackingTrack cb
      WHERE cb.backingtrack_id = c.id
        AND cb.comprador_id = ${p}
        AND cb.status_pagamento <> 'recusado')`);
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const results = await db.query(
    `SELECT c.* FROM v_catalog c ${where} ORDER BY ${sortOptions[filters.sort]}`,
    params
  );

  const instruments = await db.query(
    `SELECT instrumento, COUNT(*) AS qtd
     FROM Track
     WHERE instrumento IS NOT NULL
     GROUP BY instrumento
     ORDER BY instrumento`
  );
  const artists = await db.query(
    `SELECT DISTINCT a.id, a.nome_artistico
     FROM Artista a
     JOIN ArtistaMusica am ON am.artista_id = a.id
     JOIN BackingTrack bt  ON bt.musica_id = am.musica_id
     ORDER BY a.nome_artistico`
  );

  let songTitle = null;
  if (filters.song) {
    const song = await db.query('SELECT titulo FROM Musica WHERE id = $1', [Number(filters.song)]);
    songTitle = song.rows[0]?.titulo || null;
  }

  res.render('explore', {
    title: 'Explorar',
    tracks: results.rows,
    instruments: instruments.rows,
    artists: artists.rows,
    filters,
    songTitle,
  });
});

module.exports = router;
