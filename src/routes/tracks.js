const express = require('express');
const db = require('../db');
const { requireLogin, setFlash } = require('../middleware');
const { parseDuration } = require('../helpers');

const router = express.Router();

router.get('/tracks/:id', async (req, res, next) => {
  const id = Number(req.params.id);
  const user = req.session.user;

  const main = await db.query('SELECT * FROM v_catalog WHERE id = $1', [id]);
  const track = main.rows[0];
  if (!track) return next();

  const stems = await db.query(
    `SELECT nome_faixa, instrumento, duracao
     FROM Track
     WHERE backingtrack_id = $1
     ORDER BY id`,
    [id]
  );

  const credits = await db.query(
    `SELECT a.id, a.nome_artistico, am.papel_artista
     FROM ArtistaMusica am
     JOIN Artista a ON a.id = am.artista_id
     WHERE am.musica_id = $1
     ORDER BY am.papel_artista DESC, a.nome_artistico`,
    [track.musica_id]
  );

  const inPlaylists = await db.query(
    `SELECT p.id, p.nome, u.nome AS dono
     FROM BackingTrackPlaylist btp
     JOIN Playlist p ON p.id = btp.playlist_id
     JOIN Usuario u  ON u.id = p.usuario_id
     WHERE btp.backingtrack_id = $1
     ORDER BY p.nome`,
    [id]
  );

  // "quem comprou este também comprou": outras compras aprovadas dos mesmos compradores
  const alsoBought = await db.query(
    `SELECT c.id, c.nome, c.musica, c.artistas, c.valor, c.criador,
            COUNT(*) AS em_comum
     FROM CompraBackingTrack este
     JOIN CompraBackingTrack outro
       ON outro.comprador_id = este.comprador_id
      AND outro.backingtrack_id <> este.backingtrack_id
      AND outro.status_pagamento = 'aprovado'
     JOIN v_catalog c ON c.id = outro.backingtrack_id
     WHERE este.backingtrack_id = $1
       AND este.status_pagamento = 'aprovado'
     GROUP BY c.id, c.nome, c.musica, c.artistas, c.valor, c.criador
     ORDER BY em_comum DESC, c.nome
     LIMIT 4`,
    [id]
  );

  const sameSong = await db.query(
    `SELECT id, nome, criador, valor, instrumentos
     FROM v_catalog
     WHERE musica_id = $1 AND id <> $2
     ORDER BY vendas DESC`,
    [track.musica_id, id]
  );

  let purchase = null;
  let myPlaylists = [];
  if (user) {
    const p = await db.query(
      `SELECT status_pagamento, metodo_pagamento, data_compra, valor
       FROM CompraBackingTrack
       WHERE comprador_id = $1 AND backingtrack_id = $2`,
      [user.id, id]
    );
    purchase = p.rows[0] || null;

    const pl = await db.query(
      `SELECT p.id, p.nome
       FROM Playlist p
       WHERE p.usuario_id = $1
         AND NOT EXISTS (SELECT 1 FROM BackingTrackPlaylist x
                         WHERE x.playlist_id = p.id AND x.backingtrack_id = $2)
       ORDER BY p.nome`,
      [user.id, id]
    );
    myPlaylists = pl.rows;
  }

  res.render('track', {
    title: track.nome,
    track,
    stems: stems.rows,
    credits: credits.rows,
    inPlaylists: inPlaylists.rows,
    alsoBought: alsoBought.rows,
    sameSong: sameSong.rows,
    purchase,
    myPlaylists,
    isOwner: user && user.id === track.criador_id,
  });
});

