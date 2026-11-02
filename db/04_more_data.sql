-- =====================================================================
-- Trabalho de Banco de Dados II - Parte 01
-- Grupo H - Spotify
-- Dados extras para a aplicacao
--
-- A populacao do BD I tinha o minimo pedido (10/5 tuplas), o que deixava
-- varias telas vazias. Aqui entram mais usuarios, musicas, backing tracks,
-- compras etc. Nenhuma tabela foi alterada.
--
-- Diferente do 02_populate, aqui usei VALUES + JOIN nas chaves secundarias
-- em vez de um subselect por coluna, fica bem mais facil de ler.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Usuarios novos (senha em texto puro aqui, o 05_adjustments faz o hash)
-- ---------------------------------------------------------------------
INSERT INTO Usuario (cpf, email, nome, senha, data_nascimento, nivel_experiencia) VALUES
('81726354901', 'kaio.braga@email.com',    'Kaio Braga',    'kaio2024',   '1999-02-11', 'intermediario'),
('29384756102', 'larissa.melo@email.com',  'Larissa Melo',  'larimelo',   '2002-05-30', 'iniciante'),
('47586920313', 'mateus.pinto@email.com',  'Mateus Pinto',  'guitarra10', '1993-10-17', 'avancado'),
('56473829104', 'nina.alves@email.com',    'Nina Alves',    'ninacanta',  '1998-12-03', 'intermediario'),
('65748392015', 'otavio.rocha@email.com',  'Otavio Rocha',  'percussao',  '1991-01-25', 'avancado'),
('74839201526', 'paula.souza@email.com',   'Paula Souza',   'paulinha7',  '2003-07-08', 'iniciante');

-- ---------------------------------------------------------------------
-- Albuns para os artistas que estavam sem nada
-- ---------------------------------------------------------------------
INSERT INTO Album (titulo, data_lancamento, duracao) VALUES
('Sertao em Flor', '2019-06-20', 2380),
('Rotas',          '2020-03-14', 2900),
('Sala Vazia',     '2021-09-09', 1850),
('Mare de Marco',  '2022-03-18', 2450),
('Cantoria',       '2023-07-01', 2200),
('Tres Vozes',     '2024-02-23', 2050);

INSERT INTO ArtistaAlbum (artista_id, album_id, papel_artista)
SELECT a.id, al.id, v.papel
FROM (VALUES
    ('Fulo de Mandacaru', 'Sertao em Flor', 'principal'),
    ('Gira Mundo',        'Rotas',          'principal'),
    ('Helena Rios',       'Sala Vazia',     'principal'),
    ('Jangada Azul',      'Mare de Marco',  'principal'),
    ('Luar do Sertao',    'Cantoria',       'principal'),
    ('Estrela Guia',      'Tres Vozes',     'principal'),
    ('Ana Vento',         'Tres Vozes',     'participacao'),
    ('Dedo de Prosa',     'Cantoria',       'participacao')
) AS v(artista, album, papel)
JOIN Artista a ON a.nome_artistico = v.artista
JOIN Album al  ON al.titulo = v.album;

-- ---------------------------------------------------------------------
-- Musicas (o album Causos ja existia mas nao tinha faixas)
-- ---------------------------------------------------------------------
INSERT INTO Musica (numero_faixa, titulo, duracao, album_id)
SELECT v.faixa, v.titulo, v.duracao, al.id
FROM (VALUES
    (1, 'Causo do Tropeiro',    245, 'Causos'),
    (2, 'Viola Enluarada',      260, 'Causos'),
    (1, 'Xote da Chuva',        190, 'Sertao em Flor'),
    (2, 'Baiao de Dois Tempos', 205, 'Sertao em Flor'),
    (1, 'Marrakech',            360, 'Rotas'),
    (2, 'Bamako',               335, 'Rotas'),
    (3, 'Cusco',                350, 'Rotas'),
    (1, 'Janela',               220, 'Sala Vazia'),
    (2, 'Silencio Bom',         235, 'Sala Vazia'),
    (1, 'Prancha Velha',        200, 'Mare de Marco'),
    (2, 'Onda Quebrada',        215, 'Mare de Marco'),
    (1, 'Repente do Norte',     250, 'Cantoria'),
    (1, 'Coro de Rua',          210, 'Tres Vozes'),
    (2, 'Acalanto',             240, 'Tres Vozes')
) AS v(faixa, titulo, duracao, album)
JOIN Album al ON al.titulo = v.album;

