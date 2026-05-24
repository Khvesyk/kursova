const mysql = require('mysql2');

const db = mysql.createConnection({
    host: '10.211.55.9',
    user: 'dbuser',
    password: 'Chwesyk1979!', 
    database: 'travel_agency_db'
});

// Спроба підключення
db.connect((err) => {
    if (err) {
        console.error('❌ ПОМИЛКА БАЗИ ДАНИХ:', err.message);
    } else {
        console.log('✅ УСПІШНЕ ПІДКЛЮЧЕННЯ ДО БД!');
    }
});

module.exports = db;