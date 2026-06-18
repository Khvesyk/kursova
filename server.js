const express = require('express');
const session = require('express-session');
const app = express();
const apiRoutes = require('./routes/routes');

app.use(express.json());
const path = require('path');
app.use('/uploads', require('express').static(path.join(__dirname, 'public/uploads')));
app.use(session({
  secret: 'goway_secret_key',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 1000 * 60 * 60 * 24 } // 24 години
}));

app.use(apiRoutes);
app.use(express.static('public'));

app.listen(3000, () => {
  console.log('🚀 НОВИЙ СЕРВЕР ЗАПУЩЕНО');
  console.log('Перевір це посилання: http://localhost:3000/api/tours');
});
