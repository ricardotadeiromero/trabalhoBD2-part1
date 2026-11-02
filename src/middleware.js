function loadLocals(req, res, next) {
  res.locals.currentUser = req.session.user || null;
  res.locals.flash = req.session.flash || null;
  res.locals.currentPath = req.path;
  delete req.session.flash;
  next();
}

function requireLogin(req, res, next) {
  if (!req.session.user) {
    req.session.flash = { type: 'info', text: 'Entre na sua conta para continuar.' };
    req.session.returnTo = req.originalUrl;
    return res.redirect('/login');
  }
  next();
}

function setFlash(req, type, text) {
  req.session.flash = { type, text };
}

module.exports = { loadLocals, requireLogin, setFlash };
