USE parking_management_system;

-- Q1: Find all available parking slots with lot info
SELECT 
    ps.slot_number,
    ps.type,
    ps.price_per_hour,
    pl.lot_name,
    pl.location,
    ps.location_zone
FROM ParkingSlot ps
JOIN ParkingLot pl ON ps.lot_id = pl.lot_id
WHERE ps.status = 'available'
ORDER BY ps.price_per_hour ASC;

-- Q2: Find all VIP customers
SELECT 
    user_id,
    full_name,
    email,
    phone_number,
    is_vip,
    status
FROM User
WHERE is_vip = TRUE;

-- Q3: Find all active bookings with customer and vehicle details
SELECT 
    b.booking_id,
    u.full_name,
    u.phone_number,
    v.plate_number,
    v.vehicle_type,
    ps.slot_number,
    pl.lot_name,
    b.start_time,
    b.total_fee,
    b.payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Vehicle v ON b.vehicle_id = v.vehicle_id
JOIN ParkingSlot ps ON b.slot_id = ps.slot_id
JOIN ParkingLot pl ON ps.lot_id = pl.lot_id
WHERE b.booking_status = 'active';

-- Q4: Daily revenue report
SELECT 
    DATE(payment_date) AS date,
    SUM(amount) AS daily_revenue,
    COUNT(payment_id) AS num_transactions
FROM Payment
WHERE payment_status = 'completed'
GROUP BY DATE(payment_date)
ORDER BY date DESC;

-- Q5: Parking lot utilization report
SELECT 
    pl.lot_name,
    pl.location,
    pl.total_slots,
    pl.available_slots,
    (pl.total_slots - pl.available_slots) AS occupied_slots,
    ROUND((pl.total_slots - pl.available_slots) * 100.0 / pl.total_slots, 2) AS utilization_percent
FROM ParkingLot pl;

-- Q6: Staff shift schedule
SELECT 
    s.staff_id,
    u.full_name,
    u.phone_number,
    s.role,
    s.shift_start,
    s.shift_end,
    s.status
FROM Staff s
JOIN User u ON s.user_id = u.user_id
WHERE s.status = 'active';

-- Q7: Find all pending penalties
SELECT 
    p.penalty_id,
    b.booking_id,
    u.full_name,
    u.phone_number,
    p.amount,
    p.reason,
    p.issued_at
FROM Penalty p
JOIN Booking b ON p.booking_id = b.booking_id
JOIN User u ON b.user_id = u.user_id
WHERE p.status = 'pending';

-- Q8: Active reservations about to expire
SELECT 
    r.reservation_id,
    u.full_name,
    u.phone_number,
    ps.slot_number,
    pl.lot_name,
    r.expiry_time,
    TIMESTAMPDIFF(MINUTE, NOW(), r.expiry_time) AS minutes_remaining
FROM Reservation r
JOIN User u ON r.user_id = u.user_id
JOIN ParkingSlot ps ON r.slot_id = ps.slot_id
JOIN ParkingLot pl ON ps.lot_id = pl.lot_id
WHERE r.status = 'active' 
  AND r.expiry_time > NOW()
ORDER BY r.expiry_time ASC;

-- Q9: Salary payment summary by month
SELECT 
    sp.month_year,
    COUNT(sp.salary_id) AS num_payments,
    SUM(sp.amount) AS total_salary_paid,
    ROUND(AVG(sp.amount), 2) AS average_salary
FROM SalaryPayment sp
WHERE sp.payment_status = 'completed'
GROUP BY sp.month_year
ORDER BY sp.month_year DESC;

-- Q10: Revenue by parking slot type
SELECT 
    ps.type,
    COUNT(p.payment_id) AS num_payments,
    SUM(p.amount) AS total_revenue,
    ROUND(AVG(p.amount), 2) AS avg_payment
FROM ParkingSlot ps
JOIN Booking b ON ps.slot_id = b.slot_id
JOIN Payment p ON b.booking_id = p.booking_id
WHERE p.payment_status = 'completed'
GROUP BY ps.type
ORDER BY total_revenue DESC;

-- Q11: Top 5 customers by total spent
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.phone_number,
    u.is_vip,
    SUM(p.amount) AS total_spent
FROM User u
JOIN Booking b ON u.user_id = b.user_id
JOIN Payment p ON b.booking_id = p.booking_id
WHERE p.payment_status = 'completed'
GROUP BY u.user_id
ORDER BY total_spent DESC
LIMIT 5;

-- Q12: Currently occupied slots with real-time info
SELECT 
    ps.slot_number,
    ps.type,
    pl.lot_name,
    pl.location,
    u.full_name AS occupied_by,
    v.plate_number,
    b.start_time,
    TIMESTAMPDIFF(HOUR, b.start_time, NOW()) AS hours_parked,
    ps.price_per_hour * TIMESTAMPDIFF(HOUR, b.start_time, NOW()) AS estimated_fee
