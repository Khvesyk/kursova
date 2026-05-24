USE travel_agency_db;

-- 1. Виведення списку клієнтів (контактна інформація)
SELECT user_id, first_name, last_name, email, phone_number, created_at
FROM Users
WHERE role = 'Client'
ORDER BY created_at DESC;

-- 2. Детальна інформація про бронювання (хто замовив, який тур, статус)
SELECT b.booking_id, u.first_name, u.last_name, t.tour_title, b.booking_date, b.status, b.total_amount
FROM Bookings b
JOIN Users u ON b.user_id = u.user_id
JOIN Tours t ON b.tour_id = t.tour_id
ORDER BY b.booking_date DESC;

-- 3. Пошук актуальних турів у ціновому діапазоні (від 500 до 1500)
SELECT tour_title, region, price_per_person, start_date, end_date
FROM Tours
WHERE is_active = TRUE 
  AND price_per_person BETWEEN 500.00 AND 1500.00
ORDER BY price_per_person ASC;

-- 4. Інформація про тури разом із деталями готелів
SELECT t.tour_title, t.region, h.hotel_name, h.stars, t.price_per_person
FROM Tours t
LEFT JOIN Hotels h ON t.hotel_id = h.hotel_id
WHERE t.is_active = TRUE;

-- 5. Підрахунок загальної статистики доходів та кількості бронювань за статусами
SELECT status, COUNT(booking_id) AS total_bookings, SUM(total_amount) AS expected_revenue
FROM Bookings
GROUP BY status;

-- 6. Аналіз турів та готелів за країнами (регіонами)

SELECT t.region AS country, 
       COUNT(t.tour_id) AS total_tours, 
       COUNT(DISTINCT h.hotel_id) AS available_hotels, 
       MIN(t.price_per_person) AS min_price
FROM Tours t
LEFT JOIN Hotels h ON t.hotel_id = h.hotel_id
WHERE t.is_active = TRUE
GROUP BY t.region
ORDER BY total_tours DESC;

-- 7. Аналіз необроблених заявок (нові ліди)
SELECT lead_id, name, phone, email, message, created_at
FROM Leads
WHERE status = 'New'
ORDER BY created_at ASC;

-- 8. Рейтинг популярності турів (від найбільш популярного до найменш)
SELECT t.tour_id, t.tour_title, t.region, COUNT(b.booking_id) AS number_of_bookings
FROM Tours t
LEFT JOIN Bookings b ON t.tour_id = b.tour_id
GROUP BY t.tour_id, t.tour_title, t.region
ORDER BY number_of_bookings DESC;

-- 9. Рейтинг турів та готелів на основі відгуків клієнтів

SELECT t.tour_title, 
       h.hotel_name, 
       ROUND(AVG(r.rating), 1) AS average_rating, 
       COUNT(r.review_id) AS total_reviews
FROM Reviews r
JOIN Tours t ON r.tour_id = t.tour_id
JOIN Hotels h ON r.hotel_id = h.hotel_id
GROUP BY t.tour_id, t.tour_title, h.hotel_name
ORDER BY average_rating DESC;

-- 10. Підрахунок загальної суми, витраченої кожним клієнтом на підтверджені тури (Топ-10 клієнтів)
SELECT u.user_id, u.first_name, u.last_name, SUM(b.total_amount) AS total_spent
FROM Users u
JOIN Bookings b ON u.user_id = b.user_id
WHERE b.status = 'Confirmed'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_spent DESC
LIMIT 10;