router.post('/tracks/:id/buy', requireLogin, async (req, res) => {
  const id = Number(req.params.id);
  const user = req.session.user;
  const method = req.body.metodo;

  if (!['pix', 'cartao_credito', 'cartao_debito', 'boleto'].includes(method)) {
    setFlash(req, 'error', 'Escolha uma forma de pagamento.');
    return res.redirect(`/tracks/${id}`);
  }

  // pagamento é simulado: boleto fica pendente até o usuário confirmar
  const status = method === 'boleto' ? 'pendente' : 'aprovado';

  try {
    // a PK é (comprador, backing track), então se a compra anterior foi
    // recusada reaproveitamos a mesma linha em vez de inserir outra
    const result = await db.query(
      `INSERT INTO CompraBackingTrack
           (comprador_id, backingtrack_id, valor, metodo_pagamento, status_pagamento)
       SELECT $1, bt.id, bt.valor, $3, $4
       FROM BackingTrack bt
       WHERE bt.id = $2
       ON CONFLICT (comprador_id, backingtrack_id) DO UPDATE
          SET metodo_pagamento = EXCLUDED.metodo_pagamento,
              status_pagamento = EXCLUDED.status_pagamento,
              valor            = EXCLUDED.valor,
              data_compra      = CURRENT_DATE
        WHERE CompraBackingTrack.status_pagamento = 'recusado'`,
      [user.id, id, method, status]
    );

    if (result.rowCount === 0) {
      setFlash(req, 'info', 'Você já tem esse backing track.');
    } else if (status === 'pendente') {
      setFlash(req, 'info', 'Boleto gerado! Assim que pagar, confirme na sua biblioteca.');
    } else {
      setFlash(req, 'success', 'Compra aprovada. Já está na sua biblioteca.');
    }
  } catch (err) {
    // vem da trigger trg_check_purchase_owner
    if (err.code === '23514') {
      setFlash(req, 'error', 'Você não pode comprar o seu próprio backing track.');
    } else {
      throw err;
    }
  }
  res.redirect(`/tracks/${id}`);
});

router.get('/publish', requireLogin, async (req, res) => {
  const songs = await loadSongOptions();
  res.render('publish', { title: 'Publicar', songs, form: {}, error: null });
});

router.post('/publish', requireLogin, async (req, res) => {
  const user = req.session.user;
  const form = {
    nome: (req.body.nome || '').trim(),
    musica_id: Number(req.body.musica_id) || null,
    valor: req.body.valor,
    duracao: req.body.duracao,
  };

  // os stems chegam como arrays paralelos (stem_nome[], stem_instrumento[])
  const names = [].concat(req.body.stem_nome || []);
  const instruments = [].concat(req.body.stem_instrumento || []);
  const stems = names
    .map((name, i) => ({ nome: name.trim(), instrumento: (instruments[i] || '').trim().toLowerCase() }))
    .filter((s) => s.nome);

  const seconds = parseDuration(form.duracao);
  const price = Number(String(form.valor).replace(',', '.'));

  const fail = async (error) =>
    res.status(400).render('publish', {
      title: 'Publicar',
      songs: await loadSongOptions(),
      form: { ...form, stems },
      error,
    });

  if (!form.nome || !form.musica_id) return fail('Dê um nome e escolha a música.');
  if (Number.isNaN(price) || price < 0) return fail('Preço inválido.');
  if (!seconds) return fail('Duração no formato mm:ss, por exemplo 3:45.');
  if (stems.length === 0) return fail('Adicione pelo menos um stem (faixa separada).');

  try {
    const newId = await db.withTransaction(async (client) => {
      const inserted = await client.query(
        `INSERT INTO BackingTrack (nome, valor, duracao, usuario_id, musica_id)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id`,
        [form.nome, price, seconds, user.id, form.musica_id]
      );
      const btId = inserted.rows[0].id;

      for (const stem of stems) {
        await client.query(
          `INSERT INTO Track (nome_faixa, instrumento, duracao, backingtrack_id)
           VALUES ($1, $2, $3, $4)`,
          [stem.nome, stem.instrumento || null, seconds, btId]
        );
      }
      return btId;
    });

    setFlash(req, 'success', 'Backing track publicado!');
    res.redirect(`/tracks/${newId}`);
  } catch (err) {
    if (err.code === '23505') {
      return fail(
        err.constraint && err.constraint.startsWith('track_')
          ? 'Dois stems estão com o mesmo nome.'
          : 'Você já publicou um backing track com esse nome para essa música.'
      );
    }
    throw err;
  }
});

function loadSongOptions() {
  return db
    .query(
      `SELECT m.id, m.titulo, al.titulo AS album,
              COALESCE(string_agg(a.nome_artistico, ', ' ORDER BY a.nome_artistico), '-') AS artistas
       FROM Musica m
       JOIN Album al ON al.id = m.album_id
       LEFT JOIN ArtistaMusica am ON am.musica_id = m.id
       LEFT JOIN Artista a        ON a.id = am.artista_id
       GROUP BY m.id, al.titulo
       ORDER BY artistas, m.titulo`
    )
    .then((r) => r.rows);
}

module.exports = router;