INSERT INTO ArtistaMusica (artista_id, musica_id, papel_artista)
SELECT a.id, m.id, v.papel
FROM (VALUES
    ('Dedo de Prosa',     'Causo do Tropeiro',    'interprete'),
    ('Dedo de Prosa',     'Viola Enluarada',      'interprete'),
    ('Luar do Sertao',    'Viola Enluarada',      'compositor'),
    ('Fulo de Mandacaru', 'Xote da Chuva',        'interprete'),
    ('Fulo de Mandacaru', 'Baiao de Dois Tempos', 'interprete'),
    ('Gira Mundo',        'Marrakech',            'interprete'),
    ('Gira Mundo',        'Bamako',               'interprete'),
    ('Gira Mundo',        'Cusco',                'interprete'),
    ('Helena Rios',       'Janela',               'interprete'),
    ('Helena Rios',       'Silencio Bom',         'interprete'),
    ('Jangada Azul',      'Prancha Velha',        'interprete'),
    ('Jangada Azul',      'Onda Quebrada',        'interprete'),
    ('Luar do Sertao',    'Repente do Norte',     'interprete'),
    ('Estrela Guia',      'Coro de Rua',          'interprete'),
    ('Estrela Guia',      'Acalanto',             'interprete'),
    ('Helena Rios',       'Acalanto',             'participacao')
) AS v(artista, musica, papel)
JOIN Artista a ON a.nome_artistico = v.artista
JOIN Musica m  ON m.titulo = v.musica;

-- ---------------------------------------------------------------------
-- Backing tracks novos
-- ---------------------------------------------------------------------
INSERT INTO BackingTrack (nome, valor, data_criacao, duracao, usuario_id, musica_id)
SELECT v.nome, v.valor, v.data::date, v.duracao, u.id, m.id
FROM (VALUES
    ('Tropeiro Viola Base',     22.90, '2024-03-10', 245, 'mateus.pinto@email.com', 'Causo do Tropeiro'),
    ('Viola Enluarada Full',    27.90, '2024-04-02', 260, 'bruno.sales@email.com',  'Viola Enluarada'),
    ('Xote da Chuva Sanfona',   18.90, '2024-05-15', 190, 'otavio.rocha@email.com', 'Xote da Chuva'),
    ('Baiao Dois Tempos Perc',  16.90, '2024-06-21', 205, 'otavio.rocha@email.com', 'Baiao de Dois Tempos'),
    ('Marrakech Oud Groove',    44.90, '2024-08-08', 360, 'mateus.pinto@email.com', 'Marrakech'),
    ('Bamako Kora Loop',        39.90, '2024-09-12', 335, 'elisa.ramos@email.com',  'Bamako'),
    ('Cusco Andino',            42.90, '2024-10-30', 350, 'diego.farias@email.com', 'Cusco'),
    ('Janela Piano Only',       19.90, '2024-11-18', 220, 'nina.alves@email.com',   'Janela'),
    ('Silencio Bom Strings',    24.90, '2025-01-09', 235, 'diego.farias@email.com', 'Silencio Bom'),
    ('Prancha Velha Rock',      21.90, '2025-02-14', 200, 'mateus.pinto@email.com', 'Prancha Velha'),
    ('Onda Quebrada Drums',     17.90, '2025-03-22', 215, 'otavio.rocha@email.com', 'Onda Quebrada'),
    ('Repente Pandeiro',        14.90, '2025-04-30', 250, 'kaio.braga@email.com',   'Repente do Norte'),
    ('Coro de Rua A Cappella',  29.90, '2025-06-06', 210, 'nina.alves@email.com',   'Coro de Rua'),
    ('Acalanto Ninar',           9.90, '2025-07-19', 240, 'larissa.melo@email.com', 'Acalanto'),
    ('Linha do Mar Bossa',      26.90, '2025-08-25', 225, 'kaio.braga@email.com',   'Linha do Mar'),
    ('Sal na Pele Acustico',    19.90, '2025-10-02', 215, 'bruno.sales@email.com',  'Sal na Pele'),
    ('Banzeiro Folk',           23.90, '2026-01-12', 300, 'elisa.ramos@email.com',  'Banzeiro'),
    ('Primeiro Raio Ensaio',     7.90, '2026-03-03', 200, 'alice.prado@email.com',  'Primeiro Raio')
) AS v(nome, valor, data, duracao, email, musica)
JOIN Usuario u ON u.email = v.email
JOIN Musica m  ON m.titulo = v.musica;

