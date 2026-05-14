#  EXECUTIVE SUMMARY
This project delivers a comprehensive relational database solution for an
Integrated Parking Management System (PMS). The system manages ten core entities:
 • User • Booking • Payment • Penalty
 • Vehicle • Reservation • Parking Lot • Salary Payment
 • Parking Slot • Staff
By digitizing the tracking of vehicles, slot occupancy, staff shifts, and financial transactions, 
the system eliminates manual entry errors, reduces revenue leakage, and optimizes the 
utilization of physical parking assets.
The database supports real-time occupancy monitoring, VIP customer management,
automated penalty calculation, and comprehensive financial reporting. Both MySQL 
(relational) and MongoDB (NoSQL) implementations ensure flexibility for different 
operational needs.

#  INTRODUCTION & PROBLEM STATEMENT
Urban parking facilities frequently face challenges such as:
 1. Revenue leakage due to untracked overstays
 2. Slow vehicle processing at entry/exit points
 3. Inefficient space allocation across different vehicle types
 4. Lack of data for pricing optimization
 5. No systematic VIP or loyalty program
 6. Difficulty in staff shift and payroll management
 7. Manual penalty issuance and tracking
 8. No advance reservation system
This project addresses these bottlenecks by implementing a structured database that provides 
real-time visibility into facility operations, automates fee Calculation, and enables data-driven 
decision making.
# PROJECT OBJECTIVES
The primary goal is to establish a centralized repository that manages the complete lifecycle
of a parking event—from user registration and vehicle entry to automated fee calculation, 
payment processing, and penalty enforcement.
Specific Objectives:
 
 1. Design a normalized database schema (BCNF) for all parking operations
 2. Implement both MySQL (relational) and MongoDB (NoSQL) solutions
 3. Track real-time slot occupancy across multiple parking lots
 4. Automate fee calculation based on duration and slot type
 5. Support advance reservations with expiry handling
 6. Manage staff information, shifts, and salary payments
 7. Track penalties for overstay and violations
 8. Generate operational and financial reports
 9. Implement VIP customer benefits and loyalty tracking
 10. Ensure data security with role-based access control
# SYSTEM REQUIREMENTS ANALYSIS
The system is designed to handle high-concurrency environments. Key requirements
were gathered through stakeholder surveys (see Annex: survey_questions.pdf).
## Functional Requirements
 • User registration and authentication
 • Vehicle registration (multiple vehicles per user)
 • Real-time slot availability checking
 • Booking creation, modification, and cancellation
 • Advance reservation with time-limited expiry
 • Automated fee calculation based on duration
 • Payment processing (cash, card, Telebirr, mobile money)
 • Penalty issuance for overstay or violations
 • Staff shift scheduling and salary management
 • VIP customer benefits and discount logic
 • Report generation (revenue, utilization, penalties)
## Non-Functional Requirements
 • ACID compliance for financial transactions
 • Response time < 2 seconds for availability checks
 • 99.9% uptime for critical operations
 • Data retention for 7 years (financial records)
 • Role-based access control with audit logging
# DATA COLLECTION METHODOLOGY
Requirement gathering was conducted through a comprehensive 10-page stakeholder
survey distributed to:
 • Customers (Section A & D) - 50 respondents
 • Staff/Attendants (Section B) - 15 respondents
 • Management (Section C & E) - 5 respondents
Key findings from the survey:
 • 68% of customers prefer mobile money (Telebirr) payment
 • 45% of users would pay for VIP subscription (500-1000 birr/month)
 • Staff identified North Zone as highest congestion area
 • Management targets 5,000 birr daily revenue
 • Overstay penalties are most common violation (72% of penalties)
Survey responses directly informed:
 • price_per_hour values for different slot types
 • is_vip logic and discount rates
 • location_zone and floor_number assignments
 • shift_start and shift_end for staff schedules
 • penalty amount calculation rules
# ENTITY-RELATIONSHIP (ER) DIAGRAM LOGIC
The architecture follows a star-like schema where the Booking entity acts as the Central hub, 
connecting User, Vehicle, and Parking Slot. This ensures that every transaction is traceable to 
a specific individual and physical asset.
## Core Entities and Relationships
 User (1) ──────< (M) Vehicle - One user can own multiple vehicles
 User (1) ──────< (M) Booking - One user can make multiple bookings
 User (1) ──────< (M) Reservation - One user can make multiple reservations
 User (1) ──────|| (1) Staff - One user can be a staff member
 Parking Lot (1) ──< (M) Parking Slot - One lot contains multiple slots
 Parking Slot (1) ──< (M) Booking - One slot can have multiple bookings
 Parking Slot (1) ──< (M) Reservation - One slot can have multiple reservations
 Booking (1) ───── (1) Payment - Each booking has one payment
 Booking (1) ─────< (M) Penalty - One booking can have multiple penalties
 Staff (1) ──────< (M) Salary Payment - One staff receives multiple salaries