FROM ParkingSlot ps
JOIN ParkingLot pl ON ps.lot_id = pl.lot_id
JOIN Booking b ON ps.slot_id = b.slot_id
JOIN User u ON b.user_id = u.user_id
JOIN Vehicle v ON b.vehicle_id = v.vehicle_id
WHERE ps.is_occupied = TRUE AND b.booking_status = 'active';

-- Q13: Payment method breakdown
SELECT 
    payment_method,
    COUNT(payment_id) AS usage_count,
    SUM(amount) AS total_amount,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM Payment WHERE payment_status = 'completed'), 2) AS percentage
FROM Payment
WHERE payment_status = 'completed'
GROUP BY payment_method
ORDER BY total_amount DESC;

-- Q14: Staff performance (bookings handled)
SELECT 
    s.staff_id,
    u.full_name,
    s.role,
    COUNT(b.booking_id) AS bookings_handled,
    SUM(b.total_fee) AS total_revenue
FROM Staff s
JOIN User u ON s.user_id = u.user_id
LEFT JOIN Booking b ON u.user_id = b.user_id
WHERE b.payment_status = 'paid'
GROUP BY s.staff_id, u.full_name, s.role
ORDER BY total_revenue DESC;

-- Q15: Overstay penalties report
SELECT 
    p.penalty_id,
    u.full_name,
    v.plate_number,
    b.start_time,
    b.end_time,
    TIMESTAMPDIFF(HOUR, b.start_time, b.end_time) AS hours_booked,
    TIMESTAMPDIFF(HOUR, b.start_time, NOW()) AS hours_actual,
    p.amount,
    p.status
FROM Penalty p
JOIN Booking b ON p.booking_id = b.booking_id
JOIN User u ON b.user_id = u.user_id
JOIN Vehicle v ON b.vehicle_id = v.vehicle_id
WHERE p.reason = 'overstay';

-- Q16: VIP customer analysis
SELECT 
    u.full_name,
    u.phone_number,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_fee) AS total_spent,
    AVG(b.total_fee) AS avg_booking_value
FROM User u
JOIN Booking b ON u.user_id = b.user_id
WHERE u.is_vip = TRUE AND b.payment_status = 'paid'
GROUP BY u.user_id;

-- Q17: Parking lot revenue comparison
SELECT 
    pl.lot_name,
    COUNT(p.payment_id) AS total_transactions,
    SUM(p.amount) AS total_revenue,
    ROUND(AVG(p.amount), 2) AS avg_transaction
FROM ParkingLot pl
JOIN ParkingSlot ps ON pl.lot_id = ps.lot_id
JOIN Booking b ON ps.slot_id = b.slot_id
JOIN Payment p ON b.booking_id = p.booking_id
WHERE p.payment_status = 'completed'
GROUP BY pl.lot_id
ORDER BY total_revenue DESC;

-- Q18: Reservations vs actual bookings conversion
SELECT 
    COUNT(r.reservation_id) AS total_reservations,
    COUNT(CASE WHEN r.status = 'completed' THEN 1 END) AS converted_bookings,
    COUNT(CASE WHEN r.status = 'expired' THEN 1 END) AS expired_reservations,
    ROUND(COUNT(CASE WHEN r.status = 'completed' THEN 1 END) * 100.0 / COUNT(r.reservation_id), 2) AS conversion_rate
FROM Reservation r;

-- Q19: Monthly salary summary
SELECT 
    DATE_FORMAT(sp.month_year, '%Y-%m') AS month,
    s.role,
    COUNT(sp.salary_id) AS payments_made,
    SUM(sp.amount) AS total_amount,
    ROUND(AVG(sp.amount), 2) AS average_salary
FROM SalaryPayment sp
JOIN Staff st ON sp.staff_id = st.staff_id
JOIN User u ON st.user_id = u.user_id
JOIN Staff s ON st.staff_id = s.staff_id
GROUP BY DATE_FORMAT(sp.month_year, '%Y-%m'), s.role
ORDER BY month DESC;

-- Q20: Customer lifetime value (CLV)
SELECT 
    u.user_id,
    u.full_name,
    u.is_vip,
    COUNT(DISTINCT b.booking_id) AS total_visits,
    SUM(b.total_fee) AS total_revenue,
    ROUND(SUM(b.total_fee) / COUNT(DISTINCT b.booking_id), 2) AS avg_per_visit,
    DATEDIFF(MAX(b.start_time), MIN(b.start_time)) AS customer_lifetime_days
FROM User u
JOIN Booking b ON u.user_id = b.user_id
WHERE b.payment_status = 'paid'
GROUP BY u.user_id
HAVING total_visits > 0
ORDER BY total_revenue DESC;