-- ---------------------------------------------------------------------
-- Stems (Track)
-- ---------------------------------------------------------------------
INSERT INTO Track (nome_faixa, instrumento, duracao, backingtrack_id)
SELECT v.faixa, v.instrumento, bt.duracao, bt.id
FROM (VALUES
    ('Violao Dedilhado',   'violao',        'Novo Dia Violao'),
    ('Viola Caipira',      'viola caipira', 'Tropeiro Viola Base'),
    ('Baixo Acustico',     'baixo',         'Tropeiro Viola Base'),
    ('Viola Ponteada',     'viola caipira', 'Viola Enluarada Full'),
    ('Violao 7 Cordas',    'violao',        'Viola Enluarada Full'),
    ('Percussao Leve',     'percussao',     'Viola Enluarada Full'),
    ('Sanfona',            'sanfona',       'Xote da Chuva Sanfona'),
    ('Zabumba',            'zabumba',       'Xote da Chuva Sanfona'),
    ('Triangulo',          'triangulo',     'Xote da Chuva Sanfona'),
    ('Zabumba Seca',       'zabumba',       'Baiao Dois Tempos Perc'),
    ('Triangulo Aberto',   'triangulo',     'Baiao Dois Tempos Perc'),
    ('Oud',                'oud',           'Marrakech Oud Groove'),
    ('Darbuka',            'percussao',     'Marrakech Oud Groove'),
    ('Baixo Synth',        'sintetizador',  'Marrakech Oud Groove'),
    ('Kora',               'kora',          'Bamako Kora Loop'),
    ('Djembe',             'percussao',     'Bamako Kora Loop'),
    ('Quena',              'flauta',        'Cusco Andino'),
    ('Charango',           'charango',      'Cusco Andino'),
    ('Bombo Leguero',      'percussao',     'Cusco Andino'),
    ('Piano',              'piano',         'Janela Piano Only'),
    ('Violino I',          'violino',       'Silencio Bom Strings'),
    ('Viola de Arco',      'viola de arco', 'Silencio Bom Strings'),
    ('Violoncelo',         'violoncelo',    'Silencio Bom Strings'),
    ('Guitarra Base',      'guitarra',      'Prancha Velha Rock'),
    ('Baixo',              'baixo',         'Prancha Velha Rock'),
    ('Bateria',            'bateria',       'Prancha Velha Rock'),
    ('Bateria Completa',   'bateria',       'Onda Quebrada Drums'),
    ('Overheads',          'bateria',       'Onda Quebrada Drums'),
    ('Pandeiro',           'pandeiro',      'Repente Pandeiro'),
    ('Viola Repentista',   'viola caipira', 'Repente Pandeiro'),
    ('Voz Soprano',        'voz',           'Coro de Rua A Cappella'),
    ('Voz Contralto',      'voz',           'Coro de Rua A Cappella'),
    ('Voz Baixo',          'voz',           'Coro de Rua A Cappella'),
    ('Caixinha de Musica', 'sintetizador',  'Acalanto Ninar'),
    ('Piano Suave',        'piano',         'Acalanto Ninar'),
    ('Violao Bossa',       'violao',        'Linha do Mar Bossa'),
    ('Contrabaixo',        'baixo',         'Linha do Mar Bossa'),
    ('Escovinha',          'bateria',       'Linha do Mar Bossa'),
    ('Violao',             'violao',        'Sal na Pele Acustico'),
    ('Cajon',              'percussao',     'Sal na Pele Acustico'),
    ('Violao Folk',        'violao',        'Banzeiro Folk'),
    ('Gaita',              'gaita',         'Banzeiro Folk'),
    ('Guia de Piano',      'piano',         'Primeiro Raio Ensaio')
) AS v(faixa, instrumento, bt_nome)
JOIN BackingTrack bt ON bt.nome = v.bt_nome;