## Relational Cardinalities
 • User to Vehicle: One-to-Many (cascade delete)
 • User to Booking: One-to-Many (restrict delete)
 • Parking Lot to Parking Slot: One-to-Many (cascade delete)
 • Booking to Payment: One-to-One (unique constraint)
 • Booking to Penalty: One-to-Many (optional)
# RELATIONAL DATABASE SCHEMA DESIGN
The schema utilizes MySQL data types effectively, employing ENUM types for
status tracking and DECIMAL for financial accuracy. Foreign key constraints
maintain referential integrity.
## Complete List of Tables
 
Valid role and status values
 • DEFAULT values: created_at, status defaults
 • ON DELETE CASCADE: Automatic cleanup of dependent records
 ## Data Type Selection Rationale
 • INT/AUTO_INCREMENT: Surrogate keys for efficient joins
 • VARCHAR(20) for phone_number: E.164 format support
 • ENUM for status fields: Constrained values, storage efficiency
 • DECIMAL(10,2) for financial fields: Exact decimal precision
 • DATETIME for timestamps: Timezone-aware tracking
 • TIME for shift times: Duration-agnostic time storage
# DATABASE NORMALIZATION & INTEGRITY
To ensure data redundancy is minimized, the database is normalized to the
Third Normal Form (3NF) / BCNF. This structure prevents update anomalies and
ensures that non-key attributes are functionally dependent only on the primary
key.
## Normalization Process
Step 1: Unnormalized Form (UNF)
 Booking(user_id, user_name, user_phone, slot_number, slot_type, price,
 plate_number, start_time, end_time, total_fee)
Step 2: First Normal Form (1NF) - Remove repeating groups
 Separate repeating groups into individual rows/ tables
Step 3: Second Normal Form (2NF) - Remove partial dependencies
 Move slot_type, price to ParkingSlot table
 Move user_name, user_phone to User table
Step 4: Third Normal Form (3NF) - Remove transitive dependencies
 No transitive dependencies remain
Step 5: Boyce-Codd Normal Form (BCNF)
 Every determinant is a candidate key - satisfied
## Integrity Constraints Implemented
 • Primary Keys: Uniquely identify each row
 • Foreign Keys: Maintain referential integrity
 • UNIQUE constraints: email, phone_number, plate_number, slot_number
 • NOT NULL constraints: Required fields
 • CHECK constraints:
 # IMPLEMENTATION : DDL AND DML
The database was instantiated using standard SQL scripts (see Appendix A for
complete schema). Sample datasets were injected to simulate real-world scenarios
including active parkers, completed stays, and slots currently under maintenance.
## DDL Summary (schema.sql)
 • 10 CREATE TABLE statements with all constraints
 • Foreign key relationships with ON DELETE CASCADE/SET NULL
 • ENUM definitions for status and type fields
 • UNIQUE constraints for email, phone, plate_number, slot_number
 • Indexes on frequently queried columns (status, is_occupied)

## DML Summary (data insertion)
 • User: 6 records (customers, admin, manager, staff)
 • Vehicle: 6 records (cars, motorcycle, truck)
 • ParkingLot: 3 records (multiple locations)
 • ParkingSlot: 10 records (various types and zones)
 • Staff: 2 records (attendant, supervisor)
 • Booking: 6 records (active and completed)
 • Payment: 4 records (various methods)
 • Reservation: 3 records (active reservations)
 • Penalty: 2 records (overstay, no_payment)
 • SalaryPayment: 2 records (monthly salaries)
## Technology Stack
 • MySQL 8.0: Relational database engine
 • MongoDB 6.0: NoSQL document store
 • Draw.io: ER Diagram design
 • Mermaid: Diagram-as-code rendering
 • GitHub: Version control and collaboration
# ANALYSIS: INFORMATION RETRIEVAL
Standard retrieval queries allow staff to quickly identify available slots by
price or location, while customers can view their active parking status and
historical records.
## Key Retrieval Queries (See queries.sql for complete list)
 • Find all available slots: SELECT with status = 'available'
 • Find VIP slots only: Filter by type = 'vip'
 • User booking history: JOIN User + Booking + Vehicle
 • Currently occupied slots: is_occupied = TRUE with customer info
 • Vehicle lookup by plate: Exact match on plate_number
## Sample Query: Available VIP Slots
 SELECT ps.slot_number, ps.price_per_hour, pl.lot_name, pl.location
 FROM ParkingSlot ps
 JOIN ParkingLot pl ON ps.lot_id = pl.lot_id
 WHERE ps.type = 'vip' AND ps.status = 'available';
## Sample Query: Customer Active Bookings
 SELECT b.booking_id, b.start_time, ps.slot_number, pl.lot_name
 FROM Booking b
 JOIN ParkingSlot ps ON b.slot_id = ps.slot_id
 JOIN ParkingLot pl ON ps.lot_id = pl.lot_id
 WHERE b.user_id = [user_id] AND b.booking_status = 'active';

 # ANALYSIS: FINANCIAL REPORTING
The system generates automated revenue reports, aggregating income by date and
payment channel. This allows management to monitor the facility's economic
health and identify peak revenue periods.
## Revenue Reports Implemented
 • Daily revenue summary (by date)
 • Payment method breakdown (cash vs card vs Telebirr)
 • Revenue by slot type (VIP vs Standard)
 • Monthly revenue trends
 • Revenue forecast from active bookings
