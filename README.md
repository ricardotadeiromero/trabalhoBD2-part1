# Ensaio

Trabalho de Banco de Dados II (Parte 01), Grupo H: Alan Souza, Pedro Rossi e Ricardo Romero.

O Ensaio é um marketplace de **backing tracks**: músicos publicam versões de músicas com os
instrumentos separados (os *stems*) e outros músicos compram para estudar ou tocar junto.
A aplicação usa o banco que a gente modelou no BD I (tema "Spotify"), sem refazer as tabelas.

## O que dá pra fazer

| Tela | O que faz | Tabelas envolvidas |
|------|-----------|--------------------|
| Explorar | busca por texto (ignora acento), filtro por instrumento dos stems, artista original, preço, nível de quem criou, ordenação, esconder os que já tenho | `v_catalog` (BackingTrack, Musica, Album, ArtistaMusica, Artista, Usuario, Track, CompraBackingTrack) |
| Backing track | stems, créditos, "quem comprou este também comprou", outras versões da mesma música, compra e adicionar à playlist | Track, ArtistaMusica, CompraBackingTrack (self-join), BackingTrackPlaylist |
| Publicar | cadastra um backing track com os stems numa transação | BackingTrack, Track |
| Biblioteca | compras com status, confirmação de boleto, o que publiquei | CompraBackingTrack, `v_catalog` |
| Playlists | criar, adicionar, reordenar, remover, excluir, salvar playlists de outros | Playlist, BackingTrackPlaylist, PlaylistsSalvas |
| Músicos | busca por nome/nível/instrumento, sugestões de quem seguir (amigos de amigos), seguir | Seguidores (self-join), `v_user_summary` |
| Perfil | publicados, playlists, seguidores, artistas que a pessoa mais toca | várias |
| Artistas | discografia, músicas com quantidade de backing tracks e menor preço | Artista, ArtistaAlbum, ArtistaMusica, Album, Musica, BackingTrack |
| Painel do criador | receita, ticket médio, vendas por mês, por forma de pagamento, por nível do comprador | CompraBackingTrack, BackingTrack, Usuario |

## Banco de dados

Os scripts estão em `db/` e rodam nesta ordem:

1. `01_create.sql`: tabelas do BD I (sem alteração)
2. `02_populate.sql`: população do BD I
3. `03_buscas.sql`: as buscas do BD I (só pra referência, o setup não roda)
4. `04_more_data.sql`: mais dados, porque com o mínimo do BD I as telas ficavam vazias
5. `05_adjustments.sql`: o que mudou para a aplicação:
   - senha passou a ser guardada com bcrypt (`pgcrypto`), e a coluna cresceu para 72 caracteres
   - índices nas chaves estrangeiras que ainda não tinham índice
   - views `v_catalog` e `v_user_summary`
   - trigger que impede alguém de comprar o próprio backing track
   - `UNIQUE (playlist_id, posicao)` virou `DEFERRABLE` pra conseguir trocar duas posições num UPDATE só
   - extensão `unaccent` para a busca

Com os dados novos, as buscas do `03_buscas.sql` dão resultados diferentes dos que estão no relatório do BD I.

## Rodando localmente

Precisa de Node 20 ou mais novo e de um PostgreSQL (local ou no Neon) com as extensões
`pgcrypto` e `unaccent` disponíveis. O setup cria as duas.

```bash
npm install
cp .env.example .env      # e coloque a connection string do banco em DATABASE_URL
npm run db:setup          # cria e popula o banco
npm run dev               # http://localhost:3000
```

`npm run db:reset` apaga tudo do schema `public` e roda os scripts de novo.

### Usuários de teste

Todos vêm do seed (`02_populate.sql` e `04_more_data.sql`). Alguns que mostram bem as telas:

| E-mail | Senha | Por quê |
|--------|-------|---------|
| mateus.pinto@email.com | guitarra10 | publicou e vendeu bastante, bom pro painel |
| helena.costa@email.com | focototal | comprou vários, segue gente, tem a playlist Foco Total |
| alice.prado@email.com | segredo123 | usuária iniciante |

## Estrutura

```
db/            scripts SQL e o setup.js que roda eles
src/
  server.js    express, sessão, rotas
  db.js        pool do pg e helper de transação
  routes/      uma rota por área (explore, tracks, playlists...)
  views/       templates EJS
public/        css, js do front e ícone
```

Tecnologias: Node.js, Express 5, EJS, node-postgres, bcryptjs, Chart.js (no painel).
