-- =====================================================================
-- Trabalho de Banco de Dados I - Parte 03
-- Grupo H - Spotify
-- Etapa 2: Populacao do banco de dados
--
-- Tabelas de entidades: ao menos 10 tuplas.
-- Tabelas de relacionamentos: ao menos 5 tuplas.
-- Os IDs sao gerados pelo SERIAL; as chaves estrangeiras sao
-- preenchidas com subconsultas sobre as chaves secundarias (UNIQUE).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Usuario (10 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO Usuario (cpf, email, nome, senha, data_nascimento, nivel_experiencia) VALUES
('39053344705', 'alice.prado@email.com',   'Alice Prado',    'segredo123', '1998-03-12', 'iniciante'),
('15350946056', 'bruno.sales@email.com',   'Bruno Sales',    'violao2020', '1995-07-25', 'avancado'),
('82545778307', 'carla.nunes@email.com',   'Carla Nunes',    'lofi4ever',  '2000-01-30', 'intermediario'),
('64023918200', 'diego.farias@email.com',  'Diego Farias',   'cordas456',  '1992-11-08', 'avancado'),
('70318492155', 'elisa.ramos@email.com',   'Elisa Ramos',    'jazzmania',  '1997-05-19', 'avancado'),
('28194056733', 'fabio.teles@email.com',   'Fabio Teles',    'forrozado',  '1990-09-02', 'intermediario'),
('91627384510', 'gustavo.lima@email.com',  'Gustavo Reis',   'bateria789', '2001-12-14', 'iniciante'),
('45079813622', 'helena.costa@email.com',  'Helena Costa',   'focototal',  '1999-06-27', 'intermediario'),
('53861249077', 'igor.mendes@email.com',   'Igor Mendes',    'baixolar',   '1994-04-03', 'iniciante'),
('37294850166', 'julia.torres@email.com',  'Julia Torres',   'vozativa',   '1996-08-21', 'avancado');

-- ---------------------------------------------------------------------
-- Artista (10 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO Artista (nome_artistico, data_criacao, biografia) VALUES
('Ana Vento',         '2010-05-01', 'Cantora e compositora de MPB contemporanea.'),
('Baiao Eletrico',    '2008-02-20', 'Banda que mistura forro tradicional com musica eletronica.'),
('Clara Mare',        '2015-09-10', 'Projeto solo de indie folk inspirado no litoral.'),
('Dedo de Prosa',     '2012-07-07', 'Duo de viola caipira e causos cantados.'),
('Estrela Guia',      '2018-01-15', 'Trio vocal de harmonias regionais.'),
('Fulo de Mandacaru', '2005-06-24', 'Grupo de xote e baiao do sertao central.'),
('Gira Mundo',        '2011-11-11', 'Coletivo instrumental de world music.'),
('Helena Rios',       '2019-04-02', 'Voz e piano em cancoes minimalistas.'),
('Jangada Azul',      '2009-08-30', 'Banda de rock praiano.'),
('Luar do Sertao',    '2016-10-05', 'Repentistas de sertanejo raiz.');

-- ---------------------------------------------------------------------
-- Album (15 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO Album (titulo, data_lancamento, duracao) VALUES
-- albuns de Ana Vento (6)
('Ventania',              '2012-03-01', 2430),
('Correnteza',            '2014-06-10', 2610),
('Horizonte',             '2016-09-05', 2280),
('Aurora',                '2018-04-20', 2520),
('Maresia',               '2020-08-14', 2350),
('Alvorada',              '2022-11-25', 2490),
-- albuns de Baiao Eletrico (7)
('Forro de Tomada',       '2009-06-12', 2100),
('Zabumba Neon',          '2010-06-18', 2040),
('Xote Digital',          '2012-06-22', 2160),
('Asa Branca 2.0',        '2014-06-13', 2220),
('Sanfona Turbo',         '2016-06-17', 2130),
('Pe de Serra Eletrico',  '2018-06-15', 2250),
('Arrasta-Pe Cibernetico','2021-06-11', 2310),
-- demais albuns
('Ondas',                 '2019-05-17', 2760),
('Causos',                '2017-03-08', 1980);

-- ---------------------------------------------------------------------
-- Musica (18 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO Musica (numero_faixa, titulo, duracao, album_id) VALUES
-- musicas de Ana Vento (8)
(1, 'Rajada',          210, (SELECT id FROM Album WHERE titulo = 'Ventania')),
(2, 'Redemoinho',      195, (SELECT id FROM Album WHERE titulo = 'Ventania')),
(1, 'Cachoeira',       240, (SELECT id FROM Album WHERE titulo = 'Correnteza')),
(1, 'Linha do Mar',    225, (SELECT id FROM Album WHERE titulo = 'Horizonte')),
(1, 'Primeiro Raio',   200, (SELECT id FROM Album WHERE titulo = 'Aurora')),
(1, 'Sal na Pele',     215, (SELECT id FROM Album WHERE titulo = 'Maresia')),
(2, 'Espuma',          185, (SELECT id FROM Album WHERE titulo = 'Maresia')),
(1, 'Novo Dia',        230, (SELECT id FROM Album WHERE titulo = 'Alvorada')),
-- musicas de Clara Mare (8, todas no album Ondas)
(1, 'Mare Alta',       320, (SELECT id FROM Album WHERE titulo = 'Ondas')),
(2, 'Ressaca',         280, (SELECT id FROM Album WHERE titulo = 'Ondas')),
(3, 'Banzeiro',        300, (SELECT id FROM Album WHERE titulo = 'Ondas')),
(4, 'Correnteza Fria', 260, (SELECT id FROM Album WHERE titulo = 'Ondas')),
(5, 'Mar Aberto',      340, (SELECT id FROM Album WHERE titulo = 'Ondas')),
(6, 'Farol',           290, (SELECT id FROM Album WHERE titulo = 'Ondas')),
(7, 'Ancora',          310, (SELECT id FROM Album WHERE titulo = 'Ondas')),
(8, 'Porto Seguro',    330, (SELECT id FROM Album WHERE titulo = 'Ondas')),
-- musicas de Baiao Eletrico (2)
(1, 'Choque de Xote',  180, (SELECT id FROM Album WHERE titulo = 'Forro de Tomada')),
(1, 'Luz de Led',      175, (SELECT id FROM Album WHERE titulo = 'Zabumba Neon'));

-- ---------------------------------------------------------------------
-- BackingTrack (10 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO BackingTrack (nome, valor, data_criacao, duracao, usuario_id, musica_id) VALUES
('Rajada Acustica',      19.90, '2023-01-15', 210,
    (SELECT id FROM Usuario WHERE email = 'bruno.sales@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Rajada')),
('Redemoinho Groove',    24.90, '2023-02-10', 195,
    (SELECT id FROM Usuario WHERE email = 'bruno.sales@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Redemoinho')),
('Cachoeira Lo-Fi',      14.90, '2023-03-05', 240,
    (SELECT id FROM Usuario WHERE email = 'carla.nunes@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Cachoeira')),
('Mare Alta Strings',    39.90, '2023-04-12', 320,
    (SELECT id FROM Usuario WHERE email = 'diego.farias@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Mare Alta')),
('Ressaca Piano',        29.90, '2023-05-20', 280,
    (SELECT id FROM Usuario WHERE email = 'diego.farias@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Ressaca')),
('Mar Aberto Jazz',      34.90, '2023-06-08', 340,
    (SELECT id FROM Usuario WHERE email = 'elisa.ramos@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Mar Aberto')),
('Farol Beat',           21.90, '2023-07-14', 290,
    (SELECT id FROM Usuario WHERE email = 'elisa.ramos@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Farol')),
('Choque de Xote Base',  15.90, '2023-08-22', 180,
    (SELECT id FROM Usuario WHERE email = 'fabio.teles@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Choque de Xote')),
('Luz de Led Synth',     17.90, '2023-09-30', 175,
    (SELECT id FROM Usuario WHERE email = 'fabio.teles@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Luz de Led')),
('Novo Dia Violao',      12.90, '2023-10-18', 230,
    (SELECT id FROM Usuario WHERE email = 'alice.prado@email.com'),
    (SELECT id FROM Musica  WHERE titulo = 'Novo Dia'));

-- ---------------------------------------------------------------------
-- Track (12 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO Track (nome_faixa, instrumento, duracao, backingtrack_id) VALUES
('Base Violao',       'violao',       210, (SELECT id FROM BackingTrack WHERE nome = 'Rajada Acustica')),
('Linha de Baixo',    'baixo',        210, (SELECT id FROM BackingTrack WHERE nome = 'Rajada Acustica')),
('Groove de Bateria', 'bateria',      195, (SELECT id FROM BackingTrack WHERE nome = 'Redemoinho Groove')),
('Piano Ambiente',    'piano',        240, (SELECT id FROM BackingTrack WHERE nome = 'Cachoeira Lo-Fi')),
('Primeiro Violino',  'violino',      320, (SELECT id FROM BackingTrack WHERE nome = 'Mare Alta Strings')),
('Violoncelo',        'violoncelo',   320, (SELECT id FROM BackingTrack WHERE nome = 'Mare Alta Strings')),
('Piano Solo',        'piano',        280, (SELECT id FROM BackingTrack WHERE nome = 'Ressaca Piano')),
('Sax Tenor',         'saxofone',     340, (SELECT id FROM BackingTrack WHERE nome = 'Mar Aberto Jazz')),
('Pads Sintetizados', 'sintetizador', 290, (SELECT id FROM BackingTrack WHERE nome = 'Farol Beat')),
('Zabumba Grave',     'zabumba',      180, (SELECT id FROM BackingTrack WHERE nome = 'Choque de Xote Base')),
('Triangulo Agudo',   'triangulo',    180, (SELECT id FROM BackingTrack WHERE nome = 'Choque de Xote Base')),
('Lead Synth',        'sintetizador', 175, (SELECT id FROM BackingTrack WHERE nome = 'Luz de Led Synth'));

-- ---------------------------------------------------------------------
-- Playlist (10 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO Playlist (nome, data_criacao, usuario_id) VALUES
('Treino',        '2024-01-05', (SELECT id FROM Usuario WHERE email = 'alice.prado@email.com')),
('Relax',         '2024-01-20', (SELECT id FROM Usuario WHERE email = 'bruno.sales@email.com')),
('Festa Junina',  '2024-02-14', (SELECT id FROM Usuario WHERE email = 'carla.nunes@email.com')),
('Cordas e Alma', '2024-03-02', (SELECT id FROM Usuario WHERE email = 'diego.farias@email.com')),
('Jazz da Noite', '2024-03-28', (SELECT id FROM Usuario WHERE email = 'elisa.ramos@email.com')),
('Pe de Serra',   '2024-04-11', (SELECT id FROM Usuario WHERE email = 'fabio.teles@email.com')),
('Percussivas',   '2024-05-06', (SELECT id FROM Usuario WHERE email = 'gustavo.lima@email.com')),
('Foco Total',    '2024-05-25', (SELECT id FROM Usuario WHERE email = 'helena.costa@email.com')),
('Graves',        '2024-06-09', (SELECT id FROM Usuario WHERE email = 'igor.mendes@email.com')),
('Vozes',         '2024-06-30', (SELECT id FROM Usuario WHERE email = 'julia.torres@email.com'));

-- ---------------------------------------------------------------------
-- Seguidores (6 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO Seguidores (seguido_id, seguidor_id) VALUES
((SELECT id FROM Usuario WHERE email = 'bruno.sales@email.com'),
 (SELECT id FROM Usuario WHERE email = 'alice.prado@email.com')),
((SELECT id FROM Usuario WHERE email = 'bruno.sales@email.com'),
 (SELECT id FROM Usuario WHERE email = 'carla.nunes@email.com')),
((SELECT id FROM Usuario WHERE email = 'diego.farias@email.com'),
 (SELECT id FROM Usuario WHERE email = 'helena.costa@email.com')),
((SELECT id FROM Usuario WHERE email = 'elisa.ramos@email.com'),
 (SELECT id FROM Usuario WHERE email = 'helena.costa@email.com')),
((SELECT id FROM Usuario WHERE email = 'fabio.teles@email.com'),
 (SELECT id FROM Usuario WHERE email = 'gustavo.lima@email.com')),
((SELECT id FROM Usuario WHERE email = 'julia.torres@email.com'),
 (SELECT id FROM Usuario WHERE email = 'igor.mendes@email.com'));

-- ---------------------------------------------------------------------
-- PlaylistsSalvas (6 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO PlaylistsSalvas (usuario_id, playlist_id, data_salva) VALUES
((SELECT id FROM Usuario WHERE email = 'alice.prado@email.com'),
 (SELECT id FROM Playlist WHERE nome = 'Foco Total'), '2024-06-01'),
((SELECT id FROM Usuario WHERE email = 'bruno.sales@email.com'),
 (SELECT id FROM Playlist WHERE nome = 'Foco Total'), '2024-06-03'),
((SELECT id FROM Usuario WHERE email = 'carla.nunes@email.com'),
 (SELECT id FROM Playlist WHERE nome = 'Jazz da Noite'), '2024-06-10'),
((SELECT id FROM Usuario WHERE email = 'gustavo.lima@email.com'),
 (SELECT id FROM Playlist WHERE nome = 'Pe de Serra'), '2024-06-15'),
((SELECT id FROM Usuario WHERE email = 'helena.costa@email.com'),
 (SELECT id FROM Playlist WHERE nome = 'Cordas e Alma'), '2024-06-22'),
((SELECT id FROM Usuario WHERE email = 'igor.mendes@email.com'),
 (SELECT id FROM Playlist WHERE nome = 'Relax'), '2024-07-02');

-- ---------------------------------------------------------------------
-- CompraBackingTrack (6 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO CompraBackingTrack
    (comprador_id, backingtrack_id, valor, metodo_pagamento, data_compra, status_pagamento) VALUES
((SELECT id FROM Usuario WHERE email = 'helena.costa@email.com'),
 (SELECT id FROM BackingTrack WHERE nome = 'Mare Alta Strings'),
 39.90, 'pix',           '2024-05-26', 'aprovado'),
((SELECT id FROM Usuario WHERE email = 'helena.costa@email.com'),
 (SELECT id FROM BackingTrack WHERE nome = 'Ressaca Piano'),
 29.90, 'cartao_credito','2024-05-26', 'aprovado'),
((SELECT id FROM Usuario WHERE email = 'alice.prado@email.com'),
 (SELECT id FROM BackingTrack WHERE nome = 'Choque de Xote Base'),
 15.90, 'pix',           '2024-06-05', 'aprovado'),
((SELECT id FROM Usuario WHERE email = 'gustavo.lima@email.com'),
 (SELECT id FROM BackingTrack WHERE nome = 'Redemoinho Groove'),
 24.90, 'boleto',        '2024-06-12', 'pendente'),
((SELECT id FROM Usuario WHERE email = 'igor.mendes@email.com'),
 (SELECT id FROM BackingTrack WHERE nome = 'Rajada Acustica'),
 19.90, 'cartao_debito', '2024-06-20', 'aprovado'),
((SELECT id FROM Usuario WHERE email = 'julia.torres@email.com'),
 (SELECT id FROM BackingTrack WHERE nome = 'Mar Aberto Jazz'),
 34.90, 'pix',           '2024-07-01', 'recusado');

-- ---------------------------------------------------------------------
-- BackingTrackPlaylist (10 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO BackingTrackPlaylist (playlist_id, backingtrack_id, posicao) VALUES
-- Treino (Alice): musicas curtas
((SELECT id FROM Playlist WHERE nome = 'Treino'),
 (SELECT id FROM BackingTrack WHERE nome = 'Rajada Acustica'), 1),
((SELECT id FROM Playlist WHERE nome = 'Treino'),
 (SELECT id FROM BackingTrack WHERE nome = 'Choque de Xote Base'), 2),
-- Relax (Bruno)
((SELECT id FROM Playlist WHERE nome = 'Relax'),
 (SELECT id FROM BackingTrack WHERE nome = 'Cachoeira Lo-Fi'), 1),
((SELECT id FROM Playlist WHERE nome = 'Relax'),
 (SELECT id FROM BackingTrack WHERE nome = 'Novo Dia Violao'), 2),
-- Festa Junina (Carla)
((SELECT id FROM Playlist WHERE nome = 'Festa Junina'),
 (SELECT id FROM BackingTrack WHERE nome = 'Choque de Xote Base'), 1),
((SELECT id FROM Playlist WHERE nome = 'Festa Junina'),
 (SELECT id FROM BackingTrack WHERE nome = 'Luz de Led Synth'), 2),
-- Foco Total (Helena): musicas longas
((SELECT id FROM Playlist WHERE nome = 'Foco Total'),
 (SELECT id FROM BackingTrack WHERE nome = 'Mare Alta Strings'), 1),
((SELECT id FROM Playlist WHERE nome = 'Foco Total'),
 (SELECT id FROM BackingTrack WHERE nome = 'Ressaca Piano'), 2),
((SELECT id FROM Playlist WHERE nome = 'Foco Total'),
 (SELECT id FROM BackingTrack WHERE nome = 'Mar Aberto Jazz'), 3),
((SELECT id FROM Playlist WHERE nome = 'Foco Total'),
 (SELECT id FROM BackingTrack WHERE nome = 'Farol Beat'), 4);

-- ---------------------------------------------------------------------
-- ArtistaAlbum (17 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO ArtistaAlbum (artista_id, album_id, papel_artista) VALUES
-- Ana Vento: 6 albuns
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Album WHERE titulo = 'Ventania'),   'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Album WHERE titulo = 'Correnteza'), 'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Album WHERE titulo = 'Horizonte'),  'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Album WHERE titulo = 'Aurora'),     'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Album WHERE titulo = 'Maresia'),    'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Album WHERE titulo = 'Alvorada'),   'principal'),
-- Baiao Eletrico: 7 albuns
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Album WHERE titulo = 'Forro de Tomada'),        'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Album WHERE titulo = 'Zabumba Neon'),           'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Album WHERE titulo = 'Xote Digital'),           'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Album WHERE titulo = 'Asa Branca 2.0'),         'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Album WHERE titulo = 'Sanfona Turbo'),          'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Album WHERE titulo = 'Pe de Serra Eletrico'),   'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Album WHERE titulo = 'Arrasta-Pe Cibernetico'), 'principal'),
-- demais artistas
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Album WHERE titulo = 'Ondas'),  'principal'),
((SELECT id FROM Artista WHERE nome_artistico = 'Dedo de Prosa'),
 (SELECT id FROM Album WHERE titulo = 'Causos'), 'principal'),
-- participacoes
((SELECT id FROM Artista WHERE nome_artistico = 'Estrela Guia'),
 (SELECT id FROM Album WHERE titulo = 'Aurora'), 'participacao'),
((SELECT id FROM Artista WHERE nome_artistico = 'Gira Mundo'),
 (SELECT id FROM Album WHERE titulo = 'Ondas'),  'participacao');

-- ---------------------------------------------------------------------
-- ArtistaMusica (18 tuplas)
-- ---------------------------------------------------------------------
INSERT INTO ArtistaMusica (artista_id, musica_id, papel_artista) VALUES
-- Ana Vento: 8 musicas
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Musica WHERE titulo = 'Rajada'),        'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Musica WHERE titulo = 'Redemoinho'),    'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Musica WHERE titulo = 'Cachoeira'),     'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Musica WHERE titulo = 'Linha do Mar'),  'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Musica WHERE titulo = 'Primeiro Raio'), 'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Musica WHERE titulo = 'Sal na Pele'),   'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Musica WHERE titulo = 'Espuma'),        'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Ana Vento'),
 (SELECT id FROM Musica WHERE titulo = 'Novo Dia'),      'interprete'),
-- Clara Mare: 8 musicas
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Musica WHERE titulo = 'Mare Alta'),       'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Musica WHERE titulo = 'Ressaca'),         'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Musica WHERE titulo = 'Banzeiro'),        'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Musica WHERE titulo = 'Correnteza Fria'), 'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Musica WHERE titulo = 'Mar Aberto'),      'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Musica WHERE titulo = 'Farol'),           'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Musica WHERE titulo = 'Ancora'),          'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Clara Mare'),
 (SELECT id FROM Musica WHERE titulo = 'Porto Seguro'),    'interprete'),
-- Baiao Eletrico: 2 musicas
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Musica WHERE titulo = 'Choque de Xote'), 'interprete'),
((SELECT id FROM Artista WHERE nome_artistico = 'Baiao Eletrico'),
 (SELECT id FROM Musica WHERE titulo = 'Luz de Led'),     'interprete');