-- ---------------------------------------------------------------------
-- Playlists novas
-- ---------------------------------------------------------------------
INSERT INTO Playlist (nome, data_criacao, usuario_id)
SELECT v.nome, v.data::date, u.id
FROM (VALUES
    ('Estudo de Viola', '2024-08-01', 'mateus.pinto@email.com'),
    ('Roda de Forro',   '2024-09-10', 'otavio.rocha@email.com'),
    ('Mundo Afora',     '2024-11-02', 'elisa.ramos@email.com'),
    ('Pianinho',        '2025-01-15', 'nina.alves@email.com'),
    ('Ensaio Banda',    '2025-03-01', 'kaio.braga@email.com'),
    ('Ninar',           '2025-07-20', 'larissa.melo@email.com')
) AS v(nome, data, email)
JOIN Usuario u ON u.email = v.email;

-- os nomes de playlist do seed sao todos diferentes, entao da pra casar so pelo nome
INSERT INTO BackingTrackPlaylist (playlist_id, backingtrack_id, posicao)
SELECT p.id, bt.id, v.pos
FROM (VALUES
    ('Cordas e Alma',   'Mare Alta Strings',      1),
    ('Cordas e Alma',   'Silencio Bom Strings',   2),
    ('Cordas e Alma',   'Cusco Andino',           3),
    ('Jazz da Noite',   'Mar Aberto Jazz',        1),
    ('Jazz da Noite',   'Ressaca Piano',          2),
    ('Jazz da Noite',   'Bamako Kora Loop',       3),
    ('Pe de Serra',     'Xote da Chuva Sanfona',  1),
    ('Pe de Serra',     'Baiao Dois Tempos Perc', 2),
    ('Pe de Serra',     'Choque de Xote Base',    3),
    ('Percussivas',     'Onda Quebrada Drums',    1),
    ('Percussivas',     'Repente Pandeiro',       2),
    ('Percussivas',     'Baiao Dois Tempos Perc', 3),
    ('Graves',          'Prancha Velha Rock',     1),
    ('Graves',          'Linha do Mar Bossa',     2),
    ('Vozes',           'Coro de Rua A Cappella', 1),
    ('Vozes',           'Acalanto Ninar',         2),
    ('Estudo de Viola', 'Tropeiro Viola Base',    1),
    ('Estudo de Viola', 'Viola Enluarada Full',   2),
    ('Estudo de Viola', 'Repente Pandeiro',       3),
    ('Roda de Forro',   'Xote da Chuva Sanfona',  1),
    ('Roda de Forro',   'Choque de Xote Base',    2),
    ('Roda de Forro',   'Luz de Led Synth',       3),
    ('Mundo Afora',     'Marrakech Oud Groove',   1),
    ('Mundo Afora',     'Bamako Kora Loop',       2),
    ('Mundo Afora',     'Cusco Andino',           3),
    ('Pianinho',        'Janela Piano Only',      1),
    ('Pianinho',        'Ressaca Piano',          2),
    ('Pianinho',        'Primeiro Raio Ensaio',   3),
    ('Ensaio Banda',    'Prancha Velha Rock',     1),
    ('Ensaio Banda',    'Onda Quebrada Drums',    2),
    ('Ensaio Banda',    'Rajada Acustica',        3),
    ('Ninar',           'Acalanto Ninar',         1),
    ('Ninar',           'Janela Piano Only',      2)
) AS v(playlist, bt_nome, pos)
JOIN Playlist p      ON p.nome = v.playlist
JOIN BackingTrack bt ON bt.nome = v.bt_nome;

