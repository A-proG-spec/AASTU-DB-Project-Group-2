-- Create database
CREATE DATABASE IF NOT EXISTS parking_management_system;
USE parking_management_system;


-- 1. USER TABLE

CREATE TABLE User (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'manager', 'customer', 'staff') DEFAULT 'customer',
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    is_vip BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active'
);


-- 2. VEHICLE TABLE

CREATE TABLE Vehicle (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    plate_number VARCHAR(20) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    vehicle_type ENUM('car', 'motorcycle', 'truck', 'bus', 'bicycle') NOT NULL,
    brand VARCHAR(50),
    color VARCHAR(30),
    registered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);


-- 3. PARKING LOT TABLE

CREATE TABLE ParkingLot (
    lot_id INT PRIMARY KEY AUTO_INCREMENT,
    lot_name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    total_slots INT NOT NULL,
    available_slots INT NOT NULL,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    status ENUM('open', 'closed', 'maintenance', 'full') DEFAULT 'open'
);


-- 4. PARKING SLOT TABLE

CREATE TABLE ParkingSlot (
    slot_id INT PRIMARY KEY AUTO_INCREMENT,
    slot_number VARCHAR(10) UNIQUE NOT NULL,
    lot_id INT NOT NULL,
    type ENUM('standard', 'vip', 'handicap', 'compact', 'large', 'electric') NOT NULL,
    price_per_hour DECIMAL(10,2) NOT NULL,
    is_occupied BOOLEAN DEFAULT FALSE,
    location_zone VARCHAR(50),
    floor_number INT,
    status ENUM('available', 'occupied', 'maintenance', 'reserved') DEFAULT 'available',
    FOREIGN KEY (lot_id) REFERENCES ParkingLot(lot_id)
);


-- 5. STAFF TABLE

CREATE TABLE Staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    role ENUM('attendant', 'supervisor', 'manager', 'security', 'cleaner') NOT NULL,
    shift_start TIME NOT NULL,
    shift_end TIME NOT NULL,
    status ENUM('active', 'on_leave', 'inactive') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);


-- 6. BOOKING TABLE

CREATE TABLE Booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    slot_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    duration DECIMAL(10,2),
    total_fee DECIMAL(10,2),
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    booking_status ENUM('active', 'completed', 'cancelled', 'expired', 'no_show') DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (slot_id) REFERENCES ParkingSlot(slot_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)
);


-- 7. PAYMENT TABLE

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'credit_card', 'debit_card', 'mobile_money', 'telebirr') NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(100) UNIQUE,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);


-- 8. RESERVATION TABLE

CREATE TABLE Reservation (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    slot_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    reservation_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    expiry_time DATETIME NOT NULL,
    status ENUM('active', 'expired', 'cancelled', 'completed') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (slot_id) REFERENCES ParkingSlot(slot_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)
);


-- 9. PENALTY TABLE

CREATE TABLE Penalty (
    penalty_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason ENUM('overstay', 'wrong_parking', 'damage', 'no_payment', 'other') NOT NULL,
    issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'paid', 'waived') DEFAULT 'pending',
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);


-- 10. SALARY PAYMENT TABLE

CREATE TABLE SalaryPayment (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('cash', 'bank_transfer', 'telebirr') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    month_year DATE NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);


-- 11. INSERT SAMPLE DATA


-- Insert Users
INSERT INTO User (password_hash, role, full_name, email, phone_number, is_vip, status) VALUES
('hashed_pwd_1', 'customer', 'John Doe', 'john@example.com', '0912345678', FALSE, 'active'),
('hashed_pwd_2', 'customer', 'Jane Smith', 'jane@example.com', '0923456789', TRUE, 'active'),
('hashed_pwd_3', 'admin', 'Admin User', 'admin@parking.com', '0934567890', FALSE, 'active'),
('hashed_pwd_4', 'manager', 'Mike Manager', 'manager@parking.com', '0945678901', FALSE, 'active'),
('hashed_pwd_5', 'customer', 'VIP Customer', 'vip@example.com', '0956789012', TRUE, 'active'),
('hashed_pwd_6', 'staff', 'John Attendant', 'attendant@parking.com', '0967890123', FALSE, 'active');

-- Insert Vehicles
INSERT INTO Vehicle (plate_number, user_id, vehicle_type, brand, color) VALUES
('AA-1234', 1, 'car', 'Toyota', 'White'),
('BB-5678', 2, 'car', 'Honda', 'Black'),
('CC-9012', 2, 'motorcycle', 'Yamaha', 'Red'),
('DD-3456', 3, 'truck', 'Ford', 'Blue'),
('EE-7890', 4, 'car', 'Hyundai', 'Silver'),
('FF-1112', 5, 'car', 'BMW', 'Black');

