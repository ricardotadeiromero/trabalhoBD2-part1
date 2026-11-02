const path = require('path');
const express = require('express');
const cookieSession = require('cookie-session');

const helpers = require('./helpers');
const { loadLocals } = require('./middleware');

const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
// Render fica atras de proxy, sem isso o cookie secure nao funciona
app.set('trust proxy', 1);

Object.assign(app.locals, helpers);

app.use(express.static(path.join(__dirname, '..', 'public')));
app.use(express.urlencoded({ extended: false }));
app.use(
  cookieSession({
    name: 'ensaio',
    secret: process.env.SESSION_SECRET || 'dev-secret',
    maxAge: 7 * 24 * 60 * 60 * 1000,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
  })
);
app.use(loadLocals);

app.use(require('./routes/home'));
app.use(require('./routes/auth'));
app.use(require('./routes/explore'));
app.use(require('./routes/tracks'));
app.use(require('./routes/library'));
app.use(require('./routes/playlists'));
app.use(require('./routes/people'));
app.use(require('./routes/artists'));
app.use(require('./routes/dashboard'));

app.use((req, res) => {
  res.status(404).render('error', { title: 'Página não encontrada', message: 'Esse endereço não existe.' });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).render('error', {
    title: 'Algo deu errado',
    message: 'Tivemos um problema ao falar com o banco. Tente de novo em instantes.',
  });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`rodando em http://localhost:${port}`);
});
