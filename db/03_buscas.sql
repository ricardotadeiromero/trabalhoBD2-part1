-- =====================================================================
-- Trabalho de Banco de Dados I - Parte 03
-- Grupo H - Spotify
-- Etapa 3: Buscas
-- =====================================================================

-- ---------------------------------------------------------------------
-- Busca 1 (2,5 pontos)
-- Qual o nome dos artistas que possuem mais de 5 albuns publicados?
-- ---------------------------------------------------------------------
SELECT a.nome_artistico,
       COUNT(aa.album_id) AS total_albuns
FROM Artista a
JOIN ArtistaAlbum aa ON aa.artista_id = a.id
GROUP BY a.id, a.nome_artistico
HAVING COUNT(aa.album_id) > 5
ORDER BY total_albuns DESC;

-- ---------------------------------------------------------------------
-- Busca 2 (3,5 pontos)
-- Qual o artista que possui o maior numero de musicas publicadas?
-- Se mais de um, apresentar o primeiro em ordem alfabetica.
-- ---------------------------------------------------------------------
SELECT a.nome_artistico,
       COUNT(am.musica_id) AS total_musicas
FROM Artista a
JOIN ArtistaMusica am ON am.artista_id = a.id
GROUP BY a.id, a.nome_artistico
ORDER BY total_musicas DESC, a.nome_artistico ASC
LIMIT 1;

-- ---------------------------------------------------------------------
-- Busca 3 (4 pontos)
-- Qual o nome de usuario do usuario que tem a playlist com a maior
-- duracao media de musicas? Se mais de um, apresentar o primeiro em
-- ordem alfabetica.
-- ---------------------------------------------------------------------
SELECT u.nome                    AS nome_usuario,
       p.nome                    AS playlist,
       ROUND(AVG(m.duracao), 2)  AS duracao_media
FROM Usuario u
JOIN Playlist p              ON p.usuario_id      = u.id
JOIN BackingTrackPlaylist bp ON bp.playlist_id    = p.id
JOIN BackingTrack bt         ON bt.id             = bp.backingtrack_id
JOIN Musica m                ON m.id              = bt.musica_id
GROUP BY u.id, u.nome, p.id, p.nome
ORDER BY duracao_media DESC, u.nome ASC
LIMIT 1;