## Sample Query: Daily Revenue Report
 SELECT DATE(payment_date) AS date,
 SUM(amount) AS daily_revenue,
 COUNT(payment_id) AS num_transactions,
 ROUND(AVG(amount), 2) AS avg_transaction
 FROM Payment
 WHERE payment_status = 'completed'
 GROUP BY DATE(payment_date)
 ORDER BY date DESC;
## Sample Query: Revenue by Slot Type
 SELECT ps.type,
 COUNT(p.payment_id) AS num_payments,
 SUM(p.amount) AS total_revenue,
 ROUND(AVG(p.amount), 2) AS avg_payment
 FROM Payment p
 JOIN Booking b ON p.booking_id = b.booking_id
 JOIN ParkingSlot ps ON b.slot_id = ps.slot_id
 WHERE p.payment_status = 'completed'
 GROUP BY ps.type
 ORDER BY total_revenue DESC;
# ANALYSIS: OPERATIONAL METRICS
By calculating the ratio of occupied to total slots per floor or per lot, the
system provides a utilization index. This helps in directing traffic to less
crowded zones, improving the overall flow of the facility.
## Operational Metrics Implemented
 • Utilization rate by floor (occupied/total * 100)
 • Utilization rate by parking lot
 • Average parking duration
 • Peak hour analysis (by hour of day)
 • Staff performance (bookings handled per staff)
 • Slot turnover rate

## Sample Query: Utilization by Parking Lot
 SELECT pl.lot_name,
 pl.total_slots,
 pl.available_slots,
 (pl.total_slots - pl.available_slots) AS occupied_slots,
 ROUND((pl.total_slots - pl.available_slots) * 100.0 / pl.total_slots, 2) AS 
utilization_percent
 FROM ParkingLot pl;
## Sample Query: Peak Hour Analysis
 SELECT HOUR(start_time) AS hour_of_day,
 COUNT(booking_id) AS bookings_started,
 SUM(total_fee) AS revenue
 FROM Booking
 WHERE payment_status = 'paid'
 GROUP BY HOUR(start_time)
 ORDER BY revenue DESC
 LIMIT 5;
# ANALYSIS: BEHAVIORAL PATTERNS
The database tracks user frequency, identifying "Frequent Parkers." This
intelligence allows the business to target specific users for loyalty programs
or VIP upgrades.
## Behavioral Metrics Implemented
 • Customer lifetime value (total spent per customer)
 • Visit frequency (bookings per time period)
 • Preferred parking hours (time-of-day analysis)
 • Preferred slot types
 • Cancellation rate analysis
 • No-show rate for reservations
## Sample Query: Top Customers by Lifetime Value
 SELECT u.user_id,
 u.full_name,
 u.is_vip,
 COUNT(b.booking_id) AS total_visits,
 SUM(b.total_fee) AS lifetime_value,
 ROUND(AVG(b.total_fee), 2) AS avg_per_visit
 FROM User u
 JOIN Booking b ON u.user_id = b.user_id
 WHERE b.payment_status = 'paid'
 GROUP BY u.user_id
 ORDER BY lifetime_value DESC
 LIMIT 10;
 
## Sample Query: Reservation Conversion Rate
 SELECT COUNT(r.reservation_id) AS total_reservations,
 COUNT(CASE WHEN r.status = 'completed' THEN 1 END) AS converted,
 COUNT(CASE WHEN r.status = 'expired' THEN 1 END) AS expired,
 ROUND(COUNT(CASE WHEN r.status = 'completed' THEN 1 END) * 100.0 /
 COUNT(r.reservation_id), 2) AS conversion_rate
 FROM Reservation r;
# VIP PROGRAM MODELING
The system includes logic for a VIP tier, offering premium slots and discounted
rates. Data analysis compares standard revenue against potential loyalty
earnings to justify the program's expansion.
## VIP Features Implemented
 • is_vip boolean flag in User table
 • VIP-only parking slots (type = 'vip')
 • Discount logic for total_fee calculation
 • Priority reservation windows
 • VIP customer analytics
## Sample Query: VIP vs Non-VIP Comparison
 SELECT u.is_vip,
 COUNT(b.booking_id) AS total_bookings,
 SUM(b.total_fee) AS total_revenue,
 ROUND(AVG(b.total_fee), 2) AS avg_booking_value
 FROM User u
 JOIN Booking b ON u.user_id = b.user_id
 WHERE b.payment_status = 'paid'
 GROUP BY u.is_vip;
## VIP Recommendation Logic
 Based on frequency analysis, users with:
 • 5+ bookings per month
 • Total monthly spend > 500 birr
 • 0 no-shows in last 3 months
 → Eligible for VIP upgrade invitation
# SECURITY & ACCESS CONTROL
Access is strictly partitioned using role-based access control (RBAC). Users
can only interact with their own data, while Managers and Admins have graduated
levels of oversight for maintenance and financial auditing



for more detailed information please check the final report.pdf file 