-- Insert Parking Lots
INSERT INTO ParkingLot (lot_name, location, total_slots, available_slots, opening_time, closing_time, status) VALUES
('Main Campus Lot', 'AASTU Main Campus', 50, 45, '06:00:00', '22:00:00', 'open'),
('VIP Plaza', 'Bole Road', 30, 28, '00:00:00', '23:59:00', 'open'),
('Shopping Mall Lot', 'Mexico Square', 100, 80, '08:00:00', '23:00:00', 'open');

-- Insert Parking Slots
INSERT INTO ParkingSlot (slot_number, lot_id, type, price_per_hour, is_occupied, location_zone, floor_number, status) VALUES
('A01', 1, 'standard', 50.00, FALSE, 'North', 1, 'available'),
('A02', 1, 'standard', 50.00, FALSE, 'North', 1, 'available'),
('A03', 1, 'vip', 100.00, FALSE, 'North', 1, 'available'),
('A04', 1, 'handicap', 40.00, FALSE, 'North', 1, 'available'),
('B01', 1, 'standard', 50.00, TRUE, 'South', 1, 'occupied'),
('B02', 1, 'compact', 40.00, FALSE, 'South', 1, 'available'),
('C01', 2, 'large', 80.00, FALSE, 'East', 2, 'available'),
('C02', 2, 'vip', 100.00, TRUE, 'East', 2, 'occupied'),
('C03', 2, 'electric', 90.00, FALSE, 'East', 2, 'available'),
('D01', 3, 'standard', 50.00, FALSE, 'West', 1, 'available');

-- Insert Staff
INSERT INTO Staff (user_id, role, shift_start, shift_end, status) VALUES
(6, 'attendant', '08:00:00', '16:00:00', 'active'),
(1, 'supervisor', '09:00:00', '17:00:00', 'active');

-- Insert Bookings
INSERT INTO Booking (user_id, slot_id, vehicle_id, start_time, end_time, duration, total_fee, payment_status, booking_status) VALUES
(1, 1, 1, '2026-04-27 08:00:00', '2026-04-27 12:00:00', 4.00, 200.00, 'paid', 'completed'),
(2, 3, 2, '2026-04-27 09:00:00', '2026-04-27 17:00:00', 8.00, 800.00, 'paid', 'completed'),
(2, 6, 3, '2026-04-28 10:00:00', NULL, NULL, NULL, 'pending', 'active'),
(5, 8, 6, '2026-04-28 09:00:00', NULL, NULL, NULL, 'pending', 'active'),
(1, 2, 1, '2026-04-29 14:00:00', '2026-04-29 18:00:00', 4.00, 200.00, 'pending', 'active'),
(3, 4, 4, '2026-04-27 06:00:00', '2026-04-27 14:00:00', 8.00, 320.00, 'paid', 'completed');

-- Insert Payments
INSERT INTO Payment (booking_id, amount, payment_method, payment_status, transaction_id) VALUES
(1, 200.00, 'cash', 'completed', 'TXN001'),
(2, 800.00, 'credit_card', 'completed', 'TXN002'),
(4, 320.00, 'mobile_money', 'completed', 'TXN003'),
(6, 200.00, 'telebirr', 'pending', 'TXN004');

-- Insert Reservations
INSERT INTO Reservation (user_id, slot_id, vehicle_id, expiry_time, status) VALUES
(1, 1, 1, '2026-04-30 10:00:00', 'active'),
(2, 3, 2, '2026-04-30 09:00:00', 'active'),
(5, 8, 6, '2026-04-29 20:00:00', 'active');

-- Insert Penalties
INSERT INTO Penalty (booking_id, amount, reason, status) VALUES
(2, 100.00, 'overstay', 'pending'),
(1, 50.00, 'no_payment', 'paid');

-- Insert Salary Payments
INSERT INTO SalaryPayment (staff_id, amount, payment_date, payment_method, payment_status, month_year) VALUES
(1, 5000.00, '2026-04-30', 'bank_transfer', 'completed', '2026-04-01'),
(2, 8000.00, '2026-04-30', 'cash', 'completed', '2026-04-01');

-- Update occupied slots
UPDATE ParkingSlot SET is_occupied = TRUE, status = 'occupied' WHERE slot_id IN (3, 6, 8);
UPDATE ParkingLot SET available_slots = total_slots - (SELECT COUNT(*) FROM ParkingSlot WHERE is_occupied = TRUE AND lot_id = ParkingLot.lot_id);
