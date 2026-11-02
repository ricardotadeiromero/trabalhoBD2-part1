-- =====================================================================
-- Trabalho de Banco de Dados I - Parte 03
-- Grupo H - Spotify
-- Etapa 1: Criacao dos esquemas das tabelas
--
-- Observacao: seguindo a recomendacao do professor, as chaves compostas
-- do modelo relacional foram substituidas por IDs sequenciais (SERIAL),
-- e as antigas chaves primarias viraram chaves secundarias (UNIQUE).
-- =====================================================================

-- Tabela de usuarios da plataforma
CREATE TABLE Usuario (
    id                SERIAL PRIMARY KEY,
    cpf               CHAR(11)     NOT NULL UNIQUE,
    email             VARCHAR(60)  NOT NULL UNIQUE,
    nome              VARCHAR(100) NOT NULL,
    senha             VARCHAR(50)  NOT NULL,
    data_nascimento   DATE,
    nivel_experiencia VARCHAR(15)  DEFAULT 'iniciante'
        CHECK (nivel_experiencia IN ('iniciante', 'intermediario', 'avancado'))
);

-- Tabela de artistas
CREATE TABLE Artista (
    id             SERIAL PRIMARY KEY,
    nome_artistico VARCHAR(60) NOT NULL,
    data_criacao   DATE        NOT NULL,
    biografia      VARCHAR(300),
    UNIQUE (nome_artistico, data_criacao)
);

-- Tabela de albuns
CREATE TABLE Album (
    id              SERIAL PRIMARY KEY,
    titulo          VARCHAR(60) NOT NULL,
    data_lancamento DATE        NOT NULL,
    duracao         INT CHECK (duracao > 0),
    UNIQUE (titulo, data_lancamento)
);

-- Tabela de musicas (entidade fraca de Album)
CREATE TABLE Musica (
    id           SERIAL PRIMARY KEY,
    numero_faixa INT         NOT NULL CHECK (numero_faixa > 0),
    titulo       VARCHAR(60) NOT NULL,
    duracao      INT CHECK (duracao > 0),
    album_id     INT         NOT NULL,
    FOREIGN KEY (album_id) REFERENCES Album (id),
    UNIQUE (album_id, numero_faixa, titulo)
);

-- Tabela de backing tracks (entidade fraca de Usuario e Musica)
CREATE TABLE BackingTrack (
    id           SERIAL PRIMARY KEY,
    nome         VARCHAR(60)   NOT NULL,
    valor        NUMERIC(8, 2) NOT NULL CHECK (valor >= 0),
    data_criacao DATE          DEFAULT CURRENT_DATE,
    duracao      INT CHECK (duracao > 0),
    usuario_id   INT           NOT NULL,
    musica_id    INT           NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario (id),
    FOREIGN KEY (musica_id)  REFERENCES Musica (id),
    UNIQUE (usuario_id, nome, musica_id)
);

-- Tabela de tracks/stems (entidade fraca de BackingTrack)
CREATE TABLE Track (
    id              SERIAL PRIMARY KEY,
    nome_faixa      VARCHAR(60) NOT NULL,
    instrumento     VARCHAR(30),
    duracao         INT CHECK (duracao > 0),
    backingtrack_id INT         NOT NULL,
    FOREIGN KEY (backingtrack_id) REFERENCES BackingTrack (id) ON DELETE CASCADE,
    UNIQUE (backingtrack_id, nome_faixa)
);

-- Tabela de playlists (entidade fraca de Usuario)
CREATE TABLE Playlist (
    id           SERIAL PRIMARY KEY,
    nome         VARCHAR(60) NOT NULL,
    data_criacao DATE        DEFAULT CURRENT_DATE,
    usuario_id   INT         NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario (id),
    UNIQUE (usuario_id, nome)
);

-- Auto-relacionamento Segue (Usuario x Usuario)
CREATE TABLE Seguidores (
    seguido_id  INT NOT NULL,
    seguidor_id INT NOT NULL,
    PRIMARY KEY (seguido_id, seguidor_id),
    FOREIGN KEY (seguido_id)  REFERENCES Usuario (id),
    FOREIGN KEY (seguidor_id) REFERENCES Usuario (id),
    CHECK (seguido_id <> seguidor_id)
);

-- Relacionamento Salva (Usuario x Playlist)
CREATE TABLE PlaylistsSalvas (
    usuario_id  INT NOT NULL,
    playlist_id INT NOT NULL,
    data_salva  DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (usuario_id, playlist_id),
    FOREIGN KEY (usuario_id)  REFERENCES Usuario (id),
    FOREIGN KEY (playlist_id) REFERENCES Playlist (id)
);

-- Relacionamento Adquire (Usuario x BackingTrack)
CREATE TABLE CompraBackingTrack (
    comprador_id     INT           NOT NULL,
    backingtrack_id  INT           NOT NULL,
    valor            NUMERIC(8, 2) NOT NULL CHECK (valor >= 0),
    metodo_pagamento VARCHAR(15)   NOT NULL
        CHECK (metodo_pagamento IN ('pix', 'cartao_credito', 'cartao_debito', 'boleto')),
    data_compra      DATE          DEFAULT CURRENT_DATE,
    status_pagamento VARCHAR(10)   NOT NULL DEFAULT 'pendente'
        CHECK (status_pagamento IN ('pendente', 'aprovado', 'recusado')),
    PRIMARY KEY (comprador_id, backingtrack_id),
    FOREIGN KEY (comprador_id)    REFERENCES Usuario (id),
    FOREIGN KEY (backingtrack_id) REFERENCES BackingTrack (id)
);

-- Relacionamento Contem (Playlist x BackingTrack)
CREATE TABLE BackingTrackPlaylist (
    playlist_id     INT NOT NULL,
    backingtrack_id INT NOT NULL,
    posicao         INT CHECK (posicao > 0),
    PRIMARY KEY (playlist_id, backingtrack_id),
    FOREIGN KEY (playlist_id)     REFERENCES Playlist (id),
    FOREIGN KEY (backingtrack_id) REFERENCES BackingTrack (id),
    UNIQUE (playlist_id, posicao)
);

-- Relacionamento Lanca (Artista x Album)
CREATE TABLE ArtistaAlbum (
    artista_id    INT NOT NULL,
    album_id      INT NOT NULL,
    papel_artista VARCHAR(20) DEFAULT 'principal'
        CHECK (papel_artista IN ('principal', 'participacao')),
    PRIMARY KEY (artista_id, album_id),
    FOREIGN KEY (artista_id) REFERENCES Artista (id),
    FOREIGN KEY (album_id)   REFERENCES Album (id)
);

-- Relacionamento Interpretada_por (Artista x Musica)
CREATE TABLE ArtistaMusica (
    artista_id    INT NOT NULL,
    musica_id     INT NOT NULL,
    papel_artista VARCHAR(20) DEFAULT 'interprete'
        CHECK (papel_artista IN ('interprete', 'compositor', 'participacao')),
    PRIMARY KEY (artista_id, musica_id),
    FOREIGN KEY (artista_id) REFERENCES Artista (id),
    FOREIGN KEY (musica_id)  REFERENCES Musica (id)
);
