const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../db');
const { setFlash } = require('../middleware');

const router = express.Router();

router.get('/login', (req, res) => {
  if (req.session.user) return res.redirect('/');
  res.render('login', { title: 'Entrar', email: '', error: null });
});

router.post('/login', async (req, res) => {
  const email = (req.body.email || '').trim().toLowerCase();
  const password = req.body.senha || '';

  const { rows } = await db.query('SELECT id, nome, senha FROM Usuario WHERE email = $1', [email]);
  const found = rows[0];

  if (!found || !(await bcrypt.compare(password, found.senha))) {
    return res.status(401).render('login', {
      title: 'Entrar',
      email,
      error: 'E-mail ou senha incorretos.',
    });
  }

  req.session.user = { id: found.id, nome: found.nome };
  const target = req.session.returnTo || '/';
  delete req.session.returnTo;
  res.redirect(target);
});

router.get('/register', (req, res) => {
  if (req.session.user) return res.redirect('/');
  res.render('register', { title: 'Criar conta', form: {}, error: null });
});

router.post('/register', async (req, res) => {
  const form = {
    nome: (req.body.nome || '').trim(),
    email: (req.body.email || '').trim().toLowerCase(),
    cpf: (req.body.cpf || '').replace(/\D/g, ''),
    data_nascimento: req.body.data_nascimento || null,
    nivel_experiencia: req.body.nivel_experiencia || 'iniciante',
  };
  const password = req.body.senha || '';

  const renderError = (error) =>
    res.status(400).render('register', { title: 'Criar conta', form, error });

  if (!form.nome || !form.email) return renderError('Preencha nome e e-mail.');
  if (form.cpf.length !== 11) return renderError('O CPF precisa ter 11 dígitos.');
  if (password.length < 6) return renderError('A senha precisa ter pelo menos 6 caracteres.');
  // o front já confere, mas sem JS o formulário passa direto
  if (password !== req.body.senha_confirmacao) return renderError('As senhas não conferem.');

  const hash = await bcrypt.hash(password, 10);

  try {
    const { rows } = await db.query(
      `INSERT INTO Usuario (cpf, email, nome, senha, data_nascimento, nivel_experiencia)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, nome`,
      [form.cpf, form.email, form.nome, hash, form.data_nascimento, form.nivel_experiencia]
    );
    req.session.user = { id: rows[0].id, nome: rows[0].nome };
    setFlash(req, 'success', `Bem-vindo(a), ${rows[0].nome.split(' ')[0]}!`);
    res.redirect('/');
  } catch (err) {
    // 23505 = unique_violation (email ou cpf repetido)
    if (err.code === '23505') {
      const field = err.constraint === 'usuario_cpf_key' ? 'CPF' : 'e-mail';
      return renderError(`Já existe uma conta com esse ${field}.`);
    }
    if (err.code === '23514') return renderError('Algum campo está com valor inválido.');
    throw err;
  }
});

router.post('/logout', (req, res) => {
  req.session = null;
  res.redirect('/');
});

module.exports = router;
