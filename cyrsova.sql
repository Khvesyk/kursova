CREATE DATABASE IF NOT EXISTS travel_agency_db;
USE travel_agency_db;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM Payments WHERE user_id IN (SELECT user_id FROM Users WHERE email LIKE '%@example.com');
DELETE FROM Reviews WHERE user_id IN (SELECT user_id FROM Users WHERE email LIKE '%@example.com');
DELETE FROM Bookings WHERE user_id IN (SELECT user_id FROM Users WHERE email LIKE '%@example.com');
DELETE FROM Users WHERE email LIKE '%@example.com';

SET SQL_SAFE_UPDATES = 1;

CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role ENUM('Admin', 'Client') DEFAULT 'Client',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Leads (
    lead_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('New', 'InProgress', 'Done') DEFAULT 'New',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Hotels (
    hotel_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    stars INT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS Tours (
    tour_id INT AUTO_INCREMENT PRIMARY KEY,
    tour_title VARCHAR(255) NOT NULL,
    region VARCHAR(100) NOT NULL,
    description TEXT,
    price_per_person DECIMAL(10, 2) NOT NULL,
    hotel_id INT,
    services_included TEXT,
    image_url VARCHAR(500) DEFAULT NULL,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    tour_id INT,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Confirmed', 'Cancelled') DEFAULT 'Pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (tour_id) REFERENCES Tours(tour_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Card', 'Cash', 'Bank Transfer', 'ApplePay/GooglePay') DEFAULT 'Card',
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100) UNIQUE,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tour_id INT NULL,
    hotel_id INT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (tour_id) REFERENCES Tours(tour_id) ON DELETE CASCADE,
    FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id) ON DELETE CASCADE
);

-- ================================================
-- КОРИСТУВАЧІ (вставляються тільки якщо таблиця порожня)
-- ================================================
INSERT INTO Users (first_name, last_name, email, password, phone_number, role)
SELECT * FROM (SELECT 'Admin' AS first_name, 'GoWay' AS last_name, 'admin@goway.ua' AS email, '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW' AS password, '+380671234567' AS phone_number, 'Admin' AS role) t
WHERE NOT EXISTS (SELECT 1 FROM Users WHERE email = 'admin@goway.ua');

INSERT INTO Users (first_name, last_name, email, password, phone_number, role) VALUES
('Назар', 'Хвесик', 'khvesyknazar@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380671112233', 'Admin'),
('Олексій', 'Коваленко', 'oleksiy.kovalenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380671234568', 'Client'),
('Марія', 'Шевченко', 'maria.shevchenko@ukr.net', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380502345678', 'Client'),
('Іван', 'Петренко', 'ivan.petrenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380933456789', 'Client'),
('Оксана', 'Бондаренко', 'oksana.bondarenko@meta.ua', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380674567890', 'Client'),
('Дмитро', 'Мельник', 'dmytro.melnyk@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380505678901', 'Client'),
('Юлія', 'Ткаченко', 'yulia.tkachenko@ukr.net', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380936789012', 'Client'),
('Андрій', 'Кравченко', 'andriy.kravchenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380677890123', 'Client'),
('Наталія', 'Іваненко', 'natalia.ivanenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380508901234', 'Client'),
('Сергій', 'Савченко', 'serhiy.savchenko@meta.ua', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380939012345', 'Client'),
('Вікторія', 'Попович', 'viktoria.popovych@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380670123456', 'Client'),
('Богдан', 'Лисенко', 'bohdan.lysenko@ukr.net', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380501234560', 'Client'),
('Катерина', 'Марченко', 'kateryna.marchenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380932345671', 'Client'),
('Михайло', 'Гриценко', 'mykhailo.hrytsenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380673456782', 'Client'),
('Людмила', 'Романенко', 'lyudmyla.romanenko@meta.ua', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380504567893', 'Client'),
('Тарас', 'Сидоренко', 'taras.sydorenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380935678904', 'Client'),
('Ірина', 'Павленко', 'iryna.pavlenko@ukr.net', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380676789015', 'Client'),
('Олег', 'Власенко', 'oleh.vlasenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380507890126', 'Client'),
('Тетяна', 'Кириленко', 'tetyana.kyrylenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380938901237', 'Client'),
('Василь', 'Демченко', 'vasyl.demchenko@meta.ua', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380679012348', 'Client'),
('Олена', 'Зінченко', 'olena.zinchenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380500123459', 'Client'),
('Роман', 'Харченко', 'roman.kharchenko@ukr.net', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380931234560', 'Client'),
('Аліна', 'Федоренко', 'alina.fedorenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380672345671', 'Client'),
('Микола', 'Морозенко', 'mykola.morozenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380503456782', 'Client'),
('Софія', 'Назаренко', 'sofia.nazarenko@meta.ua', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380934567893', 'Client'),
('Артем', 'Білоус', 'artem.bilous@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380675678904', 'Client'),
('Діана', 'Гончаренко', 'diana.honcharenko@ukr.net', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380506789015', 'Client'),
('Євген', 'Левченко', 'yevhen.levchenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380937890126', 'Client'),
('Поліна', 'Захаренко', 'polina.zakharenko@gmail.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380678901237', 'Client'),
('Владислав', 'Остапенко', 'vladyslav.ostapenko@meta.ua', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uYutlQeJW', '+380509012348', 'Client')
ON DUPLICATE KEY UPDATE user_id = user_id;

-- ================================================
-- ТУРИ (вставляються тільки якщо таблиця порожня)
-- ================================================
INSERT INTO Tours (tour_title, region, description, price_per_person, start_date, end_date, is_active)
SELECT * FROM (
SELECT 'Відпустка в Буковелі' t, 'Україна' r, 'Гірський курорт Буковель — найкраще місце для активного відпочинку. Катання на лижах, сноубординг, прогулянки Карпатами. Готель 4*, сніданки, ски-пас на 5 днів.' d, 280.00 p, '2026-06-15' s, '2026-06-20' e, 1 a
UNION ALL SELECT 'Тур до Кракова','Польща','Краків — одне з найкрасивіших міст Європи. Замок Вавель, Старе місто, соляні шахти Велічка. Авіапереліт, готель 3*, сніданки та екскурсії.',320.00,'2026-06-20','2026-06-24',1
UNION ALL SELECT 'Вікенд у Варшаві','Польща','Три дні у столиці Польщі. Королівський замок, Старе місто, шопінг. Переліт, готель 3* в центрі, сніданки включено.',195.00,'2026-06-27','2026-06-29',1
UNION ALL SELECT 'Пляжний відпочинок в Анталії','Туреччина','Готель 5* All Inclusive на березі Середземного моря. Аквапарк, анімація, пісчані пляжі. Авіапереліт та трансфер включено.',689.00,'2026-06-10','2026-06-17',1
UNION ALL SELECT 'Єгипет. Шарм-ель-Шейх','Єгипет','Червоне море, дайвінг, коралові рифи. Готель 4* All Inclusive, екскурсія до пірамід. Авіапереліт включено.',749.00,'2026-06-05','2026-06-12',1
UNION ALL SELECT 'Грецькі острови — Крит','Греція','Палац Кносс, Самарська ущелина, білосніжні пляжі. Готель 4* з видом на море, прямий авіапереліт включено.',820.00,'2026-07-01','2026-07-08',1
UNION ALL SELECT 'Барселона та Коста Брава','Іспанія','Архітектура Гауді, пляжі, іспанська кухня. Готель 4* в центрі Барселони, авіапереліт та екскурсії включено.',990.00,'2026-07-10','2026-07-17',1
UNION ALL SELECT 'Відпочинок на Мальдівах','Мальдіви','Бірюзові лагуни, бунгало над водою. Готель 5* All Inclusive, дайвінг. Авіапереліт включено.',2100.00,'2026-07-15','2026-07-22',1
UNION ALL SELECT 'Прага — золоте місто','Чехія','Старомістська площа, Карлів міст, Празький замок. Готель 3* в центрі, сніданки та екскурсії включено.',380.00,'2026-06-18','2026-06-22',1
UNION ALL SELECT 'Відень та Зальцбург','Австрія','Опера, палац Шенбрунн, батьківщина Моцарта. Готель 4*, авіапереліт та екскурсії включено.',750.00,'2026-07-05','2026-07-10',1
UNION ALL SELECT 'Рим — вічне місто','Італія','Колізей, Ватикан, фонтан Треві. Готель 3* у центрі, сніданки та екскурсії з гідом включено.',870.00,'2026-06-25','2026-07-01',1
UNION ALL SELECT 'Дубай — місто майбутнього','ОАЕ','Бурдж Халіфа, сафарі в пустелі, золоті ринки. Готель 5*, авіапереліт та трансфер включено.',1350.00,'2026-07-20','2026-07-27',1
UNION ALL SELECT 'Чорногорія — перлина Адріатики','Чорногорія','Бока-Которська затока, середньовічні міста, чисте море. Готель 4* з видом на затоку, сніданки включено.',520.00,'2026-06-28','2026-07-05',1
UNION ALL SELECT 'Будапешт — місто термальних купалень','Угорщина','Термальні купальні Сечені, рибальський бастіон, угорська кухня. Готель 4* у центрі, сніданки включено.',410.00,'2026-06-22','2026-06-26',1
UNION ALL SELECT 'Таїланд — Бангкок та Пхукет','Таїланд','10 днів азійської екзотики: храми Бангкоку та пляжі Пхукету. Готель 4* All Inclusive, авіапереліт включено.',1150.00,'2026-07-25','2026-08-03',1
UNION ALL SELECT 'Амстердам — місто каналів','Нідерланди','Канали, тюльпани, музей Ван Гога. Готель 3* в центрі, сніданки та екскурсії включено.',560.00,'2026-06-20','2026-06-24',1
UNION ALL SELECT 'Париж — місто кохання','Франція','Ейфелева вежа, Лувр, Монмартр. Готель 3* біля центру, авіапереліт та екскурсії включено.',950.00,'2026-07-12','2026-07-18',1
UNION ALL SELECT 'Лондон — столиця Британії','Великобританія','Букінгемський палац, Тауер, Біг Бен. Готель 3* в центрі, авіапереліт включено.',1100.00,'2026-07-05','2026-07-10',1
UNION ALL SELECT 'Відпочинок на Балі','Індонезія','Тропічні ліси, рисові тераси, храми та пляжі Куті. Готель 4* з басейном, авіапереліт включено.',1250.00,'2026-07-20','2026-07-30',1
UNION ALL SELECT 'Санторіні — острів мрії','Греція','Білі будиночки, синє море, захід сонця в Ої. Готель 4* з видом на кальдеру, авіапереліт включено.',1450.00,'2026-07-08','2026-07-14',1
UNION ALL SELECT 'Португалія — Лісабон та Сінтра','Португалія','Середньовічні замки Сінтри, трамваї Лісабона. Готель 4*, авіапереліт та екскурсії включено.',780.00,'2026-06-25','2026-07-01',1
UNION ALL SELECT 'Марокко — Марракеш','Марокко','Медіна, базари, пустеля Сахара. Готель Riad 4*, авіапереліт та екскурсії включено.',690.00,'2026-06-15','2026-06-21',1
UNION ALL SELECT 'Японія — Токіо та Кіото','Японія','Храм Сенсодзі, гора Фудзі, бамбуковий ліс. Готель 3*, авіапереліт та JR Pass включено.',1980.00,'2026-07-25','2026-08-04',1
UNION ALL SELECT 'Відпочинок у Хорватії','Хорватія','Дубровник, острів Хвар, Плітвицькі озера. Готель 4* біля моря, сніданки включено.',720.00,'2026-07-01','2026-07-08',1
UNION ALL SELECT 'Фінляндія — Гельсінкі та Лапландія','Фінляндія','Столиця дизайну та казкова Лапландія. Готель 4*, авіапереліт включено.',1150.00,'2026-08-10','2026-08-16',1
UNION ALL SELECT 'Грузія — Тбілісі та Батумі','Грузія','Стара Тбілісі, монастир Вардзія, пляжі Батумі. Готель 4*, авіапереліт включено.',450.00,'2026-06-18','2026-06-24',1
UNION ALL SELECT 'Швейцарія — Альпи та Женева','Швейцарія','Альпійські луки, шоколад, Женевське озеро. Готель 4*, авіапереліт включено.',1650.00,'2026-07-15','2026-07-21',1
UNION ALL SELECT 'Мексика — Канкун та Чічен-Іца','Мексика','Карибське море, піраміди майя, сеноти. Готель 5* All Inclusive, авіапереліт включено.',1750.00,'2026-08-01','2026-08-10',1
UNION ALL SELECT 'Норвегія — фіорди та Берген','Норвегія','Гейрангерфіорд, Флом, рибний ринок Бергена. Готель 4*, авіапереліт включено.',1380.00,'2026-07-20','2026-07-26',1
UNION ALL SELECT 'Відпочинок на Кіпрі','Кіпр','Середземне море, Пафос, скеля Афродіти. Готель 4* All Inclusive, авіапереліт включено.',680.00,'2026-06-22','2026-06-29',1
) AS nt
WHERE NOT EXISTS (SELECT 1 FROM Tours LIMIT 1);

-- ================================================
-- БРОНЮВАННЯ (вставляються тільки якщо таблиця порожня)
-- ================================================
INSERT INTO Bookings (user_id, tour_id, status, total_amount, booking_date)
SELECT * FROM (
SELECT 3,1,'Confirmed',280.00,'2026-05-01 10:23:00' UNION ALL
SELECT 3,4,'Confirmed',689.00,'2026-05-02 11:15:00' UNION ALL
SELECT 4,2,'Confirmed',320.00,'2026-05-02 14:30:00' UNION ALL
SELECT 4,6,'Pending',820.00,'2026-05-10 09:45:00' UNION ALL
SELECT 5,3,'Confirmed',195.00,'2026-05-03 16:20:00' UNION ALL
SELECT 5,8,'Cancelled',2100.00,'2026-05-04 12:10:00' UNION ALL
SELECT 6,5,'Confirmed',749.00,'2026-05-04 15:45:00' UNION ALL
SELECT 6,12,'Confirmed',1350.00,'2026-05-11 10:30:00' UNION ALL
SELECT 7,7,'Pending',990.00,'2026-05-05 09:00:00' UNION ALL
SELECT 7,16,'Confirmed',560.00,'2026-05-12 14:20:00' UNION ALL
SELECT 8,9,'Confirmed',380.00,'2026-05-05 17:30:00' UNION ALL
SELECT 8,20,'Confirmed',1450.00,'2026-05-13 11:45:00' UNION ALL
SELECT 9,10,'Confirmed',750.00,'2026-05-06 11:00:00' UNION ALL
SELECT 9,23,'Pending',1980.00,'2026-05-14 16:00:00' UNION ALL
SELECT 10,11,'Cancelled',870.00,'2026-05-06 14:20:00' UNION ALL
SELECT 10,1,'Confirmed',280.00,'2026-05-15 09:30:00' UNION ALL
SELECT 11,13,'Confirmed',520.00,'2026-05-07 10:15:00' UNION ALL
SELECT 11,4,'Pending',689.00,'2026-05-15 13:45:00' UNION ALL
SELECT 12,14,'Confirmed',410.00,'2026-05-07 15:40:00' UNION ALL
SELECT 12,17,'Confirmed',950.00,'2026-05-16 10:00:00' UNION ALL
SELECT 13,15,'Pending',1150.00,'2026-05-08 09:30:00' UNION ALL
SELECT 13,25,'Confirmed',1150.00,'2026-05-16 14:30:00' UNION ALL
SELECT 14,1,'Confirmed',560.00,'2026-05-08 12:00:00' UNION ALL
SELECT 14,6,'Confirmed',820.00,'2026-05-17 11:00:00' UNION ALL
SELECT 15,2,'Confirmed',320.00,'2026-05-09 10:45:00' UNION ALL
SELECT 15,8,'Pending',2100.00,'2026-05-17 15:20:00' UNION ALL
SELECT 16,3,'Confirmed',195.00,'2026-05-09 14:00:00' UNION ALL
SELECT 16,12,'Confirmed',1350.00,'2026-05-18 09:45:00' UNION ALL
SELECT 17,5,'Cancelled',749.00,'2026-05-09 16:30:00' UNION ALL
SELECT 17,19,'Confirmed',1250.00,'2026-05-18 13:00:00' UNION ALL
SELECT 18,7,'Confirmed',990.00,'2026-05-10 11:15:00' UNION ALL
SELECT 18,22,'Confirmed',690.00,'2026-05-19 10:15:00' UNION ALL
SELECT 19,9,'Confirmed',380.00,'2026-05-10 15:00:00' UNION ALL
SELECT 19,27,'Confirmed',1650.00,'2026-05-19 14:45:00' UNION ALL
SELECT 20,11,'Pending',870.00,'2026-05-11 09:20:00' UNION ALL
SELECT 20,29,'Confirmed',1380.00,'2026-05-20 11:30:00' UNION ALL
SELECT 21,13,'Confirmed',520.00,'2026-05-11 13:45:00' UNION ALL
SELECT 21,4,'Confirmed',689.00,'2026-05-20 15:00:00' UNION ALL
SELECT 22,14,'Confirmed',410.00,'2026-05-12 10:30:00' UNION ALL
SELECT 22,7,'Pending',990.00,'2026-05-21 09:00:00' UNION ALL
SELECT 23,15,'Confirmed',1150.00,'2026-05-12 16:00:00' UNION ALL
SELECT 23,10,'Confirmed',750.00,'2026-05-21 13:30:00' UNION ALL
SELECT 24,16,'Cancelled',560.00,'2026-05-13 09:45:00' UNION ALL
SELECT 24,3,'Confirmed',195.00,'2026-05-22 10:45:00' UNION ALL
SELECT 25,17,'Confirmed',950.00,'2026-05-13 14:20:00' UNION ALL
SELECT 25,18,'Confirmed',1100.00,'2026-05-22 15:15:00' UNION ALL
SELECT 26,1,'Confirmed',280.00,'2026-05-14 11:00:00' UNION ALL
SELECT 26,21,'Confirmed',780.00,'2026-05-23 09:30:00' UNION ALL
SELECT 27,2,'Pending',320.00,'2026-05-14 15:30:00' UNION ALL
SELECT 27,28,'Confirmed',1750.00,'2026-05-23 14:00:00' UNION ALL
SELECT 28,5,'Confirmed',749.00,'2026-05-15 10:00:00' UNION ALL
SELECT 28,30,'Confirmed',680.00,'2026-05-23 16:30:00' UNION ALL
SELECT 29,6,'Confirmed',820.00,'2026-05-15 14:45:00' UNION ALL
SELECT 29,11,'Pending',870.00,'2026-05-24 09:15:00' UNION ALL
SELECT 30,8,'Confirmed',2100.00,'2026-05-16 10:30:00' UNION ALL
SELECT 30,24,'Confirmed',720.00,'2026-05-24 13:45:00' UNION ALL
SELECT 3,26,'Confirmed',450.00,'2026-05-17 11:00:00' UNION ALL
SELECT 4,27,'Confirmed',1650.00,'2026-05-17 15:20:00' UNION ALL
SELECT 5,28,'Pending',1750.00,'2026-05-18 09:45:00' UNION ALL
SELECT 6,29,'Confirmed',1380.00,'2026-05-18 14:00:00' UNION ALL
SELECT 7,30,'Confirmed',680.00,'2026-05-19 10:30:00' UNION ALL
SELECT 8,1,'Confirmed',280.00,'2026-05-19 15:00:00'
) AS nb
WHERE NOT EXISTS (SELECT 1 FROM Bookings LIMIT 1);

-- ================================================
-- ЗАЯВКИ (вставляються тільки якщо таблиця порожня)
-- ================================================
INSERT INTO Leads (name, phone, email, message, status, created_at)
SELECT * FROM (
SELECT 'Ярослав Кузьменко','+380671234501','yaroslav.kuzmenko@gmail.com','Хочу поїхати до Туреччини на 2 тижні у серпні. Нас двоє з дружиною.','New','2026-05-01 09:15:00' UNION ALL
SELECT 'Людмила Павлюк','+380502345602','lyudmyla.pavlyuk@ukr.net','Цікавить тур до Єгипту на жовтень. Бюджет до 1500 USD на двох.','InProgress','2026-05-02 10:30:00' UNION ALL
SELECT 'Максим Стець','+380933456703','maksym.stets@gmail.com','Шукаю тур для сімї з дітьми. Бажано All Inclusive на море.','Done','2026-05-02 14:20:00' UNION ALL
SELECT 'Галина Остапчук','+380674567804','halyna.ostapchuk@meta.ua','Хочу поїхати до Праги або Відня. Коли є найближчі тури?','New','2026-05-03 11:45:00' UNION ALL
SELECT 'Петро Коломієць','+380505678905','petro.kolomiyets@gmail.com','Цікавить романтична поїздка до Парижу на 5 днів у вересні.','InProgress','2026-05-03 16:00:00' UNION ALL
SELECT 'Наталія Бережна','+380936789006','natalia.berezhna@ukr.net','Хочу поїхати до Греції на острови. Коли є вільні місця?','Done','2026-05-04 09:30:00' UNION ALL
SELECT 'Андрій Семенченко','+380677890107','andriy.semenchenko@gmail.com','Цікавить пляжний відпочинок у Хорватії або Чорногорії.','New','2026-05-04 13:15:00' UNION ALL
SELECT 'Оксана Мороз','+380508901208','oksana.moroz@gmail.com','Шукаю тур до ОАЕ на новий рік. Бюджет необмежений.','InProgress','2026-05-05 10:00:00' UNION ALL
SELECT 'Віктор Харченко','+380939012309','viktor.kharchenko@meta.ua','Хочу поїхати з родиною до Іспанії. Нас 4 особи.','New','2026-05-05 14:45:00' UNION ALL
SELECT 'Ірина Савченко','+380670123410','iryna.savchenko@gmail.com','Цікавить екзотичний тур — Таїланд або Балі.','Done','2026-05-06 09:20:00' UNION ALL
SELECT 'Олексій Тимченко','+380501234511','oleksiy.tymchenko@ukr.net','Планую відпустку на Мальдівах. Потрібна допомога з вибором готелю.','InProgress','2026-05-06 12:30:00' UNION ALL
SELECT 'Марина Василенко','+380932345612','maryna.vasylenko@gmail.com','Хочу поїхати до Японії. Скільки коштує тур?','New','2026-05-07 10:15:00' UNION ALL
SELECT 'Сергій Олійник','+380673456713','serhiy.oliynyk@gmail.com','Цікавить тур до Норвегії на фіорди. Коли найкращий час?','New','2026-05-07 15:00:00' UNION ALL
SELECT 'Тетяна Бойко','+380504567814','tetyana.boyko@meta.ua','Шукаю тур до Лондону на тиждень у жовтні.','Done','2026-05-08 11:30:00' UNION ALL
SELECT 'Роман Захаренко','+380935678915','roman.zakharenko@ukr.net','Хочу поїхати до Марокко або Єгипту. Що порадите?','InProgress','2026-05-08 14:20:00' UNION ALL
SELECT 'Катерина Литвиненко','+380676789016','kateryna.lytvynenko@gmail.com','Цікавить тур до Швейцарії. Нас двоє, хочемо побачити Альпи.','New','2026-05-09 09:45:00' UNION ALL
SELECT 'Богдан Прокопенко','+380507890117','bohdan.prokopenko@gmail.com','Шукаю бюджетний тур до Будапешту або Праги.','New','2026-05-09 13:00:00' UNION ALL
SELECT 'Юлія Кравець','+380938901218','yulia.kravets@meta.ua','Хочу поїхати до Португалії. Які є варіанти?','InProgress','2026-05-10 10:30:00' UNION ALL
SELECT 'Михайло Данченко','+380679012319','mykhailo.danchenko@ukr.net','Цікавить тур до Мексики на Канкун. Ціна та дати?','New','2026-05-10 15:45:00' UNION ALL
SELECT 'Вікторія Мельниченко','+380500123420','viktoria.melnychenko@gmail.com','Хочу поїхати до Дубаю на Новий рік. Що є в наявності?','Done','2026-05-11 11:00:00'
) AS nl
WHERE NOT EXISTS (SELECT 1 FROM Leads LIMIT 1);

INSERT INTO Bookings (user_id, tour_id, status, total_amount, booking_date) VALUES
(255, 1, 'Confirmed', 560.00, '2026-04-10 09:15:00'),
(256, 204, 'Confirmed', 689.00, '2026-04-11 10:30:00'),
(257, 2, 'Confirmed', 640.00, '2026-04-11 14:20:00'),
(258, 205, 'Confirmed', 1498.00, '2026-04-12 11:45:00'),
(259, 206, 'Confirmed', 1640.00, '2026-04-12 16:00:00'),
(260, 3, 'Confirmed', 390.00, '2026-04-13 09:30:00'),
(261, 207, 'Confirmed', 1980.00, '2026-04-13 13:15:00'),
(262, 208, 'Cancelled', 4200.00, '2026-04-14 10:00:00'),
(263, 209, 'Confirmed', 760.00, '2026-04-14 14:45:00'),
(264, 210, 'Confirmed', 1500.00, '2026-04-15 09:20:00'),
(265, 211, 'Pending', 870.00, '2026-04-15 12:30:00'),
(266, 212, 'Confirmed', 2700.00, '2026-04-16 10:15:00'),
(267, 213, 'Confirmed', 1040.00, '2026-04-16 15:00:00'),
(268, 214, 'Confirmed', 820.00, '2026-04-17 09:45:00'),
(269, 215, 'Confirmed', 2300.00, '2026-04-17 13:00:00'),
(270, 216, 'Pending', 1120.00, '2026-04-18 10:30:00'),
(271, 217, 'Confirmed', 1900.00, '2026-04-18 14:45:00'),
(272, 218, 'Confirmed', 2200.00, '2026-04-19 09:00:00'),
(273, 219, 'Confirmed', 2500.00, '2026-04-19 13:30:00'),
(274, 220, 'Confirmed', 2900.00, '2026-04-20 10:00:00'),
(275, 221, 'Confirmed', 1560.00, '2026-04-20 14:20:00'),
(276, 222, 'Cancelled', 690.00, '2026-04-21 09:15:00'),
(277, 223, 'Confirmed', 3960.00, '2026-04-21 12:45:00'),
(278, 224, 'Confirmed', 1440.00, '2026-04-22 10:30:00'),
(279, 225, 'Confirmed', 2300.00, '2026-04-22 15:00:00'),
(280, 226, 'Confirmed', 900.00, '2026-04-23 09:30:00'),
(281, 227, 'Pending', 3300.00, '2026-04-23 13:15:00'),
(282, 228, 'Confirmed', 3500.00, '2026-04-24 10:00:00'),
(255, 229, 'Confirmed', 1380.00, '2026-04-24 14:30:00'),
(256, 230, 'Confirmed', 680.00, '2026-04-25 09:45:00'),
(257, 1, 'Confirmed', 280.00, '2026-04-25 13:00:00'),
(258, 206, 'Confirmed', 820.00, '2026-04-26 10:15:00'),
(259, 209, 'Confirmed', 380.00, '2026-04-26 14:45:00'),
(260, 212, 'Pending', 1350.00, '2026-04-27 09:30:00'),
(261, 215, 'Confirmed', 1150.00, '2026-04-27 13:00:00'),
(262, 218, 'Confirmed', 1100.00, '2026-04-28 10:00:00'),
(263, 221, 'Confirmed', 780.00, '2026-04-28 14:20:00'),
(264, 224, 'Cancelled', 720.00, '2026-04-29 09:15:00'),
(265, 227, 'Confirmed', 1650.00, '2026-04-29 12:30:00'),
(266, 230, 'Confirmed', 680.00, '2026-04-30 10:45:00'),
(267, 204, 'Confirmed', 1378.00, '2026-05-01 09:00:00'),
(268, 207, 'Pending', 990.00, '2026-05-01 13:30:00'),
(269, 210, 'Confirmed', 750.00, '2026-05-02 10:15:00'),
(270, 213, 'Confirmed', 520.00, '2026-05-02 14:00:00'),
(271, 216, 'Confirmed', 560.00, '2026-05-03 09:45:00'),
(272, 219, 'Confirmed', 1250.00, '2026-05-03 13:15:00'),
(273, 222, 'Pending', 690.00, '2026-05-04 10:30:00'),
(274, 225, 'Confirmed', 1150.00, '2026-05-04 14:45:00'),
(275, 228, 'Confirmed', 1750.00, '2026-05-05 09:00:00'),
(276, 2, 'Confirmed', 320.00, '2026-05-05 13:30:00'),
(277, 205, 'Confirmed', 749.00, '2026-05-06 10:00:00'),
(278, 208, 'Cancelled', 2100.00, '2026-05-06 14:20:00'),
(279, 211, 'Confirmed', 870.00, '2026-05-07 09:30:00'),
(280, 214, 'Confirmed', 410.00, '2026-05-07 13:45:00'),
(281, 217, 'Pending', 950.00, '2026-05-08 10:15:00'),
(282, 220, 'Confirmed', 1450.00, '2026-05-08 14:00:00'),
(255, 223, 'Confirmed', 1980.00, '2026-05-09 09:45:00'),
(256, 226, 'Confirmed', 450.00, '2026-05-09 13:00:00'),
(257, 229, 'Confirmed', 1380.00, '2026-05-10 10:30:00'),
(258, 3, 'Confirmed', 195.00, '2026-05-10 14:45:00'),
(253, 206, 'Confirmed', 820.00, '2026-05-11 09:15:00');


-- ================================================
-- ЗАПОВНЕННЯ ТАБЛИЦІ ГОТЕЛІВ (Hotels)
-- ================================================
USE travel_agency_db;

-- 1. Оновлення назв, міст та описів для готелів з ID 11 по 30
UPDATE Hotels SET hotel_name = 'Hotel Artemide', city = 'Рим', stars = 4, description = 'Елегантний готель у центрі Риму з чудовим сервісом та спа-центром.' WHERE hotel_id = 11;
UPDATE Hotels SET hotel_name = 'Atlantis The Palm', city = 'Дубай', stars = 5, description = 'Легендарний курортний комплекс на острові Пальма Джумейра з аквапарком.' WHERE hotel_id = 12;
UPDATE Hotels SET hotel_name = 'Hotel Splendid', city = 'Будва', stars = 5, description = 'Першокласний готель на узбережжі Адріатичного моря з власним пляжем.' WHERE hotel_id = 13;
UPDATE Hotels SET hotel_name = 'Corinthia Budapest', city = 'Будапешт', stars = 5, description = 'Історичний готель класу люкс із розкішним королівським спа-комплексом.' WHERE hotel_id = 14;
UPDATE Hotels SET hotel_name = 'Centara Grand Beach Resort', city = 'Пхукет', stars = 5, description = 'Курортний готель прямо на піщаному пляжі в оточенні тропічної зелені.' WHERE hotel_id = 15;
UPDATE Hotels SET hotel_name = 'Radisson Collection Hotel', city = 'Амстердам', stars = 5, description = 'Сучасний готель преміум-класу в історичному центрі міста біля каналів.' WHERE hotel_id = 16;
UPDATE Hotels SET hotel_name = 'Plaza Athénée', city = 'Париж', stars = 5, description = 'Розкішний палац-готель поблизу Ейфелевої вежі з вишуканим інтер\'єром.' WHERE hotel_id = 17;
UPDATE Hotels SET hotel_name = 'The Ritz London', city = 'Лондон', stars = 5, description = 'Всесвітньо відомий престижний готель із традиційним англійським сервісом.' WHERE hotel_id = 18;
UPDATE Hotels SET hotel_name = 'Ayana Resort and Spa', city = 'Балі', stars = 5, description = 'Неймовірний курорт на скелі з видом на океан та численними басейнами.' WHERE hotel_id = 19;
UPDATE Hotels SET hotel_name = 'Mystique Luxury Collection', city = 'Санторіні', stars = 5, description = 'Ексклюзивний готель на скелях Ої з панорамним видом на кальдеру.' WHERE hotel_id = 20;
UPDATE Hotels SET hotel_name = 'Pestana Palace', city = 'Лісабон', stars = 5, description = 'Відновлений палац XIX століття з приватним парком та вишуканою кухнею.' WHERE hotel_id = 21;
UPDATE Hotels SET hotel_name = 'La Mamounia', city = 'Марракеш', stars = 5, description = 'Легендарний палацовий готель у марокканському стилі з розкішними садами.' WHERE hotel_id = 22;
UPDATE Hotels SET hotel_name = 'Keio Plaza Hotel', city = 'Токіо', stars = 4, description = 'Висотний готель у діловому районі Сіндзюку зі зручною транспортною розв\'язкою.' WHERE hotel_id = 23;
UPDATE Hotels SET hotel_name = 'Hotel Excelsior', city = 'Дубровник', stars = 5, description = 'Готель біля стін Старого міста з чудовим видом на Адріатичне море.' WHERE hotel_id = 24;
UPDATE Hotels SET hotel_name = 'Santa Claus Holiday Village', city = 'Рованіємі', stars = 4, description = 'Затишні котеджі безпосередньо у селищі Санта-Клауса в Лапландії.' WHERE hotel_id = 25;
UPDATE Hotels SET hotel_name = 'Rooms Hotel Tbilisi', city = 'Тбілісі', stars = 4, description = 'Стильний дизайнерський готель в історичному районі Віра.' WHERE hotel_id = 26;
UPDATE Hotels SET hotel_name = 'Grand Hotel National', city = 'Люцерн', stars = 5, description = 'Розкішний готель на березі озера з видом на Альпійські вершини.' WHERE hotel_id = 27;
UPDATE Hotels SET hotel_name = 'Hyatt Zilara Cancun', city = 'Канкун', stars = 5, description = 'Курортний готель All Inclusive на білому піщаному узбережжі Карибського моря.' WHERE hotel_id = 28;
UPDATE Hotels SET hotel_name = 'Radisson Blu Royal Hotel', city = 'Берген', stars = 4, description = 'Готель розташований у знаменитому історичному кварталі Брюгген.' WHERE hotel_id = 29;
UPDATE Hotels SET hotel_name = 'Amavi Hotel', city = 'Пафос', stars = 5, description = 'Прекрасний готель тільки для дорослих на першій береговій лінії.' WHERE hotel_id = 30;

-- 2. Прив\'язка кожного існуючого туру до відповідного готелю за реальними ID
UPDATE Tours SET hotel_id = 1 WHERE tour_id = 1;
UPDATE Tours SET hotel_id = 2 WHERE tour_id = 2;
UPDATE Tours SET hotel_id = 3 WHERE tour_id = 3;
UPDATE Tours SET hotel_id = 4 WHERE tour_id = 204;
UPDATE Tours SET hotel_id = 5 WHERE tour_id = 205;
UPDATE Tours SET hotel_id = 6 WHERE tour_id = 206;
UPDATE Tours SET hotel_id = 7 WHERE tour_id = 207;
UPDATE Tours SET hotel_id = 8 WHERE tour_id = 208;
UPDATE Tours SET hotel_id = 9 WHERE tour_id = 209;
UPDATE Tours SET hotel_id = 10 WHERE tour_id = 210;
UPDATE Tours SET hotel_id = 11 WHERE tour_id = 211;
UPDATE Tours SET hotel_id = 12 WHERE tour_id = 212;
UPDATE Tours SET hotel_id = 13 WHERE tour_id = 213;
UPDATE Tours SET hotel_id = 14 WHERE tour_id = 214;
UPDATE Tours SET hotel_id = 15 WHERE tour_id = 215;
UPDATE Tours SET hotel_id = 16 WHERE tour_id = 216;
UPDATE Tours SET hotel_id = 17 WHERE tour_id = 217;
UPDATE Tours SET hotel_id = 18 WHERE tour_id = 218;
UPDATE Tours SET hotel_id = 19 WHERE tour_id = 219;
UPDATE Tours SET hotel_id = 20 WHERE tour_id = 220;
UPDATE Tours SET hotel_id = 21 WHERE tour_id = 221;
UPDATE Tours SET hotel_id = 22 WHERE tour_id = 222;
UPDATE Tours SET hotel_id = 23 WHERE tour_id = 223;
UPDATE Tours SET hotel_id = 24 WHERE tour_id = 224;
UPDATE Tours SET hotel_id = 25 WHERE tour_id = 225;
UPDATE Tours SET hotel_id = 26 WHERE tour_id = 226;
UPDATE Tours SET hotel_id = 27 WHERE tour_id = 227;
UPDATE Tours SET hotel_id = 28 WHERE tour_id = 228;
UPDATE Tours SET hotel_id = 29 WHERE tour_id = 229;
UPDATE Tours SET hotel_id = 30 WHERE tour_id = 230;
-- ================================================
-- ЗАПОВНЕННЯ ТАБЛИЦІ ВІДГУКІВ (Reviews)
-- ================================================

INSERT INTO Reviews (user_id, tour_id, hotel_id, rating, comment) VALUES
(251, 1, 1, 5, 'Чудовий відпочинок у Буковелі. Готель зручний, близько до витягів.'),
(252, 2, 2, 4, 'Гарний тур до Кракова. Місто красиве, але екскурсії були трохи виснажливими.'),
(253, 3, 3, 5, 'Варшава вражає. Готель був у самому центрі, дуже зручно.'),
(254, 204, 4, 5, 'Анталія як завжди на висоті. Готель шикарний, їжа смачна, пляж чистий.'),
(255, 205, 5, 4, 'Шарм-ель-Шейх сподобався кораловим рифом, але номер міг би бути новішим.'),
(256, 206, 6, 5, 'Відпочинок на Криті був незабутнім. Обовязково повернемось ще раз.'),
(257, 207, 7, 5, 'Барселона неймовірна. Організація туру бездоганна.'),
(258, 208, 8, 5, 'Мальдіви - це казка. Бунгало над водою перевершило всі очікування.'),
(259, 209, 9, 4, 'Прага чудова. Готель хороший, але сніданки були дещо одноманітними.'),
(260, 210, 10, 5, 'Відень вражає архітектурою. Дуже сподобався готель і сервіс.'),
(261, 211, 11, 5, 'Рим - вічне місто. Дуже насичена та цікава програма.'),
(262, 212, 12, 5, 'Дубай - це розкіш. Готель супер, екскурсія в пустелю дуже сподобалась.'),
(263, 213, 13, 4, 'Чорногорія дуже красива. Природа неймовірна, готель відповідав своїм зіркам.'),
(264, 214, 14, 5, 'Будапешт з його купальнями - просто клас. Все організовано чудово.'),
(265, 215, 15, 5, 'Таїланд вражає екзотикою. Готель відповідав опису, все було чудово.'),
(266, 216, 16, 4, 'Амстердам цікавий, але з погодою трохи не пощастило. Готель комфортний.'),
(267, 217, 17, 5, 'Париж неймовірний. Дякую за чудовий тур і романтичну атмосферу.'),
(268, 218, 18, 5, 'Лондон дуже сподобався. Екскурсії цікаві, гід професійний.'),
(269, 219, 19, 5, 'Балі - це місце для релаксу. Все було організовано на вищому рівні.'),
(270, 220, 20, 5, 'Санторіні просто мрія. Вид з готелю був фантастичним.'),
(271, 221, 21, 4, 'Португалія чудова. Трохи втомливі переїзди, але враження найкращі.'),
(272, 222, 22, 5, 'Марокко дуже колоритне. Готель-ріад у Марракеші залишив яскраві враження.'),
(273, 223, 23, 5, 'Японія - це інший світ. Організація такої складної поїздки була ідеальною.'),
(274, 224, 24, 4, 'Хорватія сподобалася. Море чисте, але пляж біля готелю міг би бути кращим.'),
(275, 225, 25, 5, 'Лапландія - справжня казка для дітей і дорослих. Дуже сподобалося.'),
(276, 226, 26, 5, 'Грузія дуже гостинна. Смачна їжа, цікаві екскурсії, хороший готель.'),
(277, 227, 27, 5, 'Швейцарія вражає краєвидами. Все було чітко за планом, дякуємо.'),
(278, 228, 28, 5, 'Мексика неймовірна. Піраміди та пляжі залишили незабутні враження.'),
(279, 229, 29, 5, 'Норвегія вражає фіордами. Організація туру на висоті.'),
(280, 230, 30, 4, 'Кіпр - чудове місце для відпочинку. Готель непоганий, але сервіс можна покращити.');