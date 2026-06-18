const express = require('express');
const router = express.Router();
const db = require('../config/db');

router.get('/api/tours', (req, res) => {
  const sql = "SELECT tour_id AS id, tour_title AS name, region AS country, price_per_person AS price, description FROM Tours WHERE is_active = 1";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

router.get('/api/tours/:id', (req, res) => {
  const sql = "SELECT tour_id AS id, tour_title AS name, region AS country, price_per_person AS price, description, start_date, end_date FROM Tours WHERE tour_id = ? AND is_active = 1";
  db.query(sql, [req.params.id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ error: 'Тур не знайдено' });
    res.json(results[0]);
  });
});

router.post('/api/bookings', (req, res) => {
  const { tourId, firstName, lastName, email, phone, persons } = req.body;
  const findUser = "SELECT user_id FROM Users WHERE email = ?";
  db.query(findUser, [email], (err, users) => {
    if (err) return res.status(500).json({ error: err.message });
    const proceed = (userId) => {
      db.query("SELECT price_per_person FROM Tours WHERE tour_id = ?", [tourId], (err, tours) => {
        if (err || tours.length === 0) return res.status(404).json({ error: 'Тур не знайдено' });
        const total = (tours[0].price_per_person * persons).toFixed(2);
        const sql = "INSERT INTO Bookings (user_id, tour_id, total_amount) VALUES (?, ?, ?)";
        db.query(sql, [userId, tourId, total], (err, result) => {
          if (err) return res.status(500).json({ error: err.message });
          res.json({ success: true, bookingId: result.insertId, total });
        });
      });
    };
    if (users.length > 0) {
      proceed(users[0].user_id);
    } else {
      const insert = "INSERT INTO Users (first_name, last_name, email, phone_number, password) VALUES (?, ?, ?, ?, 'guest')";
      db.query(insert, [firstName, lastName, email, phone || null], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        proceed(result.insertId);
      });
    }
  });
});

const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    cb(null, path.join(__dirname, '../public/uploads'));
  },
  filename: function(req, file, cb) {
    const ext = path.extname(file.originalname);
    cb(null, 'tour-' + Date.now() + ext);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: function(req, file, cb) {
    if (file.mimetype.startsWith('image/')) cb(null, true);
    else cb(new Error('Тільки зображення'));
  }
});

// Завантаження фото туру
router.post('/api/admin/tours/:id/photo', isAdmin, upload.single('photo'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Файл не завантажено' });
  const imageUrl = '/uploads/' + req.file.filename;
  db.query("UPDATE Tours SET image_url = ? WHERE tour_id = ?", [imageUrl, req.params.id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true, image_url: imageUrl });
  });
});

// Реєстрація
router.post('/api/register', async (req, res) => {
  const { firstName, lastName, email, password, phone } = req.body;
  if (!firstName || !lastName || !email || !password)
    return res.status(400).json({ error: 'Заповніть всі поля' });

  const hash = await bcrypt.hash(password, 10);
  const sql = "INSERT INTO Users (first_name, last_name, email, password, phone_number) VALUES (?, ?, ?, ?, ?)";
  db.query(sql, [firstName, lastName, email, hash, phone || null], (err, result) => {
    if (err) return res.status(500).json({ error: 'Email вже використовується' });
    req.session.userId = result.insertId;
    req.session.role = 'Client';
    req.session.name = firstName; // ← ЦЕЙ РЯДОК БУВ ВІДСУТНІЙ
    res.json({ success: true });
  });
});

// Вхід
router.post('/api/login', (req, res) => {
  const { email, password } = req.body;
  db.query("SELECT * FROM Users WHERE email = ?", [email], async (err, users) => {
    if (err || users.length === 0)
      return res.status(401).json({ error: 'Невірний email або пароль' });

    const user = users[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ error: 'Невірний email або пароль' });

    req.session.userId = user.user_id;
    req.session.role = user.role;
    req.session.name = user.first_name;
    res.json({ success: true, name: user.first_name, role: user.role });
  });
});

// Вихід
router.post('/api/logout', (req, res) => {
  req.session.destroy();
  res.json({ success: true });
});

// Перевірка сесії
router.get('/api/me', (req, res) => {
  if (!req.session.userId)
    return res.status(401).json({ error: 'Не авторизований' });
  res.json({ userId: req.session.userId, name: req.session.name, role: req.session.role });
});