-- ---------------------------------------------------------------------
-- Seguidores
-- ---------------------------------------------------------------------
INSERT INTO Seguidores (seguido_id, seguidor_id)
SELECT a.id, b.id
FROM (VALUES
    ('mateus.pinto@email.com', 'kaio.braga@email.com'),
    ('mateus.pinto@email.com', 'paula.souza@email.com'),
    ('mateus.pinto@email.com', 'igor.mendes@email.com'),
    ('mateus.pinto@email.com', 'bruno.sales@email.com'),
    ('otavio.rocha@email.com', 'fabio.teles@email.com'),
    ('otavio.rocha@email.com', 'gustavo.lima@email.com'),
    ('otavio.rocha@email.com', 'paula.souza@email.com'),
    ('nina.alves@email.com',   'larissa.melo@email.com'),
    ('nina.alves@email.com',   'julia.torres@email.com'),
    ('nina.alves@email.com',   'helena.costa@email.com'),
    ('diego.farias@email.com', 'nina.alves@email.com'),
    ('diego.farias@email.com', 'mateus.pinto@email.com'),
    ('elisa.ramos@email.com',  'mateus.pinto@email.com'),
    ('elisa.ramos@email.com',  'carla.nunes@email.com'),
    ('bruno.sales@email.com',  'kaio.braga@email.com'),
    ('kaio.braga@email.com',   'larissa.melo@email.com'),
    ('larissa.melo@email.com', 'nina.alves@email.com'),
    ('helena.costa@email.com', 'alice.prado@email.com')
) AS v(seguido, seguidor)
JOIN Usuario a ON a.email = v.seguido
JOIN Usuario b ON b.email = v.seguidor;

-- ---------------------------------------------------------------------
-- Playlists salvas
-- ---------------------------------------------------------------------
INSERT INTO PlaylistsSalvas (usuario_id, playlist_id, data_salva)
SELECT u.id, p.id, v.data::date
FROM (VALUES
    ('paula.souza@email.com',  'Roda de Forro',   '2024-10-01'),
    ('paula.souza@email.com',  'Mundo Afora',     '2024-11-20'),
    ('kaio.braga@email.com',   'Estudo de Viola', '2024-08-15'),
    ('larissa.melo@email.com', 'Pianinho',        '2025-02-01'),
    ('julia.torres@email.com', 'Ninar',           '2025-08-02'),
    ('mateus.pinto@email.com', 'Cordas e Alma',   '2024-05-05'),
    ('otavio.rocha@email.com', 'Percussivas',     '2024-06-01'),
    ('nina.alves@email.com',   'Foco Total',      '2024-07-07'),
    ('bruno.sales@email.com',  'Mundo Afora',     '2024-12-12'),
    ('fabio.teles@email.com',  'Roda de Forro',   '2024-09-30')
) AS v(email, playlist, data)
JOIN Usuario u  ON u.email = v.email
JOIN Playlist p ON p.nome = v.playlist;

-- ---------------------------------------------------------------------
-- Compras (valor = preco do backing track na hora da compra)
-- ---------------------------------------------------------------------
INSERT INTO CompraBackingTrack
    (comprador_id, backingtrack_id, valor, metodo_pagamento, data_compra, status_pagamento)
