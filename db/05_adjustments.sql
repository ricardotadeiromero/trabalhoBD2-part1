-- =====================================================================
-- Trabalho de Banco de Dados II - Parte 01
-- Grupo H - Spotify
-- Ajustes no banco para a aplicacao: senha com hash, indices, views
-- e uma trigger de validacao de compra.
-- Rodar DEPOIS dos scripts de populacao (01, 02 e 04).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Senhas
-- No BD I a senha ficava em texto puro. O bcrypt gera 60 caracteres,
-- entao a coluna precisa crescer antes do UPDATE.
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE Usuario ALTER COLUMN senha TYPE VARCHAR(72);

-- o WHERE evita gerar hash de hash se o script rodar duas vezes
UPDATE Usuario
SET senha = crypt(senha, gen_salt('bf', 10))
WHERE senha NOT LIKE '$2%';

-- os dados estao sem acento ("Baiao"), mas o usuario vai digitar "baião"
CREATE EXTENSION IF NOT EXISTS unaccent;

-- ---------------------------------------------------------------------
-- Reordenar playlist troca a posicao de duas linhas no mesmo UPDATE.
-- Com a UNIQUE normal o Postgres reclama no meio do comando, com
-- DEFERRABLE ele so confere no final.
-- ---------------------------------------------------------------------
ALTER TABLE BackingTrackPlaylist
    DROP CONSTRAINT IF EXISTS backingtrackplaylist_playlist_id_posicao_key;
ALTER TABLE BackingTrackPlaylist
    ADD CONSTRAINT backingtrackplaylist_playlist_id_posicao_key
    UNIQUE (playlist_id, posicao) DEFERRABLE INITIALLY IMMEDIATE;

-- ---------------------------------------------------------------------
-- Indices
-- As UNIQUE compostas ja criam indice pela primeira coluna (ex.: Playlist
-- por usuario_id, Track por backingtrack_id), entao so faltavam estes.
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_backingtrack_musica   ON BackingTrack (musica_id);
CREATE INDEX IF NOT EXISTS idx_compra_backingtrack   ON CompraBackingTrack (backingtrack_id);
CREATE INDEX IF NOT EXISTS idx_btplaylist_bt         ON BackingTrackPlaylist (backingtrack_id);
CREATE INDEX IF NOT EXISTS idx_seguidores_seguidor   ON Seguidores (seguidor_id);
CREATE INDEX IF NOT EXISTS idx_salvas_playlist       ON PlaylistsSalvas (playlist_id);
CREATE INDEX IF NOT EXISTS idx_artistamusica_musica  ON ArtistaMusica (musica_id);
CREATE INDEX IF NOT EXISTS idx_artistaalbum_album    ON ArtistaAlbum (album_id);
CREATE INDEX IF NOT EXISTS idx_track_instrumento     ON Track (instrumento);

-- ---------------------------------------------------------------------
-- View do catalogo: uma linha por backing track ja com musica, album,
-- artistas, criador, instrumentos dos stems e vendas aprovadas.
-- E a base da tela de busca e dos cards espalhados pelo site.
-- Os LATERAL sao pra nao multiplicar linha (artistas x stems x compras).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_catalog AS
SELECT bt.id,
       bt.nome,
       bt.valor,
       bt.data_criacao,
       bt.duracao,
       m.id                AS musica_id,
       m.titulo            AS musica,
       al.id               AS album_id,
       al.titulo           AS album,
       u.id                AS criador_id,
       u.nome              AS criador,
       u.nivel_experiencia AS criador_nivel,
       COALESCE(art.artistas, '-')        AS artistas,
       COALESCE(art.artista_ids, '{}')    AS artista_ids,
       COALESCE(st.instrumentos, '{}')    AS instrumentos,
       COALESCE(st.qtd_stems, 0)          AS qtd_stems,
       COALESCE(vd.vendas, 0)             AS vendas,
       COALESCE(vd.receita, 0)            AS receita
FROM BackingTrack bt
JOIN Musica m   ON m.id  = bt.musica_id
JOIN Album al   ON al.id = m.album_id
JOIN Usuario u  ON u.id  = bt.usuario_id
LEFT JOIN LATERAL (
    SELECT string_agg(a.nome_artistico, ', ' ORDER BY a.nome_artistico) AS artistas,
           array_agg(a.id) AS artista_ids
    FROM ArtistaMusica am
    JOIN Artista a ON a.id = am.artista_id
    WHERE am.musica_id = m.id
) art ON TRUE
LEFT JOIN LATERAL (
    SELECT array_agg(DISTINCT t.instrumento) FILTER (WHERE t.instrumento IS NOT NULL) AS instrumentos,
           COUNT(*) AS qtd_stems
    FROM Track t
    WHERE t.backingtrack_id = bt.id
) st ON TRUE
LEFT JOIN LATERAL (
    SELECT COUNT(*)     AS vendas,
           SUM(c.valor) AS receita
    FROM CompraBackingTrack c
    WHERE c.backingtrack_id = bt.id
      AND c.status_pagamento = 'aprovado'
) vd ON TRUE;

-- Resumo de cada usuario, usado no perfil e na tela de pessoas
CREATE OR REPLACE VIEW v_user_summary AS
SELECT u.id,
       u.nome,
       u.nivel_experiencia,
       (SELECT COUNT(*) FROM Seguidores s   WHERE s.seguido_id  = u.id) AS seguidores,
       (SELECT COUNT(*) FROM Seguidores s   WHERE s.seguidor_id = u.id) AS seguindo,
       (SELECT COUNT(*) FROM BackingTrack b WHERE b.usuario_id  = u.id) AS publicados,
       (SELECT COUNT(*) FROM Playlist p     WHERE p.usuario_id  = u.id) AS playlists
FROM Usuario u;

-- ---------------------------------------------------------------------
-- Trigger: quem publicou o backing track nao pode comprar ele mesmo.
-- A aplicacao ja barra isso, mas assim vale pra qualquer insert.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_purchase_owner() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM BackingTrack
               WHERE id = NEW.backingtrack_id AND usuario_id = NEW.comprador_id) THEN
        RAISE EXCEPTION 'O criador nao pode comprar o proprio backing track'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_purchase_owner ON CompraBackingTrack;
CREATE TRIGGER trg_check_purchase_owner
    BEFORE INSERT OR UPDATE ON CompraBackingTrack
    FOR EACH ROW EXECUTE FUNCTION check_purchase_owner();