// Мої бронювання
router.get('/api/my-bookings', (req, res) => {
  if (!req.session.userId)
    return res.status(401).json({ error: 'Не авторизований' });

  const sql = `
    SELECT b.booking_id, b.booking_date, b.status, b.total_amount,
           t.tour_title AS tour_name
    FROM Bookings b
    JOIN Tours t ON b.tour_id = t.tour_id
    WHERE b.user_id = ?
    ORDER BY b.booking_date DESC
  `;
  db.query(sql, [req.session.userId], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Middleware для перевірки адміна
function isAdmin(req, res, next) {
  if (req.session.role !== 'Admin') return res.status(403).json({ error: 'Доступ заборонено' });
  next();
}

// Всі бронювання (адмін)
router.get('/api/admin/bookings', isAdmin, (req, res) => {
  const sql = `
    SELECT b.booking_id, b.booking_date, b.status, b.total_amount,
           CONCAT(u.first_name, ' ', u.last_name) AS client_name,
           t.tour_title AS tour_name
    FROM Bookings b
    JOIN Users u ON b.user_id = u.user_id
    JOIN Tours t ON b.tour_id = t.tour_id
    ORDER BY b.booking_date DESC
  `;
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Зміна статусу бронювання
router.patch('/api/admin/bookings/:id', isAdmin, (req, res) => {
  db.query("UPDATE Bookings SET status = ? WHERE booking_id = ?",
    [req.body.status, req.params.id], (err) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true });
    });
});

// Всі користувачі (адмін)
router.get('/api/admin/users', isAdmin, (req, res) => {
  db.query("SELECT user_id, first_name, last_name, email, phone_number, role, created_at FROM Users", (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});
// Всі тури для адміна (включаючи неактивні)
router.get('/api/admin/tours', isAdmin, (req, res) => {
  db.query("SELECT * FROM Tours ORDER BY tour_id", (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Додати тур
router.post('/api/admin/tours', isAdmin, (req, res) => {
  const { tour_title, region, description, price_per_person, start_date, end_date, is_active } = req.body;
  const sql = "INSERT INTO Tours (tour_title, region, description, price_per_person, start_date, end_date, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";
  db.query(sql, [tour_title, region, description, price_per_person, start_date || null, end_date || null, is_active ? 1 : 0], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true, tour_id: result.insertId });
  });
});

// Редагувати тур
router.put('/api/admin/tours/:id', isAdmin, (req, res) => {
  const { tour_title, region, description, price_per_person, start_date, end_date, is_active } = req.body;
  const sql = "UPDATE Tours SET tour_title=?, region=?, description=?, price_per_person=?, start_date=?, end_date=?, is_active=? WHERE tour_id=?";
  db.query(sql, [tour_title, region, description, price_per_person, start_date || null, end_date || null, is_active ? 1 : 0, req.params.id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true });
  });
});

// Видалити тур
router.delete('/api/admin/tours/:id', isAdmin, (req, res) => {
  db.query("DELETE FROM Tours WHERE tour_id = ?", [req.params.id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true });
  });
});
// Отримати відгуки для туру
router.get('/api/tours/:id/reviews', (req, res) => {
  const sql = `
    SELECT r.review_id, r.rating, r.comment, r.created_at,
           u.first_name, u.last_name
    FROM Reviews r
    JOIN Users u ON r.user_id = u.user_id
    WHERE r.tour_id = ?
    ORDER BY r.created_at DESC
  `;
  db.query(sql, [req.params.id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Додати відгук
router.post('/api/tours/:id/reviews', (req, res) => {
  if (!req.session.userId)
    return res.status(401).json({ error: 'Потрібно увійти' });

  const { rating, comment } = req.body;
  if (!rating || rating < 1 || rating > 5)
    return res.status(400).json({ error: 'Оцінка від 1 до 5' });

  const sql = "INSERT INTO Reviews (user_id, tour_id, rating, comment) VALUES (?, ?, ?, ?)";
  db.query(sql, [req.session.userId, req.params.id, rating, comment || null], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true, review_id: result.insertId });
  });
});
router.post('/api/leads', (req, res) => {
  const { name, phone, email, message } = req.body;
  if (!name || !phone) return res.status(400).json({ error: "Вкажіть ім'я та телефон" });
  db.query("INSERT INTO Leads (name, phone, email, message) VALUES (?, ?, ?, ?)",
    [name, phone, email || null, message || null], (err) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true });
    });
});

router.get('/api/admin/leads', isAdmin, (req, res) => {
  db.query("SELECT * FROM Leads ORDER BY created_at DESC", (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

router.patch('/api/admin/leads/:id', isAdmin, (req, res) => {
  db.query("UPDATE Leads SET status = ? WHERE lead_id = ?",
    [req.body.status, req.params.id], (err) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true });
    });
});
module.exports = router;