SELECT u.id, bt.id, bt.valor, v.metodo, v.data::date, v.status
FROM (VALUES
    ('kaio.braga@email.com',    'Mare Alta Strings',      'pix',            '2024-06-02', 'aprovado'),
    ('kaio.braga@email.com',    'Prancha Velha Rock',     'cartao_credito', '2025-02-20', 'aprovado'),
    ('kaio.braga@email.com',    'Onda Quebrada Drums',    'pix',            '2025-03-25', 'aprovado'),
    ('larissa.melo@email.com',  'Janela Piano Only',      'pix',            '2024-12-01', 'aprovado'),
    ('larissa.melo@email.com',  'Novo Dia Violao',        'boleto',         '2025-01-05', 'aprovado'),
    ('larissa.melo@email.com',  'Cachoeira Lo-Fi',        'cartao_debito',  '2025-02-11', 'aprovado'),
    ('mateus.pinto@email.com',  'Mar Aberto Jazz',        'cartao_credito', '2024-07-03', 'aprovado'),
    ('mateus.pinto@email.com',  'Bamako Kora Loop',       'pix',            '2024-09-20', 'aprovado'),
    ('mateus.pinto@email.com',  'Viola Enluarada Full',   'pix',            '2024-04-10', 'aprovado'),
    ('mateus.pinto@email.com',  'Onda Quebrada Drums',    'pix',            '2025-04-01', 'aprovado'),
    ('nina.alves@email.com',    'Ressaca Piano',          'pix',            '2024-06-14', 'aprovado'),
    ('nina.alves@email.com',    'Silencio Bom Strings',   'cartao_credito', '2025-01-20', 'aprovado'),
    ('nina.alves@email.com',    'Acalanto Ninar',         'pix',            '2025-07-21', 'aprovado'),
    ('otavio.rocha@email.com',  'Choque de Xote Base',    'pix',            '2024-05-02', 'aprovado'),
    ('otavio.rocha@email.com',  'Repente Pandeiro',       'boleto',         '2025-05-10', 'pendente'),
    ('otavio.rocha@email.com',  'Marrakech Oud Groove',   'cartao_credito', '2024-08-15', 'recusado'),
    ('paula.souza@email.com',   'Xote da Chuva Sanfona',  'pix',            '2024-06-01', 'aprovado'),
    ('paula.souza@email.com',   'Prancha Velha Rock',     'pix',            '2025-03-01', 'aprovado'),
    ('paula.souza@email.com',   'Coro de Rua A Cappella', 'boleto',         '2025-06-15', 'aprovado'),
    ('paula.souza@email.com',   'Cusco Andino',           'cartao_credito', '2024-11-11', 'aprovado'),
    ('alice.prado@email.com',   'Rajada Acustica',        'pix',            '2024-02-01', 'aprovado'),
    ('alice.prado@email.com',   'Janela Piano Only',      'pix',            '2024-12-24', 'aprovado'),
    ('bruno.sales@email.com',   'Marrakech Oud Groove',   'cartao_credito', '2024-08-20', 'aprovado'),
    ('bruno.sales@email.com',   'Cusco Andino',           'pix',            '2024-11-05', 'aprovado'),
    ('carla.nunes@email.com',   'Luz de Led Synth',       'pix',            '2024-02-20', 'aprovado'),
    ('carla.nunes@email.com',   'Xote da Chuva Sanfona',  'cartao_debito',  '2024-06-05', 'aprovado'),
    ('diego.farias@email.com',  'Bamako Kora Loop',       'pix',            '2024-09-30', 'aprovado'),
    ('diego.farias@email.com',  'Tropeiro Viola Base',    'cartao_credito', '2024-03-15', 'aprovado'),
    ('elisa.ramos@email.com',   'Cusco Andino',           'pix',            '2024-11-01', 'aprovado'),
    ('elisa.ramos@email.com',   'Marrakech Oud Groove',   'pix',            '2024-08-12', 'aprovado'),
    ('fabio.teles@email.com',   'Baiao Dois Tempos Perc', 'pix',            '2024-06-25', 'aprovado'),
    ('fabio.teles@email.com',   'Xote da Chuva Sanfona',  'pix',            '2024-05-20', 'aprovado'),
    ('gustavo.lima@email.com',  'Onda Quebrada Drums',    'cartao_debito',  '2025-03-30', 'aprovado'),
    ('gustavo.lima@email.com',  'Baiao Dois Tempos Perc', 'pix',            '2024-07-01', 'aprovado'),
    ('helena.costa@email.com',  'Silencio Bom Strings',   'pix',            '2025-01-12', 'aprovado'),
    ('helena.costa@email.com',  'Banzeiro Folk',          'cartao_credito', '2026-01-20', 'aprovado'),
    ('igor.mendes@email.com',   'Prancha Velha Rock',     'cartao_credito', '2025-02-28', 'aprovado'),
    ('igor.mendes@email.com',   'Linha do Mar Bossa',     'pix',            '2025-09-01', 'aprovado'),
    ('julia.torres@email.com',  'Coro de Rua A Cappella', 'pix',            '2025-06-10', 'aprovado'),
    ('julia.torres@email.com',  'Acalanto Ninar',         'pix',            '2025-08-01', 'aprovado')
) AS v(email, bt_nome, metodo, data, status)
JOIN Usuario u       ON u.email = v.email
JOIN BackingTrack bt ON bt.nome = v.bt_nome;
